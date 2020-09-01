import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:learning/models/balancePerDay.dart';

class BalanceLineChart extends StatefulWidget {
  @override
  _BalanceLineChartState createState() => _BalanceLineChartState();

  List<BalancePerDay> balancePerDay;

  BalanceLineChart(this.balancePerDay);
}

class _BalanceLineChartState extends State<BalanceLineChart> {
  @override
  Widget build(BuildContext context) {
    var series = [
      new charts.Series<BalancePerDay, DateTime>(
          id: 'balance',
          data: widget.balancePerDay,
          domainFn: (BalancePerDay balanceData, _) => balanceData.date,
          measureFn: (BalancePerDay balanceData, _) => balanceData.balance,
          colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault),
    ];

    var customDomainAxis = new charts.DateTimeAxisSpec(
        renderSpec: charts.GridlineRendererSpec(
            labelStyle:
                charts.TextStyleSpec(color: charts.MaterialPalette.white)),
        tickFormatterSpec: new charts.AutoDateTimeTickFormatterSpec(
            day: new charts.TimeFormatterSpec(
          format: 'dd/MM',
          transitionFormat: 'dd/MM',
        )));

    charts.RenderSpec<num> renderSpecPrimary = AxisTheme.axisThemeNum();

    var chart = new charts.TimeSeriesChart(
      series,
      animate: true,
      domainAxis: customDomainAxis,
      primaryMeasureAxis: charts.NumericAxisSpec(
        tickProviderSpec: charts.BasicNumericTickProviderSpec(
          zeroBound: false,
        ),
        renderSpec: renderSpecPrimary,
      ),
      defaultRenderer: new charts.LineRendererConfig(
        includeLine: true,
        // dashPattern: [30, 60, 90, 120],
        includePoints: true,
        radiusPx: 3,
        strokeWidthPx: 2,
      ),
      behaviors: [
        new charts.ChartTitle("Evolução da banca",
            behaviorPosition: charts.BehaviorPosition.top,
            titleOutsideJustification: charts.OutsideJustification.start,
            titleStyleSpec:
                charts.TextStyleSpec(color: charts.MaterialPalette.white),
            innerPadding: 30),
        new charts.ChartTitle("Banca (R\$)",
            behaviorPosition: charts.BehaviorPosition.start,
            titleOutsideJustification:
                charts.OutsideJustification.middleDrawArea,
            titleStyleSpec:
                charts.TextStyleSpec(color: charts.MaterialPalette.white)),
        new charts.ChartTitle("dia/mês",
            behaviorPosition: charts.BehaviorPosition.bottom,
            titleOutsideJustification: charts.OutsideJustification.endDrawArea,
            titleStyleSpec:
                charts.TextStyleSpec(color: charts.MaterialPalette.white))
      ],
    );

    var chartWidget = new Padding(
      padding: new EdgeInsets.all(10),
      child: new SizedBox(
        height: 250,
        child: chart,
      ),
    );

    return chartWidget;
  }
}

class AxisTheme {
  static charts.RenderSpec<num> axisThemeNum() {
    return charts.GridlineRendererSpec(
      labelStyle: charts.TextStyleSpec(
        color: charts.MaterialPalette.white,
      ),
      lineStyle: charts.LineStyleSpec(
        color: charts.MaterialPalette.white,
      ),
    );
  }

  static charts.RenderSpec<DateTime> axisThemeDateTime() {
    return charts.GridlineRendererSpec(
      labelStyle: charts.TextStyleSpec(
        color: charts.MaterialPalette.white,
      ),
      lineStyle: charts.LineStyleSpec(
        color: charts.MaterialPalette.transparent,
      ),
    );
  }
}
