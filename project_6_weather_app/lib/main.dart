import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

const String apiKey = '';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blueGrey,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: WeatherScreen(),
    );
  }
}

class Weather {
  final String cityName;
  final double temperature;
  final String condition;
  final String iconCode;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.condition,
    required this.iconCode,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    final main = json['main'];
    final weather = json['weather'][0];

    double tempInKelvin = main['temp'];
    double tempInCelsius = tempInKelvin - 273.15;

    return Weather(
      cityName: json['name'],
      temperature: tempInCelsius,
      condition: weather['main'],
      iconCode: weather['icon'],
    );
  }

  String get iconUrl => 'http://openweathermap.org/img/wn/$iconCode@4x.png';
}

class ApiService {

  Future<Position> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<Weather> fetchWeather() async {
    try {
      Position position = await _getUserLocation();
      double lat = position.latitude;
      double lon = position.longitude;

      final url =
          'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return Weather.fromJson(json);
      } else {
        throw Exception('Failed to load weather data (Server Error)');
      }
    } catch (e) {
      rethrow;
    }
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Weather> _weatherFuture;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  void _fetchWeather() {
    setState(() {
      _weatherFuture = apiService.fetchWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Real-time Weather'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchWeather,
          ),
        ],
      ),
      body: FutureBuilder<Weather>(
        future: _weatherFuture,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text('Fetching your location and weather...'),
                ],
              ),
            );
          }

          else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Error: ${snapshot.error}\n\n(Have you added permissions and API key?)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red[300]),
                ),
              ),
            );
          }

          else if (snapshot.hasData) {
            final weather = snapshot.data!;

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weather.cityName,
                    style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Image.network(weather.iconUrl),
                  SizedBox(height: 10),
                  Text(
                    '${weather.temperature.toStringAsFixed(1)}°C',
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.w200),
                  ),
                  Text(
                    weather.condition,
                    style: TextStyle(fontSize: 24, color: Colors.grey[400]),
                  ),
                ],
              ),
            );
          }

          else {
            return Center(child: Text('Something went wrong.'));
          }
        },
      ),
    );
  }
}