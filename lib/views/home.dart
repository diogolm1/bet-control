import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:google_fonts/google_fonts.dart';
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
    await getBalance();
  }

  createAlertDialog(BuildContext context) async {
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
      body: Column(children: [
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
                                  child: Text("Carregando dados..."),
                                );
                              default:
                                if (snapshot.hasError) {
                                  return Center(
                                    child: Text("Erro ao carregar dados."),
                                  );
                                } else {
                                  if (snapshot.data.growthRate > 0) {
                                    growthRate = "+ ${formatCurrency.format(snapshot.data.growthRate * 100)}%";
                                  } else if (snapshot.data.growthRate < 0) {
                                    growthRate = "- ${formatCurrency.format(snapshot.data.growthRate.abs() * 100)}%";
                                  } else {
                                    growthRate = "";
                                  }
                                  return Expanded(
                                      child: Column(children: [
                                    Container(
                                        child: GestureDetector(
                                      onTap: () {
                                        createAlertDialog(context);
                                      },
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Text("Banca atual:",
                                              style: TextStyle(
                                                  // fontFamily: 'PatuaOne',
                                                  fontSize: 30,
                                                  fontWeight: FontWeight.w900)),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text("R\$ ${formatCurrency.format(snapshot.data.balance)}",
                                                  style: TextStyle(
                                                      // fontFamily: 'PatuaOne',
                                                      fontSize: 30,
                                                      fontWeight: FontWeight.w900)),
                                              Container(
                                                margin: EdgeInsets.only(left: 5),
                                                child: Icon(
                                                  Icons.edit,
                                                  size: 17,
                                                  color: Colors.white,
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    )),
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
                                                        child: Text("Carregando dados..."),
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
                                        child: Container(
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
                                                                    style: TextStyle(
                                                                        fontSize: 23,
                                                                        color: Colors.black,
                                                                        fontWeight: FontWeight.w600),
                                                                  ),
                                                                ),
                                                                Text(
                                                                  "+ ${formatCurrency.format(snapshot.data.dayProfit)}",
                                                                  textAlign: TextAlign.center,
                                                                  style: TextStyle(
                                                                      fontSize: 20, fontWeight: FontWeight.w500),
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
                                                                    style: TextStyle(
                                                                        fontSize: 23,
                                                                        color: Colors.black,
                                                                        fontWeight: FontWeight.w600),
                                                                  ),
                                                                ),
                                                                Text(
                                                                  "- ${formatCurrency.format(snapshot.data.dayLoss.abs())}",
                                                                  textAlign: TextAlign.center,
                                                                  style: TextStyle(
                                                                      fontSize: 20,
                                                                      color: Colors.red,
                                                                      fontWeight: FontWeight.w500),
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
                                                            style: TextStyle(
                                                                fontSize: 23,
                                                                color: Colors.black,
                                                                fontWeight: FontWeight.w600),
                                                          ),
                                                        ),
                                                        Container(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                              Text(
                                                                "${(snapshot.data.dayProfit + snapshot.data.dayLoss) >= 0 ? "+ " + formatCurrency.format(snapshot.data.dayProfit + snapshot.data.dayLoss) : "- " + formatCurrency.format((snapshot.data.dayProfit + snapshot.data.dayLoss).abs())} ",
                                                                textAlign: TextAlign.start,
                                                                style: TextStyle(
                                                                    color: ((snapshot.data.dayProfit +
                                                                                snapshot.data.dayLoss) >=
                                                                            0
                                                                        ? Colors.white
                                                                        : Colors.red),
                                                                    fontSize: 20,
                                                                    fontWeight: FontWeight.w500),
                                                              ),
                                                              Container(
                                                                margin: EdgeInsets.only(top: 5),
                                                                child: Text(
                                                                  growthRate,
                                                                  textAlign: TextAlign.center,
                                                                  style: TextStyle(
                                                                      color: ((snapshot.data.dayProfit +
                                                                                  snapshot.data.dayLoss) >=
                                                                              0
                                                                          ? Colors.white
                                                                          : Colors.red),
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
                                                )))),
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
