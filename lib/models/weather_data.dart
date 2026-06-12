class WeatherData {
  int? temp;
  int? max;
  int? min;
  int? wind;
  int? gusts;
  int? direction;
  int? feelsLike;
  int? pressure;
  int? humidity;
  String? description;
  String? icon ;
  String? city ;
  String? country ;


  WeatherData ({
    this.temp,
    this.max,
    this.min,
    this.wind,
    this.gusts,
    this.direction,
    this.feelsLike,
    this.pressure,
    this.humidity,
    this.description,
    this.icon,
    this.city,
    this.country

  });

  //get data from json
  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      // in case we receive int tell dart to use toDouble()
        temp: (json['main']['temp'] as num) .round(),
        min: (json['main']['temp_min'] as num ).round(),
        max: (json['main']['temp_max']as num ) .round(),

        wind: ((json['wind']['speed']as num ).toDouble()*3.6).round(),
        gusts: ((json['wind']['gust']as num ).toDouble()*3.6).round(),
        direction: (json['wind']['deg'] as int ),

        feelsLike: ((json['main']['feels_like']as num ) ).round(),
        pressure: json['main']['pressure'] as int ,
        humidity: json['main']['humidity'] as int ,
        description: json['weather'][0]['main']as String,
        icon: json['weather'][0]['icon']as String,

        city: json['name'] as String,
        country: json['sys']['country']as String
    );
  }

}