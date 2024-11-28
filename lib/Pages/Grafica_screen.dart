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
  double animationProgress = 0.0;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    loadJsonData();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Future<void> loadJsonData() async {
    try {
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
        animationProgress = 0.0; // Animación comienza en 0
      });

      // Iniciar animación
      animateForecast();
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
        animationProgress = 1.0; // Animación completa
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
                        color: Colors.cyanAccent.withOpacity(0.8), // Color de iluminación
                        blurRadius: 20, // Difuminado
                        spreadRadius: 5, // Extensión del brillo
                        offset: const Offset(0, 0), // Centrado
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
                            duration: const Duration(minutes: 2),
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
                                              (forecastData.length * value)
                                                  .toInt()),
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
                                    border: Border.all(
                                        color: Colors.grey, width: 1),
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
