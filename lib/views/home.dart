import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:intl/intl.dart';
import 'package:learning/models/balance.dart';
import 'package:learning/models/bet.dart';
import 'package:learning/repositories/balanceRepository.dart';
import 'package:learning/repositories/betRepository.dart';
import 'package:learning/views/betPage.dart';
import 'package:learning/widgets/table.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Bet> bets = [];
  Balance balance;

  var formatCurrency = NumberFormat("#,##0.00", "pt");

  Future<List<Bet>> getBets() async {
    var bets = await BetRepository.instance.getAll();
    return bets;
  }

  Future<Balance> getBalance() async {
    var b = await BalanceRepository.instance.getLast();
    balance = b;
    return b;
  }

  MoneyMaskedTextController _editBalanceCtr =
      MoneyMaskedTextController(precision: 2);

  Future _editBalance() async {
    await BalanceRepository.instance.updateBalance(_editBalanceCtr.numberValue);
    var b = await getBalance();
    setState(() {
      balance = b;
    });
  }

  createAlertDialog(BuildContext context) {
    _editBalanceCtr.updateValue(balance.balance);
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Editar banca"),
            content: TextField(
              controller: _editBalanceCtr,
              keyboardType: TextInputType.number,
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancelar"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text("Salvar"),
                onPressed: () {
                  Navigator.pop(context);
                  _editBalance();
                },
              )
            ],
          );
        });
  }

  void refreshValues() async {
    var updatedBets = await getBets();
    var b = await getBalance();
    setState(() {
      bets = updatedBets;
      balance = b;
    });
  }

  void openBetPage({Bet bet}) async {
    Bet newBet = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BetPage(
                  bet: bet,
                )));

    if (newBet != null) {
      if (newBet.id != null) {
        await BetRepository.instance.update(newBet);
      } else {
        await BetRepository.instance.insert(newBet);
      }
      refreshValues();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Padding(
            padding: EdgeInsets.only(top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FutureBuilder(
                  future: getBalance(),
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
                            child: Text("Erro ao carregar dados."),
                          );
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  createAlertDialog(context);
                                },
                                child: Card(
                                  color: Colors.grey,
                                  margin: EdgeInsets.fromLTRB(100, 0, 100, 7),
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                                    child: Column(
                                      children: [
                                        Text(
                                          "Banca atual",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 28),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.only(top: 5),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "R\$ ${formatCurrency.format(snapshot.data.balance)}",
                                                  textAlign: TextAlign.center,
                                                  style:
                                                      TextStyle(fontSize: 22),
                                                ),
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(left: 5),
                                                  child: Icon(
                                                    Icons.edit,
                                                    size: 17,
                                                  ),
                                                )
                                              ],
                                            )),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                  padding: EdgeInsets.only(top: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          flex: 1,
                                          child: Card(
                                            color: Colors.green,
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 15, 0, 15),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    "Ganhos do dia",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.white),
                                                  ),
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 5),
                                                      child: Text(
                                                        "R\$ ${formatCurrency.format(snapshot.data.dayProfit)}",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            color:
                                                                Colors.white),
                                                      )),
                                                ],
                                              ),
                                            ),
                                          )),
                                      Expanded(
                                        flex: 1,
                                        child: Card(
                                          color: Colors.red[300],
                                          child: Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                0, 15, 0, 15),
                                            child: Column(
                                              children: [
                                                Text(
                                                  "Perdas do dia",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.white),
                                                ),
                                                Padding(
                                                    padding:
                                                        EdgeInsets.only(top: 5),
                                                    child: Text(
                                                      "R\$ ${formatCurrency.format(snapshot.data.dayLoss)}",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          color: Colors.white),
                                                    )),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Card(
                                          color: Colors.blue,
                                          child: Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                0, 15, 0, 15),
                                            child: Column(
                                              children: [
                                                Text(
                                                  "Resultado do dia",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.white),
                                                ),
                                                Padding(
                                                    padding:
                                                        EdgeInsets.only(top: 5),
                                                    child: Text(
                                                      "R\$ ${formatCurrency.format(snapshot.data.dayProfit + snapshot.data.dayLoss)}",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          color: Colors.white),
                                                    )),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),

                                      //     Text(
                                      //   "Resultado do dia: R\$ ${snapshot.data.dayProfit + snapshot.data.dayLoss}",
                                      //   textAlign: TextAlign.center,
                                      // ),
                                    ],
                                  ))
                            ],
                          );
                        }
                    }
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20, left: 10),
                  child: Text("Apostas do dia:"),
                ),
                BetTable(onSelectRow: openBetPage, onExcludeRow: refreshValues)
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openBetPage,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
