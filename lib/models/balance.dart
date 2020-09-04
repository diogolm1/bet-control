import 'package:intl/intl.dart';
import 'package:betcontrol/database/tables/balanceTable.dart';

class Balance {
  int id;
  double balance;
  DateTime date;
  double dayProfit;
  double dayLoss;
  double growthRate;

  Balance({this.id, this.balance, this.date, this.dayProfit, this.dayLoss, this.growthRate});

  Balance.fromMap(Map map) {
    id = map[BalanceTable.columnId];
    balance = map[BalanceTable.columnBalance];
    date = DateTime.parse(map[BalanceTable.columnDate]);
    dayProfit = map[BalanceTable.columnDayProfit];
    dayLoss = map[BalanceTable.columnDayLoss];
    growthRate = map[BalanceTable.columnGrowthRate];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      BalanceTable.columnId: id,
      BalanceTable.columnBalance: balance,
      BalanceTable.columnDate: DateFormat("yyyy-MM-dd").format(date.toLocal()),
      BalanceTable.columnDayProfit: dayProfit,
      BalanceTable.columnDayLoss: dayLoss,
      BalanceTable.columnGrowthRate: growthRate
    };

    if (id != null) {
      map[BalanceTable.columnId] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Balance(id: $id, balance: $balance, date: $date, dayProfit: $dayProfit, dayLoss: $dayLoss, growthRate: $growthRate)";
  }
}
