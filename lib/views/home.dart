import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:learning/models/axisTheme.dart';
import 'package:learning/models/balance.dart';
import 'package:learning/models/balancePerDay.dart';
import 'package:learning/models/bet.dart';
import 'package:learning/repositories/balanceRepository.dart';
import 'package:learning/repositories/betRepository.dart';
import 'package:learning/views/betPage.dart';
import 'package:learning/widgets/balanceLineChart.dart';
import 'package:learning/widgets/table.dart';
import 'package:charts_flutter/flutter.dart' as charts;

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

  Future<List<BalancePerDay>> getBalancePerDay(int days) async {
    return await BalanceRepository.instance.getBalancePerDay(days);
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
      // appBar: AppBar(
      //   title: Text(widget.title),
      //   centerTitle: true,
      // ),
      backgroundColor: Color.fromRGBO(53, 51, 51, 1),
      body: Padding(
          padding: EdgeInsets.only(top: 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        balance = snapshot.data;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            GestureDetector(
                              onTap: () {
                                createAlertDialog(context);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                      "Banca atual: R\$ ${formatCurrency.format(snapshot.data.balance)}",
                                      style: GoogleFonts.patuaOne(
                                          fontSize: 25,
                                          fontWeight: FontWeight.w500)),
                                  Container(
                                    margin: EdgeInsets.only(left: 5),
                                    child: Icon(
                                      Icons.edit,
                                      size: 17,
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                  }
                },
              ),
              // Expanded(child: Container(child: chartWidget)),
              Container(
                  margin: EdgeInsets.only(top: 15, bottom: 40),
                  child: FutureBuilder(
                      future: getBalancePerDay(7),
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
                              return BalanceLineChart(snapshot.data);
                            }
                        }
                      })),
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
                          return Expanded(
                              child: Container(
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(129, 241, 105, 1)),
                            child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Diário",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 30),
                                    ),
                                    Text(
                                      "Ganhos",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 23, color: Colors.black),
                                    ),
                                    Text(
                                      "+ ${formatCurrency.format(snapshot.data.dayProfit)}",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    Text(
                                      "Perdas",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 23, color: Colors.black),
                                    ),
                                    Text(
                                      "- ${formatCurrency.format(snapshot.data.dayLoss)}",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.red,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    Text(
                                      "Resultado",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 23, color: Colors.black),
                                    ),
                                    Text(
                                      "+ ${formatCurrency.format(snapshot.data.dayProfit - snapshot.data.dayLoss)}",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 20),
                                    )
                                  ],
                                )),
                          ));
                        }
                    }
                  }),

              // Padding(
              //   padding: EdgeInsets.only(top: 20, left: 10),
              //   child: Text("Apostas do dia:"),
              // ),
              // BetTable(onSelectRow: openBetPage, onExcludeRow: refreshValues)
            ],
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: openBetPage,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
