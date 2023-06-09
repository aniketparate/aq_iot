import 'dart:math';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class CoChartPage extends StatefulWidget {
  final List coData;

  CoChartPage({required this.coData});

  @override
  _CoChartPageState createState() => _CoChartPageState();
}

class _CoChartPageState extends State<CoChartPage> {
  List<charts.Series<double, DateTime>> _seriesData = [];

  @override
  void initState() {
    super.initState();
    // _updateSeriesData();
    _seriesData.add(
      charts.Series<double, DateTime>(
        id: 'CO',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (value, index) => DateTime.now()
            .subtract(Duration(seconds: widget.coData.length - index! - 1)),
        measureFn: (value, _) => value,
        data: widget.coData.map((value) => value as double).toList(),
      ),
    );
  }

  void _onSelectionChanged(charts.SelectionModel model) {
    final selectedDatum = model.selectedDatum;

    if (selectedDatum.isNotEmpty) {
      print(selectedDatum.first.datum);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<double> measureValues = _seriesData
        .expand((series) => series.data.map((data) => data))
        .toList();
    return Scaffold(
        appBar: AppBar(
          title: Text('CO Chart'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_seriesData.isNotEmpty)
                  SizedBox(
                      height: 300,
                      child: Expanded(
                        child: charts.TimeSeriesChart(
                          _seriesData,
                          animate: true,
                          selectionModels: [
                            charts.SelectionModelConfig(
                              type: charts.SelectionModelType.info,
                              changedListener: _onSelectionChanged,
                            )
                          ],
                          dateTimeFactory: const charts.LocalDateTimeFactory(),
                          primaryMeasureAxis: charts.NumericAxisSpec(
                            viewport: charts.NumericExtents(
                                widget.coData.reduce((a, b) => a < b ? a : b) -
                                    5,
                                widget.coData.reduce((a, b) => a > b ? a : b) +
                                    5),
                            tickFormatterSpec:
                                charts.BasicNumericTickFormatterSpec(
                                    (value) => '${value!.toInt()} ppm'),
                          ),
                        ),
                      )),
                Divider(
                  color: Colors.blue,
                  height: 30,
                  thickness: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (measureValues.isNotEmpty)
                      Text(
                        'Latest CO: ${measureValues.last.toStringAsPrecision(3)}',
                        style: const TextStyle(
                          fontSize: 32.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    const Text(
                      'ppm',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Divider(
                      color: Colors.blue,
                      height: 30,
                      thickness: 5,
                    ),
                    Text('Concentration Level'),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: [
                          DataColumn(label: Text('CO (ppm)')),
                          DataColumn(label: Text('AQI')),
                          DataColumn(label: Text('Health Effects')),
                        ],
                        rows: [
                          DataRow(cells: [
                            DataCell(Text('0.0 - 4.4')),
                            DataCell(Text('0 - 50')),
                            DataCell(Text(
                                'Air quality is considered satisfactory.')),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('4.5 - 9.4')),
                            DataCell(Text('51 - 100')),
                            DataCell(Text('Air quality is acceptable.')),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('9.5 - 12.4')),
                            DataCell(Text('101 - 150')),
                            DataCell(Text(
                                'Members of sensitive groups may experience health effects.')),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('12.5 - 15.4')),
                            DataCell(Text('151 - 200')),
                            DataCell(Text(
                                'Everyone may begin to experience health effects.')),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('15.5 - 30.4')),
                            DataCell(Text('201 - 300')),
                            DataCell(Text(
                                'Health warnings of emergency conditions.')),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('30.5+')),
                            DataCell(Text('301+')),
                            DataCell(
                                Text('Health alert: serious health effects')),
                          ]),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
