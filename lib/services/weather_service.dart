import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:weather/models/weather_data.dart';

class WeatherService{

  // String city = 'Riyadh';
  //
  // WeatherService ({
  //   this.city
  // });

  //Riyadh default
  late String weatherUrl = 'https://api.openweathermap.org/data/2.5/weather?q=Riyadh&APPID=YOURAPIKEY&units=metric';

  //get data from weather service
  Future<WeatherData> getdata(String? city) async{

    print("بدا لاتصال بالشبكه هنا ");

    weatherUrl = 'https://api.openweathermap.org/data/2.5/weather?q=$city&APPID=YOURAPIKEY&units=metric';

    //http to get
    final response = await http.get(Uri.parse(weatherUrl));

    print("البيانات القادمة من السيرفر: ${response.body}");
    print("${response.statusCode}بدا لاتصال بالشبكه هنا ");

    //check response state
    if(response.statusCode==200){
      //decode json file fromJson
      Map<String,dynamic> jsonData = jsonDecode(response.body);
      return WeatherData.fromJson(jsonData);
    }else{
      throw Exception('Filed to load data! ${response.statusCode}');
    }
  }


  //search city and return list of suggestions
  Future<List<dynamic>> citySuggestions(String text) async{

    if (text.isEmpty) return [];

    late final String searchUrl = 'https://api.openweathermap.org/geo/1.0/direct?q=$text&limit=5&APPID=YOURAPIKEY';

    //http to get
    final response = await http.get(Uri.parse(searchUrl));

    //check response state
    if(response.statusCode==200){
      List <dynamic > suggestions  = jsonDecode(response.body);
      return suggestions;
    }else{
      return [];
    }
  }


}