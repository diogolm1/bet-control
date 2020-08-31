import 'package:intl/intl.dart';
import 'package:learning/database/database.dart';
import 'package:learning/database/tables/balanceTable.dart';
import 'package:learning/models/balance.dart';
import 'package:learning/models/balancePerDay.dart';

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
          dayLoss: 0));
    }
  }

  Future<Balance> _returnUpdatedBalance(Balance b) async {
    final today = DateTime.now().toLocal();
    if (b.date.day == today.day &&
        b.date.month == today.month &&
        b.date.year == today.year) {
      return b;
    } else {
      return await insert(
          Balance(balance: b.balance, date: today, dayLoss: 0, dayProfit: 0));
    }
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(BalanceTable.name,
        where: "${BalanceTable.columnId} = ?", whereArgs: [id]);
  }

  Future<int> update(double profit, String date) async {
    final db = await DatabaseHelper.instance.database;
    var b = await getLast();

    if (date != DateFormat('dd/MM/yyyy').format(b.date)) {
      Balance newBalance = await insert(Balance(
          balance: b.balance,
          dayProfit: profit > 0 ? profit : 0,
          dayLoss: profit < 0 ? profit : 0,
          date: DateTime.now().toLocal()));
      return newBalance.id;
    } else {
      b.balance += profit;
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
    return await db.update(BalanceTable.name, b.toMap(),
        where: "${BalanceTable.columnId} = ?", whereArgs: [b.id]);
  }

  Future updateOnDeleteBet(double profit) async {
    final db = await DatabaseHelper.instance.database;
    var b = await getLast();
    b.balance += profit;
    if (profit < 0) {
      b.dayProfit += profit;
    } else {
      b.dayLoss += profit;
    }
    return await db.update(BalanceTable.name, b.toMap());
  }

  Future close() async {
    final db = await DatabaseHelper.instance.database;
    db.close();
  }

  Future<List<BalancePerDay>> getBalancePerDay(int days) async {
    final db = await DatabaseHelper.instance.database;
    var balances = await db.rawQuery(
        "SELECT * FROM ${BalanceTable.name} ORDER BY ${BalanceTable.columnId} DESC LIMIT 8");

    var balancesPerDay = balances
        .map((e) => new BalancePerDay(
            DateTime.parse(e[BalanceTable.columnDate]),
            e[BalanceTable.columnBalance]))
        .toList();

    while (balancesPerDay.length < 7) {
      var last = balancesPerDay[balancesPerDay.length - 1];
      balancesPerDay
          .add(BalancePerDay(last.date.subtract(Duration(days: 1)), 0));
    }

    return balancesPerDay;
  }
}
