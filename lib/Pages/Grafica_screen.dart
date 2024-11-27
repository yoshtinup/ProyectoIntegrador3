import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';

class GraficaScreen extends StatefulWidget {
  const GraficaScreen({Key? key}) : super(key: key);

  @override
  State<GraficaScreen> createState() => _GraficaScreenState();
}

class _GraficaScreenState extends State<GraficaScreen> {
  List<FlSpot> historicalData = [];
  List<FlSpot> forecastData = [];

  @override
  void initState() {
    super.initState();
    loadJsonData();
  }

  Future<void> loadJsonData() async {
    final String response =
        await rootBundle.loadString('assets/prediccion_ventas_diarias.json');
    final data = json.decode(response);

    setState(() {
      historicalData = List<FlSpot>.from(
        data['historical']['dates'].asMap().entries.map(
          (entry) => FlSpot(
            entry.key.toDouble(),
            data['historical']['values'][entry.key],
          ),
        ),
      );
      forecastData = List<FlSpot>.from(
        data['forecast']['dates'].asMap().entries.map((entry) {
          final value = data['forecast']['values'][entry.key];
          if (value != 0.0) {
            return FlSpot(
              (entry.key + data['historical']['dates'].length).toDouble(),
              value,
            );
          }
          return null; // Devuelve null para valores 0.0
        }).where((spot) => spot != null), // Filtra los valores null
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    var sideTitles = SideTitles(
      showTitles: true,
      interval: 10,
      getTitles: (value) {
        return value.toInt().toString();
      },
    );

    var sideTitles2 = SideTitles(
      showTitles: true,
      interval: 10,
      getTitles: (value) {
        return value.toInt().toString();
      },
    );
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black,
              Color(0xFF1A1A1A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Gráfica de Ventas',
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.03),
              Expanded(
                child: historicalData.isEmpty || forecastData.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: LineChart(
                          LineChartData(
                            lineBarsData: [
                              LineChartBarData(
                                spots: historicalData,
                                isCurved: true,
                                colors: [Colors.blue],
                                barWidth: 4,
                                isStrokeCapRound: true,
                                belowBarData: BarAreaData(show: false),
                              ),
                              LineChartBarData(
                                spots: forecastData,
                                isCurved: true,
                                colors: [Colors.green],
                                barWidth: 4,
                                isStrokeCapRound: true,
                                belowBarData: BarAreaData(show: false),
                              ),
                            ],
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: sideTitles,
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: sideTitles2,
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(color: Colors.grey, width: 1),
                            ),
                            gridData: FlGridData(show: true),
                          ),
                        ),
                      ),
              ),
              SizedBox(height: screenHeight * 0.03),
            ],
          ),
        ),
      ),
    );
  }
  
  AxisTitles({required SideTitles sideTitles}) {}
}
