import 'package:intl/intl.dart';
import 'package:betcontrol/database/database.dart';
import 'package:betcontrol/database/tables/balanceTable.dart';
import 'package:betcontrol/models/balance.dart';
import 'package:betcontrol/models/balancePerDay.dart';

class BalanceRepository {
  static final BalanceRepository instance = BalanceRepository.internal();

  factory BalanceRepository() => instance;

  BalanceRepository.internal();

  Future<Balance> insert(balance) async {
    final db = await DatabaseHelper.instance.database;
    balance.date = DateTime.now().toLocal();

    balance.id = await db.insert(BalanceTable.name, balance.toMap());
    return balance;
  }

  Future<List<Balance>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    var results = await db.query(BalanceTable.name);

    return results.map((e) => Balance.fromMap(e)).toList();
  }

  Future<Balance> getByDate(DateTime date) async {
    final db = await DatabaseHelper.instance.database;
    final dateString = DateFormat('yyyy-MM-dd').format(date);
    var result = await db.query(BalanceTable.name,
        where: "${BalanceTable.columnDate} = ?", whereArgs: [dateString]);

    if (result.length > 0) {
      return Balance.fromMap(result.first);
    }
    return null;
  }

  Future<Balance> getById(int id) async {
    final db = await DatabaseHelper.instance.database;
    var result = await db.query(BalanceTable.name,
        columns: [
          BalanceTable.columnId,
          BalanceTable.columnBalance,
          BalanceTable.columnDate,
          BalanceTable.columnDayProfit,
          BalanceTable.columnDayLoss
        ],
        where: "${BalanceTable.columnId} = ?",
        whereArgs: [id]);

    if (result.length > 0) {
      return Balance.fromMap(result.first);
    } else {
      return null;
    }
  }

  Future<Balance> getLast() async {
    final db = await DatabaseHelper.instance.database;
    var result = await db.rawQuery(
        "SELECT * FROM ${BalanceTable.name} ORDER BY ${BalanceTable.columnId} DESC LIMIT 1");
    if (result.length > 0) {
      return await _returnUpdatedBalance(Balance.fromMap(result.first));
    } else {
      return await insert(Balance(
          balance: 0,
          date: DateTime.now().toLocal(),
          dayProfit: 0,
          dayLoss: 0,
          growthRate: 0));
    }
  }

  Future<Balance> _returnUpdatedBalance(Balance b) async {
    final today = DateTime.now().toLocal();
    if (b.date.day == today.day &&
        b.date.month == today.month &&
        b.date.year == today.year) {
      return b;
    } else {
      return await insert(Balance(
          balance: b.balance,
          date: today,
          dayLoss: 0,
          dayProfit: 0,
          growthRate: 0));
    }
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(BalanceTable.name,
        where: "${BalanceTable.columnId} = ?", whereArgs: [id]);
  }

  Future<int> updateOnInsertBet(double profit, String date) async {
    final db = await DatabaseHelper.instance.database;
    var b = await getLast();

    final rate = await calculateGrowthRate(b.balance + profit, b.date);

    if (date != DateFormat('dd/MM/yyyy').format(b.date)) {
      Balance newBalance = await insert(Balance(
          balance: b.balance + profit,
          dayProfit: profit > 0 ? profit : 0,
          dayLoss: profit < 0 ? profit : 0,
          date: DateTime.now().toLocal(),
          growthRate: rate));
      return newBalance.id;
    } else {
      b.balance += profit;
      b.growthRate = rate;
      b.dayProfit += profit > 0 ? profit : 0;
      b.dayLoss += profit < 0 ? profit : 0;

      return await db.update(BalanceTable.name, b.toMap(),
          where: "${BalanceTable.columnId} = ?", whereArgs: [b.id]);
    }
  }

  Future updateBalance(double balance) async {
    final db = await DatabaseHelper.instance.database;
    var b = await getLast();

    b.balance = balance;
    b.growthRate = await calculateGrowthRate(balance, b.date);
    return await db.update(BalanceTable.name, b.toMap(),
        where: "${BalanceTable.columnId} = ?", whereArgs: [b.id]);
  }

  Future updateOnDeleteBet(double profit) async {
    final db = await DatabaseHelper.instance.database;
    var b = await getLast();

    b.balance += profit;
    b.growthRate = await calculateGrowthRate(b.balance, b.date);
    if (profit < 0) {
      b.dayProfit += profit;
    } else {
      b.dayLoss += profit;
    }
    return await db.update(BalanceTable.name, b.toMap(),
        where: "${BalanceTable.columnId} = ?", whereArgs: [b.id]);
  }

  Future close() async {
    final db = await DatabaseHelper.instance.database;
    db.close();
  }

  Future<List<BalancePerDay>> getBalancePerDay(int days) async {
    final db = await DatabaseHelper.instance.database;
    var balances = await db.rawQuery(
        "SELECT * FROM ${BalanceTable.name} ORDER BY ${BalanceTable.columnId} DESC LIMIT 7");
    List<BalancePerDay> balancesPerDay = List<BalancePerDay>();

    if (balances.length == 0) {
      var b = await getLast();
      balancesPerDay.add(BalancePerDay(b.date, b.balance));
    } else {
      balancesPerDay = balances
          .map((e) => new BalancePerDay(
              DateTime.parse(e[BalanceTable.columnDate]),
              e[BalanceTable.columnBalance]))
          .toList();
    }

    while (balancesPerDay.length < 7) {
      var last = balancesPerDay[balancesPerDay.length - 1];
      balancesPerDay
          .add(BalancePerDay(last.date.subtract(Duration(days: 1)), 0));
    }

    return balancesPerDay;
  }

  Future updateOnEditBet(double oldValue, double oldProfit, double newValue,
      double newProfit) async {
    final db = await DatabaseHelper.instance.database;
    var b = await getLast();

    //removing values of oldBet
    final oldDifference = (oldValue - oldProfit);
    b.balance += oldDifference;
    b.dayProfit += oldDifference < 0 ? oldDifference : 0;
    b.dayLoss += oldDifference > 0 ? oldDifference : 0;

    //insert values of new bet
    final newDifference = (newProfit - newValue);
    b.balance += newDifference;
    b.dayProfit += newDifference > 0 ? newDifference : 0;
    b.dayLoss += newDifference < 0 ? newDifference : 0;

    b.growthRate = await calculateGrowthRate(b.balance, b.date);

    await db.update(BalanceTable.name, b.toMap(),
        where: "${BalanceTable.columnId} = ?", whereArgs: [b.id]);
  }

  Future<double> calculateGrowthRate(double balance1, DateTime date) async {
    var balanceYesterday = await getByDate(date.subtract(Duration(days: 1)));
    if (balanceYesterday == null) return 0.0;
    double difference = balance1 - balanceYesterday.balance;
    return difference / balanceYesterday.balance;
  }
}
