import 'package:betcontrol/models/balance.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyResults extends StatelessWidget {
  final Balance balance;
  final NumberFormat formatCurrency;

  const DailyResults({Key key, this.balance, this.formatCurrency});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(color: Color.fromRGBO(75, 201, 134, 1)),
        child: Padding(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Diário",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        margin: EdgeInsets.only(right: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.only(bottom: 5),
                              child: Text(
                                "Ganhos",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 23, color: Colors.black, fontWeight: FontWeight.w600),
                              ),
                            ),
                            Text(
                              "+ ${formatCurrency.format(balance.dayProfit)}",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                            ),
                          ],
                        )),
                    Container(
                        margin: EdgeInsets.only(left: 15),
                        child: Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(bottom: 5),
                              child: Text(
                                "Perdas",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 23, color: Colors.black, fontWeight: FontWeight.w600),
                              ),
                            ),
                            Text(
                              "- ${formatCurrency.format(balance.dayLoss.abs())}",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.w500),
                            ),
                          ],
                        )),
                  ],
                ),
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 5),
                      child: Text(
                        "Resultado",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 23, color: Colors.black, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "${(balance.dayProfit + balance.dayLoss) >= 0 ? "+ " + formatCurrency.format(balance.dayProfit + balance.dayLoss) : "- " + formatCurrency.format((balance.dayProfit + balance.dayLoss).abs())} ",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                color: ((balance.dayProfit + balance.dayLoss) >= 0 ? Colors.white : Colors.red),
                                fontSize: 20,
                                fontWeight: FontWeight.w500),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 5),
                            child: Text(
                              "${balance.growthRate >= 0 ? "+ " + formatCurrency.format(balance.growthRate * 100) + "%" : (balance.growthRate < 0) ? "- " + formatCurrency.format(balance.growthRate.abs() * 100) + "%" : ""}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: ((balance.dayProfit + balance.dayLoss) >= 0 ? Colors.white : Colors.red),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            )));
  }
}
