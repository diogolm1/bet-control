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
    return Container(
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
                  return DataTable(
                    showCheckboxColumn: false,
                    columns: <DataColumn>[
                      DataColumn(
                          label: Text(
                        "Nome",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      )),
                      DataColumn(
                          label: Text(
                        "Valor",
                        style: TextStyle(color: Colors.white),
                      )),
                      DataColumn(
                          label: Text(
                        "Odd",
                        style: TextStyle(color: Colors.white),
                      )),
                      DataColumn(
                          label: Text(
                        "Lucro/Prejuízo",
                        textAlign: TextAlign.start,
                        style: TextStyle(color: Colors.white),
                      ))
                    ],
                    rows: List<DataRow>.from(snapshot.data
                        .map((e) => new DataRow(
                                cells: <DataCell>[
                                  DataCell(Text(e.name)),
                                  DataCell(
                                      Text(formatCurrency.format(e.value))),
                                  DataCell(Text(e.odd.toString())),
                                  DataCell(Text(formatCurrency
                                      .format(e.profit - e.value)))
                                ],
                                onSelectChanged: (bool selected) {
                                  _showOptions(context, e);
                                },
                                color:
                                    MaterialStateProperty.resolveWith((states) {
                                  if ((e.profit - e.value) < 0) {
                                    return Color.fromRGBO(223, 0, 1, 0.4);
                                  } else {
                                    return Color.fromRGBO(0, 210, 14, 0.3);
                                  }
                                })))
                        .toList()),
                  );
                }
            }
          }),
    );
  }
}
