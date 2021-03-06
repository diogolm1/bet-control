import 'package:intl/intl.dart';
import 'package:betcontrol/database/database.dart';
import 'package:betcontrol/database/tables/betTable.dart';
import 'package:betcontrol/models/bet.dart';
import 'package:betcontrol/repositories/balanceRepository.dart';

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
    await BalanceRepository.instance
        .updateOnInsertBet((bet.profit - bet.value), DateFormat('dd/MM/yyyy').format(bet.date));
    return bet;
  }

  Future<List<Bet>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    var today = DateFormat('yyyy-MM-dd').format(DateTime.now().toLocal());
    var results = await db.query(BetTable.name, where: '${BetTable.columnDate} = ?', whereArgs: [today]);

    var list = results.map((e) => Bet.fromMap(e)).toList();
    return list;
  }

  Future<List<Bet>> getByDate(DateTime date) async {
    final db = await DatabaseHelper.instance.database;
    var dateString = DateFormat('yyyy-MM-dd').format(date);
    var results = await db.query(BetTable.name, where: '${BetTable.columnDate} = ?', whereArgs: [dateString]);

    return results.map((e) => Bet.fromMap(e)).toList();
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

    await db.delete(BetTable.name, where: "${BetTable.columnId} = ?", whereArgs: [id]);

    return id;
  }

  Future<int> update(Bet bet) async {
    final db = await DatabaseHelper.instance.database;

    final oldBet = await getById(bet.id);
    if (bet.profit > bet.value) {
      bet.win = true;
    } else {
      bet.win = false;
    }
    int id = await db.update(BetTable.name, bet.toMap(), where: "${BetTable.columnId} = ?", whereArgs: [bet.id]);

    await BalanceRepository.instance.updateOnEditBet(oldBet.value, oldBet.profit, bet.value, bet.profit);
    return id;
  }

  Future close() async {
    final db = await DatabaseHelper.instance.database;
    db.close();
  }
}
