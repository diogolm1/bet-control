import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BalanceInfo extends StatelessWidget {
  final double balance;
  final Function(BuildContext context) editBalance;
  final NumberFormat formatCurrency;

  const BalanceInfo({Key key, this.balance, this.editBalance, this.formatCurrency});

  @override
  Widget build(BuildContext context) {
    return Container(
        child: GestureDetector(
      onTap: () {
        editBalance(context);
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
              Text("R\$ ${formatCurrency.format(balance)}",
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
    ));
  }
}
