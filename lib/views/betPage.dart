import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:learning/models/balance.dart';
import 'package:learning/models/bet.dart';

class BetPage extends StatefulWidget {
  final Bet bet;

  BetPage({this.bet});

  @override
  _BetPageState createState() => _BetPageState();
}

typedef callBackBalance = Future<Balance> Function();

class _BetPageState extends State<BetPage> {
  bool _userEdited = false;

  Bet _editedBet;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _nameCtr = TextEditingController();
  final _valueCtr = MoneyMaskedTextController(precision: 2, initialValue: null);
  final _oddCtr = MoneyMaskedTextController(precision: 2, initialValue: null);
  final _profitCtr =
      MoneyMaskedTextController(precision: 2, initialValue: null);
  final _descriptionCtr = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.bet == null) {
      _editedBet = Bet();
    } else {
      _editedBet = Bet.fromMap(widget.bet.toMap());
      _nameCtr.text = _editedBet.name;
      _valueCtr.updateValue(_editedBet.value);
      _oddCtr.updateValue(_editedBet.odd);
      _profitCtr.updateValue(_editedBet.profit);
      _descriptionCtr.text = _editedBet.description;
    }
  }

  void _saveBet() async {
    _editedBet.value = _valueCtr.numberValue;
    _editedBet.odd = _oddCtr.numberValue;
    _editedBet.profit = _profitCtr.numberValue;
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
      child: SingleChildScrollView(
          child: Container(
              margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Container(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 20),
                        child: Text(
                          "Nova aposta",
                          style: TextStyle(
                              color: Color.fromRGBO(75, 201, 134, 1),
                              fontSize: 32,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 13),
                        child: TextFormField(
                          maxLength: 30,
                          controller: _nameCtr,
                          validator: (value) {
                            if (value.isEmpty || value == null) {
                              return "Insira um nome.";
                            }
                          },
                          style: TextStyle(fontSize: 20),
                          decoration: InputDecoration(
                              labelText: "Nome",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(),
                              ),
                              counter: Offstage()),
                          textAlignVertical: TextAlignVertical.bottom,
                          textCapitalization: TextCapitalization.sentences,
                          onChanged: (text) {
                            _userEdited = true;
                            setState(() {
                              _editedBet.name = text;
                            });
                          },
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                                child: Container(
                              margin: EdgeInsets.only(right: 7),
                              child: TextFormField(
                                controller: _valueCtr,
                                validator: (value) {
                                  if (_valueCtr.numberValue == 0) {
                                    return "Valor apostado não pode ser 0.";
                                  }
                                },
                                style: TextStyle(fontSize: 20),
                                decoration: InputDecoration(
                                  labelText: "Valor",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (text) {
                                  _userEdited = true;
                                  setState(() {
                                    _editedBet.value = double.parse(text);
                                  });
                                },
                              ),
                            )),
                            Expanded(
                                child: Container(
                                    margin: EdgeInsets.only(left: 7),
                                    child: TextFormField(
                                      controller: _oddCtr,
                                      validator: (value) {
                                        if (_oddCtr.numberValue == 0) {
                                          return "Odd não pode ser 0.";
                                        }
                                      },
                                      style: TextStyle(fontSize: 20),
                                      decoration: InputDecoration(
                                        labelText: "Odd",
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide(),
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (text) {
                                        _userEdited = true;
                                        setState(() {
                                          _editedBet.odd = double.parse(text);
                                        });
                                      },
                                    ))),
                          ],
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.only(bottom: 20),
                          child: TextFormField(
                            controller: _profitCtr,
                            style: TextStyle(fontSize: 20),
                            decoration: InputDecoration(
                              labelText: "Retorno obtido",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (text) {
                              _userEdited = true;
                              setState(() {
                                _editedBet.profit = double.parse(text);
                              });
                            },
                          )),
                      Container(
                        child: TextFormField(
                          maxLength: 255,
                          controller: _descriptionCtr,
                          style: TextStyle(fontSize: 20),
                          decoration: InputDecoration(
                              labelText: "Descrição (opcional)",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(),
                              ),
                              counter: Offstage()),
                          textCapitalization: TextCapitalization.sentences,
                          onChanged: (text) {
                            _userEdited = true;
                            setState(() {
                              _editedBet.description = text;
                            });
                          },
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 25),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                                height: 50,
                                width: 250,
                                child: RaisedButton(
                                  onPressed: () {
                                    if (_formKey.currentState.validate()) {
                                      _saveBet();
                                    }
                                  },
                                  color: Color.fromRGBO(75, 201, 134, 1),
                                  textColor: Colors.white,
                                  child: Text(
                                    "Salvar",
                                    style: TextStyle(
                                        fontSize: 27,
                                        fontWeight: FontWeight.w800),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ))),
    );
  }
}
