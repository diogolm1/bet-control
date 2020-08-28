import 'package:flutter/material.dart';
import 'package:learning/models/bet.dart';

class BetPage extends StatefulWidget {
  final Bet bet;

  BetPage({this.bet});

  @override
  _BetPageState createState() => _BetPageState();
}

enum BetResultType { win, lose, cashout }

class _BetPageState extends State<BetPage> {
  bool _userEdited = false;

  Bet _editedBet;

  final _nameCtr = TextEditingController();
  final _valueCtr = TextEditingController();
  final _oddCtr = TextEditingController();
  final _profitCtr = TextEditingController();
  final _descriptionCtr = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.bet == null) {
      _editedBet = Bet();
    } else {
      _editedBet = Bet.fromMap(widget.bet.toMap());
      _nameCtr.text = _editedBet.name;
      _valueCtr.text = _editedBet.value.toString();
      _oddCtr.text = _editedBet.odd.toString();
      _profitCtr.text = _editedBet.profit.toString();
      _descriptionCtr.text = _editedBet.description;
    }
  }

  void _saveBet() {
    Navigator.pop(context, _editedBet);
  }

  Future<bool> _requestPop() {
    if (_userEdited) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Descartar alterações?"),
              content: Text(
                  "Ao retornar as alterações feitas serão perdidas. Deseja continuar?"),
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
                    Navigator.pop(context);
                  },
                )
              ],
            );
          });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          title:
              Text(_editedBet.name == null ? "Nova Aposta" : "Editar Aposta"),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Container(
              margin: EdgeInsets.fromLTRB(20, 5, 20, 20),
              child: Container(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameCtr,
                      decoration: InputDecoration(labelText: "Nome"),
                      onChanged: (text) {
                        _userEdited = true;
                        setState(() {
                          _editedBet.name = text;
                        });
                      },
                    ),
                    TextFormField(
                      controller: _valueCtr,
                      decoration: InputDecoration(labelText: "Valor"),
                      keyboardType: TextInputType.number,
                      onChanged: (text) {
                        _userEdited = true;
                        setState(() {
                          _editedBet.value = double.parse(text);
                        });
                      },
                    ),
                    TextFormField(
                      controller: _oddCtr,
                      decoration: InputDecoration(labelText: "Odd"),
                      keyboardType: TextInputType.number,
                      onChanged: (text) {
                        _userEdited = true;
                        setState(() {
                          _editedBet.odd = double.parse(text);
                        });
                      },
                    ),
                    TextFormField(
                      controller: _profitCtr,
                      decoration: InputDecoration(labelText: "Retorno obtido"),
                      keyboardType: TextInputType.number,
                      onChanged: (text) {
                        _userEdited = true;
                        setState(() {
                          _editedBet.profit = double.parse(text);
                        });
                      },
                    ),
                    TextFormField(
                      controller: _descriptionCtr,
                      decoration: InputDecoration(labelText: "Descrição"),
                      onChanged: (text) {
                        _userEdited = true;
                        setState(() {
                          _editedBet.description = text;
                        });
                      },
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 1,
                            child: RaisedButton(
                              onPressed: _saveBet,
                              color: Colors.green,
                              textColor: Colors.white,
                              child: Text(
                                "Salvar",
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
