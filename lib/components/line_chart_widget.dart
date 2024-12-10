import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LineChartWidget extends StatelessWidget {
  final Map<String, int> data;
  final String chartTitle;
  const LineChartWidget({super.key, required this.data, required this.chartTitle});

  @override
  Widget build(BuildContext context) {
    // Extract the sorted dates and values from the map
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key)); // Sort by date

    final dates = sortedEntries.map((e) => e.key).toList(); // Extract dates
    final counts = sortedEntries.map((e) => e.value).toList(); // Extract counts
    
    if (kDebugMode) {
      print("Array dates:  $dates");
      print("Array counts: $counts");
    }
   
    
    return Column(
      children: [
        Padding(         
           padding: EdgeInsets.only(bottom: 8.0),
           child: Text(
            chartTitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),),
           ),

        Expanded(child:
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          fontSize: 14),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      int index = value.toInt();
                      if (index >= 0 && index < dates.length) {
                        return Text(
                          dates[index],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                          textAlign: TextAlign.center,
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: const Border(
                  bottom: BorderSide(color: Colors.black, width: 1),
                  left: BorderSide(color: Colors.black, width: 1),
                  right: BorderSide(color: Colors.transparent),
                  top: BorderSide(color: Colors.transparent),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: counts.asMap().entries.map((entry) {
                    return FlSpot(entry.key.toDouble(), entry.value.toDouble());
                  }).toList(),
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.blue.withOpacity(0.2),
                  ),
                ),
              ],
              minX: 0,
              maxX: dates.length.toDouble() - 1,
              minY: 0,
              maxY: counts.isNotEmpty ? counts.reduce((a, b) => a > b ? a : b).toDouble() : 0,
            ),
          ),
        ),
        ),
      ],
    );
  }
}
