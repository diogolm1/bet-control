import 'package:intl/intl.dart';
import 'package:learning/database/database.dart';
import 'package:learning/database/tables/balanceTable.dart';
import 'package:learning/models/balance.dart';

class BalanceRepository {
  static final BalanceRepository instance = BalanceRepository.internal();

  factory BalanceRepository() => instance;

  BalanceRepository.internal();

  Future<Balance> insert(balance) async {
    final db = await DatabaseHelper.instance.database;
    balance.date = DateTime.now();

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
      return Balance.fromMap(result.first);
    } else {
      return await insert(
          Balance(balance: 0, date: DateTime.now(), dayProfit: 0, dayLoss: 0));
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
          date: DateTime.now()));
      return newBalance.id;
    } else {
      b.balance += profit;
      b.dayProfit += profit > 0 ? profit : 0;
      b.dayLoss += profit < 0 ? profit : 0;

      return await db.update(BalanceTable.name, b.toMap(),
          where: "${BalanceTable.columnId} = ?", whereArgs: [b.id]);
    }
  }

  Future close() async {
    final db = await DatabaseHelper.instance.database;
    db.close();
  }
}
