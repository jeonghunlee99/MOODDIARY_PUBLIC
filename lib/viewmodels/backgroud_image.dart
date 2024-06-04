class BackgroundImageViewModel {
  String getBackgroundImage(String weatherCondition) {

    switch (weatherCondition) {
      case 'Clear':
        return 'assets/weather_pics/clear.png';
      case 'Clouds':
        return 'assets/weather_pics/cloud.png';
      case 'Rain':
        return 'assets/weather_pics/rain.png';
      case 'Snow':
        return 'assets/weather_pics/snow.png';
      case 'Thunderstorm':
        return 'assets/weather_pics/thunderstorm.png';
        default:
        return 'assets/weather_pics/winter1.png';
    }
  }

}
