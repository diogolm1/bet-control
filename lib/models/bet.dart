import 'package:intl/intl.dart';
import 'package:betcontrol/database/tables/betTable.dart';

class Bet {
  int id;
  String name;
  String description;
  DateTime date;
  double odd;
  double value;
  bool win;
  double profit;

  Bet(
      {this.id,
      this.name,
      this.date,
      this.description,
      this.odd,
      this.profit,
      this.value,
      this.win});

  Bet.fromMap(Map map) {
    id = map[BetTable.columnId];
    name = map[BetTable.columnName];
    date = DateTime.parse(map[BetTable.columnDate]);
    description = map[BetTable.columnDescription];
    odd = map[BetTable.columnOdd];
    profit = map[BetTable.columnProfit];
    value = map[BetTable.columnValue];
    win = map[BetTable.columnWin] == 1;
  }

  Map toMap() {
    Map<String, dynamic> map = {
      BetTable.columnName: name,
      BetTable.columnDate: DateFormat("yyyy-MM-dd").format(date.toLocal()),
      BetTable.columnDescription: description,
      BetTable.columnOdd: odd,
      BetTable.columnProfit: profit,
      BetTable.columnValue: value,
      BetTable.columnWin: win,
    };

    if (id != null) {
      map[BetTable.columnId] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Bet(id: $id, name: $name, date: $date, description: $description, odd: $odd, profit: $profit, value: $value, win: $win";
  }
}
