import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui'; // <-- Required for BackdropFilter (glass effect)

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      theme: ThemeData.dark(),
      home: const WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final String apiKey = "180b60a53f3248fdbf792931251311";
  Map<String, dynamic>? weatherData;
  bool isLoading = false;
  bool hasSearched = false;
  String city = "Mumbai";
  final TextEditingController _controller = TextEditingController();

  // 🖼 Background Images
  final String winterImage =
      "https://raw.githubusercontent.com/01-elite/Weather-App/main/Winter.jpeg";
  final String summerImage =
      "https://raw.githubusercontent.com/01-elite/Weather-App/main/Summer.jpeg";
  final String monsoonImage =
      "https://raw.githubusercontent.com/01-elite/Weather-App/main/Monsoon.jpeg";
  final String defaultImage =
      "https://raw.githubusercontent.com/01-elite/Weather-App/main/Default.jpeg";

  Future<void> fetchWeather(String searchCity) async {
    setState(() {
      isLoading = true;
      hasSearched = true;
    });

    try {
      final url =
          "https://api.weatherapi.com/v1/current.json?key=$apiKey&q=$searchCity&aqi=no";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          weatherData = json.decode(response.body);
          city = weatherData!['location']['name'];
          isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch weather data");
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching weather: $e")),
      );
    }
  }

  String getWeatherImage() {
    if (!hasSearched) return defaultImage;
    if (weatherData == null) return summerImage;

    final condition = weatherData!['current']['condition']['text'].toLowerCase();

    if (condition.contains("rain") ||
        condition.contains("storm") ||
        condition.contains("drizzle") ||
        condition.contains("thunder")) {
      return monsoonImage;
    } else if (condition.contains("snow") ||
        condition.contains("fog") ||
        condition.contains("mist") ||
        condition.contains("cold")) {
      return winterImage;
    } else {
      return summerImage;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgImage = getWeatherImage();

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(seconds: 1),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(bgImage),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.black.withOpacity(0.4),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 🔍 Search Bar
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: "Search city...",
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            hintStyle: const TextStyle(color: Colors.white70),
                          ),
                          style: const TextStyle(color: Colors.white),
                          onSubmitted: (value) {
                            if (value.isNotEmpty) fetchWeather(value);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () {
                          if (_controller.text.isNotEmpty) {
                            fetchWeather(_controller.text);
                          }
                        },
                        icon: const Icon(Icons.search, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // 🌤 Weather Info
                  Expanded(
                    child: Center(
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : !hasSearched
                          ? const Text(
                        "Search for a city to get the weather 🌤️",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      )
                          : weatherData == null
                          ? const Text(
                        "No data found. Try another city.",
                        style: TextStyle(
                            color: Colors.white, fontSize: 18),
                      )
                          : ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                              sigmaX: 10, sigmaY: 10),
                          child: Container(
                            width: 300,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius:
                              BorderRadius.circular(25),
                              border: Border.all(
                                color: Colors.white
                                    .withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "${weatherData!['location']['name']}, ${weatherData!['location']['country']}",
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "${weatherData!['current']['temp_c']}°C",
                                  style: const TextStyle(
                                    fontSize: 60,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  weatherData!['current']
                                  ['condition']['text'],
                                  style: const TextStyle(
                                    fontSize: 22,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.water_drop,
                                        color: Colors.white70),
                                    Text(
                                      " Humidity: ${weatherData!['current']['humidity']}%",
                                      style: const TextStyle(
                                          color: Colors.white),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.air,
                                        color: Colors.white70),
                                    Text(
                                      " Wind: ${weatherData!['current']['wind_kph']} km/h ${weatherData!['current']['wind_dir']}",
                                      style: const TextStyle(
                                          color: Colors.white),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
