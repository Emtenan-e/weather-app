import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:weather/models/weather_data.dart';
import 'package:flutter_weather_bg/flutter_weather_bg.dart';
import 'package:weather_icons/weather_icons.dart';
import '../services/weather_service.dart';
// SocketException
import 'dart:io';

class WeatherPage extends StatefulWidget{


  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {

  String city = "Riyadh";

  late  Future<WeatherData> _weatherFuture;
  final WeatherService _weatherService = WeatherService();

  List <dynamic> listSuggestions =[];

  WeatherType _currentWeather = WeatherType.thunder;
  IconData? _icon ;

  final Map<String, (WeatherType, IconData)> _weatherMapping = {
    '01d': (WeatherType.sunny, WeatherIcons.day_sunny),
    '01n': (WeatherType.sunnyNight, WeatherIcons.night_clear),
    '02d': (WeatherType.cloudy, WeatherIcons.day_cloudy),
    '02n': (WeatherType.cloudyNight, WeatherIcons.night_cloudy),
    '03d': (WeatherType.cloudy, WeatherIcons.day_cloudy_windy),
    '03n': (WeatherType.cloudyNight, WeatherIcons.night_cloudy_windy),
    '04d': (WeatherType.cloudy,WeatherIcons.day_cloudy_high),
    '04n': (WeatherType.cloudyNight, WeatherIcons.night_cloudy_high),
    '09d': (WeatherType.lightRainy, WeatherIcons.raindrop),
    '14d': (WeatherType.middleRainy, WeatherIcons.raindrops),
    '11d': (WeatherType.thunder, WeatherIcons.thunderstorm),
    '13d': (WeatherType.lightSnow, WeatherIcons.snow),
    '50d': (WeatherType.foggy, WeatherIcons.fog),
  };

  String? feelsDescription ;

  TextEditingController  searchController =TextEditingController();

  @override
  void initState() {
    super.initState();
    _weatherFuture =  WeatherService().getdata(city);
  }

  void _refreshPage() {
    setState(() {
      _weatherFuture = WeatherService().getdata(city);
    });
  }

  
  
  @override
  Widget build(BuildContext context) {

    // Get screen dimensions to ensure background scales perfectly
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: FutureBuilder(
            future: _weatherFuture,
            builder: (context,snapshot){

              debugPrint("حالة الـ Future الحالية: ${snapshot.connectionState}");

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if(snapshot.hasError){
                if(snapshot.error is SocketException){
                  return Center(
                    child: Column(
                      children: [
                        Text("Something went wrong! check WIFI",
                        style: TextStyle(fontSize: 14),),
                        TextButton(onPressed: _refreshPage,
                            child: Text("Refresh!",style: TextStyle(color: Colors.blue),))
                      ],
                    ),
                  );
                }

              }

              if(snapshot.hasData){

                WeatherData weatherData = snapshot.data! ;

                _getBackground(weatherData.description,weatherData.icon);
                _getFeelsDescription(weatherData.feelsLike!,weatherData.temp!);

                //snapshot here is the obj
                return GestureDetector(
                  onTap: (){
                    FocusScope.of(context).unfocus();
                    searchController.clear();
                  },
                  child: Stack(
                    children:[
                      //background
                      WeatherBg(
                        weatherType: _currentWeather,
                        width: screenWidth,
                        height: screenHeight,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        //text to search city field
                        children: [
                          SizedBox(height: 30,),
                          Container(
                            margin: EdgeInsets.all(14),
                            child: TextField(
                              controller: searchController,
                              onSubmitted: (String value) async{

                                if (value.trim().isEmpty) return;

                                var list = await _weatherService.citySuggestions(value);

                                if(list.isEmpty){
                                  //clear the previous list
                                  setState(() {
                                    listSuggestions.clear();
                                    searchController.clear();
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text("City not found !"),
                                      duration: Duration(seconds: 2)
                                  )
                                  );

                                }else{
                                  //get first chose
                                  city = list[0]['name'];
                                  searchController.clear();

                                  setState(() {
                                    listSuggestions.clear();
                                    _weatherFuture = WeatherService().getdata(city);
                                    _refreshPage();
                                  });
                                }


                              },
                              onChanged: (String value) async {

                                //clear the list if no text
                                if (value.trim().isEmpty) {
                                  setState(() {
                                    listSuggestions.clear();
                                  });
                                  return;
                                }
                                //get list of exist city
                                var list = await _weatherService.citySuggestions(value);
                                setState(() {
                                  listSuggestions = list ;
                                });
                              },
                              style: TextStyle(color: Colors.white,),
                              decoration: InputDecoration(
                                isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 5,   // 👈 كلما قللتِ هذا الرقم، قلّ ارتفاع الـ TextField
                                    horizontal: 15, // المسافة الجانبية للنص
                                  ),

                                prefixIconColor: Colors.white,
                                label: Text('Search'),
                                labelStyle: TextStyle(color: Colors.white),
                                prefixIcon: Icon(Icons.search_rounded,),

                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.white,
                                  )
                                ),

                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.8),
                                    width: 1.0,
                                  )
                                )

                              ),
                            ),
                          ),

                          //show list of Suggestions .
                          if (listSuggestions.isNotEmpty)Container(

                            constraints: const BoxConstraints(maxHeight: 160),
                            margin: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.6), // خلفية داكنة شفافة لتبدو مودرن وفوق المتحركة
                              borderRadius: BorderRadius.circular(14),
                            ),

                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: listSuggestions.length,
                              itemBuilder:(context,index){
                                final item = listSuggestions[index];
                                return ListTile(
                                  tileColor: Colors.white ,
                                  title: Text("${item['name']}"),
                                  onTap: (){

                                    //show the data of selected city
                                    city = item['name'];
                                    searchController.clear();
                                    setState(() {
                                      listSuggestions.clear(); // إغلاق القائمة فوراً عند الاختيار
                                      _weatherFuture = WeatherService().getdata(city);
                                      _refreshPage();
                                    });

                                  },
                                );
                              },
                            ),
                          ),

                          //WEATHER DATA
                          SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                children: [
                                  Row(
                                    //all to the same line
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    //all to the center
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("$city",
                                        style: TextStyle(fontSize: 30,color: Colors.white),),
                                      Text("${weatherData.country}",
                                        style: TextStyle(fontSize: 11,color: Colors.white.withOpacity(0.4)),),
                                    ],
                                  ),
                                  //weather icon
                                  BoxedIcon(
                                    //if icon is null
                                    _icon ?? WeatherIcons.na,
                                    size: 50,
                                    color: Colors.white,
                                  ),

                                  //temp and description
                                  Text("${weatherData.temp}°",style: TextStyle(fontSize: 50, color: Colors.white)),
                                  Text("${weatherData.description}",style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.4))),

                                  //low height temp
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("H:${weatherData.max}°",style: TextStyle(fontSize: 14,color: Colors.white)),
                                      SizedBox(width: 20,),
                                      Text("L:${weatherData.min}°",style: TextStyle(fontSize: 14,color: Colors.white)),
                                    ],
                                  ),

                                  SizedBox(height: 20,),

                                  //get wind data details
                                  Container(
                                    width: screenWidth,
                                    padding: EdgeInsets.only(left: 14,right: 14,top: 14,bottom: 7),
                                    margin: EdgeInsets.all(14),
                                    decoration: BoxDecoration(

                                      borderRadius: BorderRadius.circular(20.0),
                                      color: Colors.black.withOpacity(0.2),

                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,                              children: [
                                      Expanded(
                                        flex: 2,

                                        //wind details
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                BoxedIcon(
                                                  WeatherIcons.strong_wind,
                                                  size: 13,
                                                  color: Colors.white.withOpacity(0.4),
                                                ),
                                                SizedBox(width: 14,),
                                                Text("WIND",style: TextStyle(fontSize: 13,color: Colors.white.withOpacity(0.4))),
                                              ],
                                            ),
                                            SizedBox(height: 14,),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text("Wind",style: TextStyle(fontSize: 13,color: Colors.white.withOpacity(0.6))),
                                                Text("${weatherData.wind} km/h",style: TextStyle(fontSize: 13,color: Colors.white))
                                              ],
                                            ),
                                            Divider(
                                              thickness: 1,
                                              color: Colors.white.withOpacity(0.3),                                        indent: 14,
                                              endIndent: 14,
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text("Gusts",style: TextStyle(fontSize: 13,color: Colors.white.withOpacity(0.6))),
                                                Text("${weatherData.gusts} km/h",style: TextStyle(fontSize: 13,color: Colors.white))
                                              ],
                                            ),
                                            Divider(
                                              thickness: 1,
                                              color: Colors.white.withOpacity(0.3),
                                              indent: 14,
                                              endIndent: 14,
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text("Direction",style: TextStyle(fontSize: 13,color: Colors.white.withOpacity(0.6))),
                                                Text("${weatherData.direction}°",style: TextStyle(fontSize: 13,color: Colors.white))

                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      //wind direction icon
                                      Expanded(
                                        flex: 1,
                                        child: Center(
                                          child: Transform.rotate(
                                            //wind direction icon is rotated depend on direction value
                                            //convert degree to angle:
                                            angle: (weatherData.direction ?? 0) * (math.pi / 180),
                                            child: BoxedIcon(
                                              //if icon is null
                                              WeatherIcons.wind_direction,
                                              size: 85,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),

                                    ],
                                    ),
                                  ),
                                  //Feels like and humidity details
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      //feelsLike
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          height: 120,

                                          padding: EdgeInsets.only(left: 14,right: 14,top: 14,bottom: 14),
                                          margin: EdgeInsets.only(left: 14,right: 5),
                                          decoration: BoxDecoration(

                                            borderRadius: BorderRadius.circular(20.0),
                                            color: Colors.black.withOpacity(0.2),

                                          ),

                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  BoxedIcon(
                                                    WeatherIcons.thermometer,
                                                    size: 13,
                                                    color: Colors.white.withOpacity(0.4),
                                                  ),
                                                  SizedBox(width: 14,),
                                                  Text("FEELS LIKE",style: TextStyle(fontSize: 13,color: Colors.white.withOpacity(0.4))),
                                                ],
                                              ),
                                              Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left:9),
                                                  child: Text("${weatherData.feelsLike}°",style: TextStyle(fontSize: 14,color: Colors.white),),
                                                ),
                                              ),
                                              Text("$feelsDescription",style: TextStyle(fontSize: 10,color: Colors.white),),

                                            ],
                                          ),
                                        ),
                                      ),

                                      //humidity and pressure details
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          height: 120,
                                          width: screenWidth,
                                          padding: EdgeInsets.only(left: 14,right: 14,top: 14,bottom: 14),
                                          margin: EdgeInsets.only(right: 14,left: 5),
                                          decoration: BoxDecoration(

                                            borderRadius: BorderRadius.circular(20.0),
                                            color: Colors.black.withOpacity(0.2),

                                          ),

                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("HUMIDITY",style: TextStyle(fontSize: 13,color: Colors.white.withOpacity(0.4))),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  BoxedIcon(
                                                    WeatherIcons.humidity,
                                                    size: 13,
                                                    color: Colors.white.withOpacity(0.4),
                                                  ),
                                                  SizedBox(width: 8,),
                                                  Text("${weatherData.humidity}%",
                                                    style: TextStyle(fontSize: 14,color: Colors.white),),

                                                ],
                                              ),
                                              SizedBox(height: 8,),
                                              Text("PRESSURE",style: TextStyle(fontSize: 13,color: Colors.white.withOpacity(0.4))),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Icon(
                                                    Icons.speed,
                                                    size: 15,
                                                    color: Colors.white.withOpacity(0.4),
                                                  ),
                                                  SizedBox(width: 8,),
                                                  Text("${weatherData.pressure} hPa",
                                                    style: TextStyle(fontSize: 14,color: Colors.white),),

                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              )
                          )


                        ],
                      ),
                    ]
                  ),
                );

              }

              return Center(child:Text("No data !"));

            }),
      ),
    );
  }

  void _getBackground(String? description, String? icon) {
    //searching the map if not found default values are after the question mark.
    final result = _weatherMapping[icon] ?? (WeatherType.sunny, Icons.sunny);

    _currentWeather = result.$1;
    _icon = result.$2;
  }

  void _getFeelsDescription(int feelsLike, int temp) {
    
    if (feelsLike > temp) {
      feelsDescription = "The perceived temperature is higher than the actual temperature due to humidity.";
    } else if (feelsLike < temp) {
      feelsDescription = "Colder than the actual temperature due to wind activity.";
    } else {
      feelsDescription = "The sensation of heat is exactly the same as the actual temperature.";
    }
  }



}