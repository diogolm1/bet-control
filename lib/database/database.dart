import 'package:learning/database/tables/balanceTable.dart';
import 'package:learning/database/tables/betTable.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final _databaseName = "BetControlDB.db";
  static final _databaseVersion = 2;

  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE ${BetTable.name} (${BetTable.columnId} INTEGER PRIMARY KEY"
        ", ${BetTable.columnName} TEXT NOT NULL, ${BetTable.columnDescription} TEXT, ${BetTable.columnDate} TEXT,"
        " ${BetTable.columnOdd} REAL NOT NULL, ${BetTable.columnValue} REAL NOT NULL, ${BetTable.columnWin} INTEGER, "
        "${BetTable.columnProfit} REAL);");
    await db.execute(
        "CREATE TABLE ${BalanceTable.name} (${BalanceTable.columnId} INTEGER PRIMARY KEY"
        ", ${BalanceTable.columnBalance} REAL NOT NULL, ${BalanceTable.columnDate} TEXT NOT NULL"
        ", ${BalanceTable.columnDayProfit} REAL NOT NULL, ${BalanceTable.columnDayLoss} REAL NOT NULL"
        ", ${BalanceTable.columnGrowthRate} REAL NOT NULL)");
  }
}
