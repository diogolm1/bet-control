import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:learning/models/bet.dart';
import 'package:learning/repositories/betRepository.dart';

class BetTable extends StatefulWidget {
  @override
  BetTableState createState() => BetTableState();

  final selectRowCallback onSelectRow;
  final excludeRowCallback onExcludeRow;

  BetTable({this.onSelectRow, this.onExcludeRow});
}

typedef selectRowCallback = void Function({Bet bet});
typedef excludeRowCallback = void Function();

class BetTableState extends State<BetTable> {
  Future<List<Bet>> getBets() async {
    var bets = await BetRepository.instance.getAll();

    return bets;
  }

  var formatCurrency = NumberFormat("#,##0.00", "pt");

  Future _deleteConfirmation(int id) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Excluir registro?"),
            content: Text("Deseja excluir a aposta?"),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancelar"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text("Sim"),
                onPressed: () {
                  Navigator.pop(context);
                  _deleteBet(id);
                },
              )
            ],
          );
        });
  }

  void _deleteBet(int id) async {
    await BetRepository.instance.delete(id);
    widget.onExcludeRow();
  }

  void _showOptions(BuildContext context, Bet bet) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            onClosing: () {},
            builder: (context) {
              return Container(
                padding: EdgeInsets.all((10)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FlatButton(
                      child: Text(
                        "Editar",
                        style: TextStyle(color: Colors.green, fontSize: 20),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onSelectRow(bet: bet);
                      },
                    ),
                    FlatButton(
                      child: Text(
                        "Excluir",
                        style: TextStyle(color: Colors.green, fontSize: 20),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteConfirmation(bet.id);
                      },
                    )
                  ],
                ),
              );
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 50, bottom: 10),
          child: Text(
            "Histórico de apostas",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
          ),
        ),
        Expanded(
            child: Container(
          decoration: BoxDecoration(color: Color.fromRGBO(75, 201, 134, 1)),
          margin: EdgeInsets.only(top: 20),
          child: FutureBuilder(
              future: getBets(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Center(
                      child: Text("Carregando dados..."),
                    );
                  default:
                    if (snapshot.hasError) {
                      return Center(
                        child: Text("Erro ao carregar dados"),
                      );
                    } else {
                      return Column(children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(75, 201, 134, 1)),
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Color.fromRGBO(
                                                  102, 105, 110, 0.4)))),
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
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w800),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Container(
                                            child: Text(
                                              "Valor",
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w800),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            child: Text(
                                              "Odd",
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w800),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Container(
                                            child: Text(
                                              "Resultado",
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w800),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Column(
                                    children: List<Material>.from(snapshot.data
                                        .map((e) => Material(
                                            color:
                                                Color.fromRGBO(75, 201, 134, 1),
                                            child: InkWell(
                                                splashColor: Colors.grey,
                                                onTap: () {
                                                  _showOptions(context, e);
                                                },
                                                child: Container(
                                                    padding: EdgeInsets.only(
                                                        top: 10),
                                                    decoration: BoxDecoration(
                                                        border: Border(
                                                            bottom: BorderSide(
                                                                color: Color
                                                                    .fromRGBO(
                                                                        102,
                                                                        105,
                                                                        110,
                                                                        0.4)))),
                                                    child: Container(
                                                      margin:
                                                          EdgeInsets.fromLTRB(
                                                              10, 0, 10, 10),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            flex: 3,
                                                            child: Container(
                                                              child: Text(
                                                                e.name,
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        12),
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 3,
                                                            child: Container(
                                                              child: Text(
                                                                formatCurrency
                                                                    .format(e
                                                                        .value),
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 2,
                                                            child: Container(
                                                              child: Text(
                                                                e.odd
                                                                    .toString(),
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        12),
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 3,
                                                            child: Container(
                                                              child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  children: [
                                                                    Container(
                                                                      margin: EdgeInsets.only(
                                                                          right:
                                                                              10),
                                                                      child: Text(
                                                                          formatCurrency.format(e.profit -
                                                                              e.value),
                                                                          style: TextStyle(color: Colors.black)),
                                                                    ),
                                                                    Container(
                                                                        decoration: BoxDecoration(
                                                                            color: Color.fromRGBO(
                                                                                43,
                                                                                43,
                                                                                40,
                                                                                1)),
                                                                        child: ((e.profit - e.value) >=
                                                                                0
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
                                                    )))))))
                              ],
                            ),
                            // child: DataTable(
                            //   showCheckboxColumn: false,
                            //   columns: <DataColumn>[
                            //     DataColumn(
                            //         label: Text(
                            //       "Nome",
                            //       textAlign: TextAlign.center,
                            //       style: TextStyle(
                            //           color: Colors.black,
                            //           fontSize: 15,
                            //           fontWeight: FontWeight.w800),
                            //     )),
                            //     DataColumn(
                            //         label: Text(
                            //       "Valor",
                            //       style: TextStyle(
                            //           color: Colors.black,
                            //           fontSize: 15,
                            //           fontWeight: FontWeight.w800),
                            //     )),
                            //     DataColumn(
                            //         label: Text(
                            //       "Odd",
                            //       style: TextStyle(
                            //           color: Colors.black,
                            //           fontSize: 15,
                            //           fontWeight: FontWeight.w800),
                            //     )),
                            //     DataColumn(
                            //         label: Text(
                            //       "Resultado",
                            //       textAlign: TextAlign.start,
                            //       style: TextStyle(
                            //           color: Colors.black,
                            //           fontSize: 15,
                            //           fontWeight: FontWeight.w800),
                            //     ))
                            //   ],
                            //   rows: List<DataRow>.from(snapshot.data
                            //       .map((e) => new DataRow(
                            //             cells: <DataCell>[
                            //               DataCell(Text(
                            //                 e.name,
                            //                 style:
                            //                     TextStyle(color: Colors.black),
                            //               )),
                            //               DataCell(Text(
                            //                   formatCurrency.format(e.value),
                            //                   style: TextStyle(
                            //                       color: Colors.black))),
                            //               DataCell(Text(e.odd.toString(),
                            //                   style: TextStyle(
                            //                       color: Colors.black))),
                            //               DataCell(Row(
                            //                   mainAxisAlignment:
                            //                       MainAxisAlignment.end,
                            //                   mainAxisSize: MainAxisSize.max,
                            //                   children: [
                            //                     Container(
                            //                       margin: EdgeInsets.only(
                            //                           right: 10),
                            //                       child: Text(
                            //                           formatCurrency.format(
                            //                               e.profit - e.value),
                            //                           style: TextStyle(
                            //                               color: Colors.black)),
                            //                     ),
                            //                     Container(
                            //                         decoration: BoxDecoration(
                            //                             color: Color.fromRGBO(
                            //                                 43, 43, 40, 1)),
                            //                         child: ((e.profit -
                            //                                     e.value) >=
                            //                                 0
                            //                             ? Icon(
                            //                                 Icons.arrow_upward,
                            //                                 color: Colors.green,
                            //                               )
                            //                             : Icon(
                            //                                 Icons
                            //                                     .arrow_downward,
                            //                                 color: Colors.red,
                            //                               )))
                            //                   ]))
                            //             ],
                            //             onSelectChanged: (bool selected) {
                            //               _showOptions(context, e);
                            //             },
                            //           ))
                            //       .toList()),
                            // ),
                          ),
                        )
                      ]);
                    }
                }
              }),
        ))
      ],
    );
  }
}
