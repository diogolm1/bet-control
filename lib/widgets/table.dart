import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:betcontrol/models/bet.dart';

typedef showOptions = void Function({Bet bet, BuildContext context});

class BetTable extends StatelessWidget {
  final showOptions showTableOptions;
  final List<Bet> bets;
  final formatCurrency = NumberFormat("#,##0.00", "pt");

  BetTable({this.bets, this.showTableOptions});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 50, bottom: 10),
          child: const Text(
            "Histórico de apostas",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
          ),
        ),
        Expanded(
            child: Container(
          decoration: BoxDecoration(color: Color.fromRGBO(75, 201, 134, 1)),
          margin: EdgeInsets.only(top: 20),
          child: Column(children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: Color.fromRGBO(75, 201, 134, 1)),
                child: SingleChildScrollView(
                    // controller: scrollController,
                    child: Column(
                  children: [
                    Container(
                      decoration:
                          BoxDecoration(border: Border(bottom: BorderSide(color: Color.fromRGBO(102, 105, 110, 0.4)))),
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 15, 10, 15),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                child: Text(
                                  "Nome",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Container(
                                child: Text(
                                  "Valor",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                child: Text(
                                  "Odd",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Container(
                                child: Text(
                                  "Resultado",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w800),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Column(
                        children: List<Material>.from(bets.map((e) => Material(
                            color: Color.fromRGBO(75, 201, 134, 1),
                            child: InkWell(
                                splashColor: Colors.grey,
                                onTap: () {
                                  showTableOptions(context: context, bet: e);
                                },
                                child: Container(
                                    padding: EdgeInsets.only(top: 10),
                                    decoration: BoxDecoration(
                                        border: Border(bottom: BorderSide(color: Color.fromRGBO(102, 105, 110, 0.4)))),
                                    child: Container(
                                      margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: Container(
                                              child: Text(
                                                e.name,
                                                textAlign: TextAlign.start,
                                                style: TextStyle(color: Colors.black, fontSize: 12),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Container(
                                              child: Text(
                                                formatCurrency.format(e.value),
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              child: Text(
                                                e.odd.toString(),
                                                textAlign: TextAlign.start,
                                                style: TextStyle(color: Colors.black, fontSize: 12),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Container(
                                              child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  mainAxisSize: MainAxisSize.max,
                                                  children: [
                                                    Container(
                                                      margin: EdgeInsets.only(right: 10),
                                                      child: Text(formatCurrency.format(e.profit - e.value),
                                                          style: TextStyle(color: Colors.black)),
                                                    ),
                                                    Container(
                                                        decoration: BoxDecoration(color: Color.fromRGBO(43, 43, 40, 1)),
                                                        child: ((e.profit - e.value) >= 0
                                                            ? Icon(
                                                                Icons.arrow_upward,
                                                                color: Colors.green,
                                                              )
                                                            : Icon(
                                                                Icons.arrow_downward,
                                                                color: Colors.red,
                                                              )))
                                                  ]),
                                            ),
                                          )
                                        ],
                                      ),
                                    ))))))),
                  ],
                )),
              ),
            )
          ]),
        ))
      ],
    );
  }
}
