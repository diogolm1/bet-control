import 'package:intl/intl.dart';
import 'package:learning/database/database.dart';
import 'package:learning/database/tables/betTable.dart';
import 'package:learning/models/bet.dart';
import 'package:learning/repositories/balanceRepository.dart';

class BetRepository {
  static final BetRepository instance = BetRepository.internal();

  factory BetRepository() => instance;

  BetRepository.internal();

  Future<Bet> insert(Bet bet) async {
    final db = await DatabaseHelper.instance.database;
    bet.date = DateTime.now().toLocal();
    if (bet.profit > bet.value) {
      bet.win = true;
    } else {
      bet.win = false;
    }
    bet.id = await db.insert(BetTable.name, bet.toMap());
    await BalanceRepository.instance.update(
        (bet.profit - bet.value), DateFormat('dd/MM/yyyy').format(bet.date));
    return bet;
  }

  Future<List<Bet>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    var today = DateFormat('yyyy-MM-dd').format(DateTime.now().toLocal());
    var results = await db.query(BetTable.name,
        where: '${BetTable.columnDate} = ?', whereArgs: [today]);

    var list = results.map((e) => Bet.fromMap(e)).toList();
    return list;
  }

  Future<Bet> getById(int id) async {
    final db = await DatabaseHelper.instance.database;
    var result = await db.query(BetTable.name,
        columns: [
          BetTable.columnId,
          BetTable.columnName,
          BetTable.columnDescription,
          BetTable.columnDate,
          BetTable.columnOdd,
          BetTable.columnValue,
          BetTable.columnProfit,
          BetTable.columnWin
        ],
        where: "${BetTable.columnId} = ?",
        whereArgs: [id]);

    if (result.length > 0) {
      return Bet.fromMap(result.first);
    } else {
      return null;
    }
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.database;
    var bet = await getById(id);

    await BalanceRepository.instance.updateOnDeleteBet(bet.value - bet.profit);

    await db.delete(BetTable.name,
        where: "${BetTable.columnId} = ?", whereArgs: [id]);

    return id;
  }

  Future<int> update(Bet bet) async {
    final db = await DatabaseHelper.instance.database;

    final oldBet = await getById(bet.id);
    double oldProfit = oldBet.profit - oldBet.value;
    if (bet.profit > bet.value) {
      bet.win = true;
    } else {
      bet.win = false;
    }
    int id = await db.update(BetTable.name, bet.toMap(),
        where: "${BetTable.columnId} = ?", whereArgs: [bet.id]);

    await BalanceRepository.instance.update(
        (bet.profit - bet.value) - oldProfit,
        DateFormat('dd/MM/yyyy').format(bet.date));
    return id;
  }

  Future close() async {
    final db = await DatabaseHelper.instance.database;
    db.close();
  }
}
