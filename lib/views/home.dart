import 'package:flutter/material.dart';
import 'package:learning/models/balance.dart';
import 'package:learning/models/bet.dart';
import 'package:learning/repositories/balanceRepository.dart';
import 'package:learning/repositories/betRepository.dart';
import 'package:learning/views/betPage.dart';
import 'package:learning/widgets/table.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Balance b;

  List<Bet> bets = [];
  int tst = 1;

  Future<List<Bet>> getBets() async {
    var bets = await BetRepository.instance.getAll();
    return bets;
  }

  Future<Balance> getBalance() async {
    b = await BalanceRepository.instance.getLast();
    return b;
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
        var updatedBets = await getBets();
        var balance = await getBalance();
        setState(() {
          bets = updatedBets;
          b = balance;
        });
      } else {
        newBet = await BetRepository.instance.insert(newBet);
        var balance = await getBalance();
        setState(() {
          bets.add(newBet);
          b = balance;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
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
                              Card(
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
                                          child: Text(
                                            "R\$ ${snapshot.data.balance.toStringAsFixed(2)}",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 22),
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Text(
                                  "Resultado do dia: R\$ ${snapshot.data.dayProfit + snapshot.data.dayLoss}",
                                  textAlign: TextAlign.center,
                                ),
                              )
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
                BetTable(onSelectRow: openBetPage),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openBetPage,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
