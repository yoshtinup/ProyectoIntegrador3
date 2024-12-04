import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;

class GraficaScreen extends StatefulWidget {
  const GraficaScreen({Key? key}) : super(key: key);

  @override
  State<GraficaScreen> createState() => _GraficaScreenState();
}

class _GraficaScreenState extends State<GraficaScreen> {
  List<FlSpot> historicalData = [];
  List<FlSpot> forecastData = [];
  double animationProgress = 0.0;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    loadJsonData();
  }

  Future<void> loadJsonData() async {
    try {
      // Cambia esta URL por la del endpoint de tu API
      final response = await http.get(Uri.parse('http://127.0.0.1:5002/data'));

      if (response.statusCode == 200) {
        // Decodificar JSON
        final data = json.decode(response.body)['contenido'];

        setState(() {
          // Procesar datos históricos
          historicalData = List<FlSpot>.from(
            data['historical']['dates'].asMap().entries.map(
              (entry) => FlSpot(
                entry.key.toDouble(),
                data['historical']['values'][entry.key],
              ),
            ),
          );

          // Procesar datos de pronóstico
          forecastData = List<FlSpot>.from(
            data['forecast']['dates'].asMap().entries.map((entry) {
              final value = data['forecast']['values'][entry.key];
              return value != null && value != 0.0
                  ? FlSpot(
                      (entry.key + data['historical']['dates'].length).toDouble(),
                      value,
                    )
                  : null;
            }).whereType<FlSpot>(),
          );

          isLoading = false;
          hasError = false;
          animationProgress = 0.0; // La animación comienza en 0
        });

        // Iniciar animación
        animateForecast();
      } else {
        throw Exception('Error al cargar datos: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        historicalData = [FlSpot(0, 0)];
        forecastData = [FlSpot(1, 0)];
      });
    }
  }

  void animateForecast() {
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        animationProgress = 15.0; // Animación completa
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    var bottomTitles = SideTitles(
      showTitles: true,
      interval: 10,
      getTitles: (value) {
        if (value % 10 == 0) return '${value ~/ 10} Meses';
        return '';
      },
      reservedSize: 22,
      margin: 10,
    );

    var leftTitles = SideTitles(
      showTitles: true,
      interval: 10,
      getTitles: (value) => value.toInt().toString(),
      reservedSize: 28,
      margin: 8,
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
          child: Center(
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
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.7,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.cyanAccent, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyanAccent.withOpacity(0.8),
                          blurRadius: 20,
                          spreadRadius: 5,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.cyanAccent,
                            ),
                          )
                        : TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: animationProgress),
                            duration: const Duration(seconds: 100),
                            builder: (context, value, child) {
                              return LineChart(
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
                                      spots: forecastData
                                          .sublist(
                                            0,
                                            ((forecastData.length * value).toInt()).clamp(0, forecastData.length),
                                          ),
                                      isCurved: true,
                                      colors: [Colors.green],
                                      barWidth: 4,
                                      isStrokeCapRound: true,
                                      belowBarData: BarAreaData(show: false),
                                    ),
                                  ],
                                  titlesData: FlTitlesData(
                                    bottomTitles: bottomTitles,
                                    leftTitles: leftTitles,
                                    rightTitles: SideTitles(showTitles: false),
                                    topTitles: SideTitles(showTitles: false),
                                  ),
                                  borderData: FlBorderData(
                                    show: true,
                                    border: Border.all(color: Colors.grey, width: 1),
                                  ),
                                  gridData: FlGridData(show: true),
                                ),
                              );
                            },
                          ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
