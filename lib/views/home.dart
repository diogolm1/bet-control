import 'dart:async';
import 'package:betcontrol/widgets/balanceInfo.dart';
import 'package:betcontrol/widgets/dailyResults.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:intl/intl.dart';
import 'package:betcontrol/models/balance.dart';
import 'package:betcontrol/models/balancePerDay.dart';
import 'package:betcontrol/models/bet.dart';
import 'package:betcontrol/repositories/balanceRepository.dart';
import 'package:betcontrol/repositories/betRepository.dart';
import 'package:betcontrol/views/betPage.dart';
import 'package:betcontrol/widgets/balanceLineChart.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:betcontrol/widgets/table.dart';
import 'package:rxdart/rxdart.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Bet> bets = [];
  StreamController<Balance> balanceStream = new BehaviorSubject<Balance>();
  int _currentPage = 0;
  StreamController<List<BalancePerDay>> balancesPerDayStream = BehaviorSubject<List<BalancePerDay>>();
  StreamController<List<Bet>> betsStream = new BehaviorSubject<List<Bet>>();
  String growthRate = "";

  Balance balance;

  @override
  void initState() {
    super.initState();

    getBalance();
    getBalancePerDay(7);
    getBets();
  }

  var formatCurrency = NumberFormat("#,##0.00", "pt");

  Future<Balance> getBalance() async {
    var b = await BalanceRepository.instance.getLast();
    balanceStream.add(b);
    balance = b;
    return b;
  }

  Future<List<Bet>> getBets() async {
    var bets = await BetRepository.instance.getAll();
    betsStream.add(bets);
    return bets;
  }

  Future<List<BalancePerDay>> getBalancePerDay(int days) async {
    var b = await BalanceRepository.instance.getBalancePerDay(days);
    balancesPerDayStream.add(b);
    return b;
  }

  MoneyMaskedTextController _editBalanceCtr = MoneyMaskedTextController(precision: 2);

  Future _editBalance() async {
    await BalanceRepository.instance.updateBalance(_editBalanceCtr.numberValue);
    refreshValues();
  }

  editBalanceDialog(BuildContext context) async {
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
    getBalance();
    getBalancePerDay(7);
    getBets();
  }

  void _deleteBet(int id) async {
    await BetRepository.instance.delete(id);
    refreshValues();
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

  void showOptions({BuildContext context, Bet bet}) async {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            backgroundColor: Color.fromRGBO(53, 51, 51, 1),
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
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _showDialogBet(bet: bet);
                      },
                    ),
                    FlatButton(
                      child: Text(
                        "Excluir",
                        style: TextStyle(color: Colors.white, fontSize: 20),
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

  void _showDialogBet({Bet bet}) async {
    Bet newBet = await showDialog(
        context: context,
        child: new Dialog(
          insetPadding: EdgeInsets.fromLTRB(15, 30, 10, 10),
          child: BetPage(
            bet: bet,
          ),
        ));

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
      backgroundColor: Color.fromRGBO(53, 51, 51, 1),
      body: SingleChildScrollView(
        child: Column(children: [
          Builder(
            builder: (context) {
              final height = MediaQuery.of(context).size.height;
              return CarouselSlider(
                options: CarouselOptions(
                    height: height - 35,
                    viewportFraction: 1.0,
                    enlargeCenterPage: false,
                    enableInfiniteScroll: false,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentPage = index;
                      });
                    }),
                items: [
                  Padding(
                      padding: EdgeInsets.only(top: 45),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          StreamBuilder(
                            stream: balanceStream.stream,
                            builder: (context, snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.none:
                                case ConnectionState.waiting:
                                  return Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Color.fromRGBO(149, 242, 56, 1)),
                                    ),
                                  );
                                default:
                                  if (snapshot.hasError) {
                                    return Center(
                                      child: Text("Erro ao carregar dados."),
                                    );
                                  } else {
                                    return Expanded(
                                        child: Column(children: [
                                      BalanceInfo(
                                        balance: snapshot.data.balance,
                                        editBalance: editBalanceDialog,
                                        formatCurrency: formatCurrency,
                                      ),
                                      Container(
                                          margin: EdgeInsets.only(top: 10, bottom: 30),
                                          child: StreamBuilder(
                                              stream: balancesPerDayStream.stream,
                                              builder: (context, snapshot) {
                                                switch (snapshot.connectionState) {
                                                  case ConnectionState.none:
                                                  case ConnectionState.waiting:
                                                    return SizedBox(
                                                        height: 250,
                                                        child: Center(
                                                          child: CircularProgressIndicator(
                                                            valueColor: AlwaysStoppedAnimation<Color>(
                                                                Color.fromRGBO(149, 242, 56, 1)),
                                                          ),
                                                        ));
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
                                      Expanded(
                                          child: DailyResults(
                                        balance: snapshot.data,
                                        formatCurrency: formatCurrency,
                                      )),
                                    ]));
                                  }
                              }
                            },
                          ),
                        ],
                      )),
                  StreamBuilder(
                      stream: betsStream.stream,
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
                              return BetTable(
                                bets: snapshot.data,
                                showTableOptions: showOptions,
                              );
                            }
                        }
                      })
                ],
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: _currentPage == 0 ? 12.0 : 8.0,
                height: _currentPage == 0 ? 12.0 : 8.0,
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == 0 ? Color.fromRGBO(149, 242, 56, 1) : Colors.grey,
                ),
              ),
              Container(
                width: _currentPage == 1 ? 12.0 : 8.0,
                height: _currentPage == 1 ? 12.0 : 8.0,
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == 1 ? Color.fromRGBO(149, 242, 56, 1) : Colors.grey,
                ),
              )
            ],
          )
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showDialogBet,
        backgroundColor: Color.fromRGBO(149, 242, 56, 1),
        tooltip: 'Cadastrar aposta',
        child: Icon(
          Icons.add,
          color: Colors.black,
          size: 45,
        ),
      ),
    );
  }
}
