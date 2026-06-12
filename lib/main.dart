import 'package:flutter/material.dart';
import 'package:weather/screens/splash_screen.dart';

void main() {
  runApp(const HomePage());
}


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      debugShowCheckedModeBanner: false,
      title: 'Weather App',

      builder: (context, child) {
        print(MediaQuery.of(context).size.width);
        return MediaQuery(
          //don't scale text size.
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling,
          ),child: child!,

        );
      },



      home: const SplashScreen(),
    );
  }
}