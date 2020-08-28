import 'package:flutter/material.dart';
import 'package:learning/models/bet.dart';
import 'package:learning/repositories/betRepository.dart';
import 'package:learning/views/betPage.dart';

class BetTable extends StatefulWidget {
  @override
  BetTableState createState() => BetTableState();

  final selectRowCallback onSelectRow;

  BetTable({this.onSelectRow});
}

typedef selectRowCallback = void Function({Bet bet});

class BetTableState extends State<BetTable> {
  Future<List<Bet>> getBets() async {
    var bets = await BetRepository.instance.getAll();

    return bets;
  }

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
    setState(() {
      getBets();
    });
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
        child: SingleChildScrollView(
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
                          DataColumn(label: Text("Nome")),
                          DataColumn(label: Text("Valor")),
                          DataColumn(label: Text("Odd")),
                          DataColumn(label: Text("Lucro/Prejuízo"))
                        ],
                        rows: List<DataRow>.from(snapshot.data
                            .map((e) => new DataRow(
                                    cells: <DataCell>[
                                      DataCell(Text(e.name)),
                                      DataCell(
                                          Text(e.value.toStringAsFixed(2))),
                                      DataCell(Text(e.odd.toString())),
                                      DataCell(Text((e.profit - e.value)
                                          .toStringAsFixed(2)))
                                    ],
                                    onSelectChanged: (bool selected) {
                                      _showOptions(context, e);
                                    }))
                            .toList()),
                      );
                    }
                }
              }),
          scrollDirection: Axis.horizontal,
        ));
  }
}
