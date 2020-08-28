import 'package:learning/database/tables/balanceTable.dart';

class Balance {
  int id;
  double balance;
  DateTime date;
  double dayProfit;
  double dayLoss;

  Balance({this.id, this.balance, this.date, this.dayProfit, this.dayLoss});

  Balance.fromMap(Map map) {
    id = map[BalanceTable.columnId];
    balance = map[BalanceTable.columnBalance];
    date = DateTime.parse(map[BalanceTable.columnDate]);
    dayProfit = map[BalanceTable.columnDayProfit];
    dayLoss = map[BalanceTable.columnDayLoss];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      BalanceTable.columnId: id,
      BalanceTable.columnBalance: balance,
      BalanceTable.columnDate: date.toIso8601String(),
      BalanceTable.columnDayProfit: dayProfit,
      BalanceTable.columnDayLoss: dayLoss
    };

    if (id != null) {
      map[BalanceTable.columnId] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Balance(id: $id, balance: $balance, date: $date, dayProfit: $dayProfit, dayLoss: $dayLoss)";
  }
}
