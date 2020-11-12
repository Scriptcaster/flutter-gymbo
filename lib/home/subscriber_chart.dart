import 'package:charts_flutter/flutter.dart' as charts;
import 'subscriber_series.dart';
import 'package:flutter/material.dart';

class SubscriberChart extends StatelessWidget {
  final List<SubscriberSeries> data;

  SubscriberChart({@required this.data});

  @override
  Widget build(BuildContext context) {
    List<charts.Series<SubscriberSeries, String>> series = [
      charts.Series(
          id: "Subscribers",
          data: data,
          domainFn: (SubscriberSeries series, _) => series.year,
          measureFn: (SubscriberSeries series, _) => series.subscribers,
          colorFn: (SubscriberSeries series, _) => series.barColor)
    ];

    return Container(
      height: 260,
      padding: EdgeInsets.only(
        left: 0,
        top: 20,
        right: 20,
        bottom: 20,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Text("Weight Lifted", style: Theme.of(context).textTheme.body2),
              Expanded(
                child: charts.BarChart(series, animate: true),
              )
            ],
          ),
        ),
      ),
    );
  }
}
