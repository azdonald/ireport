import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';

import 'package:ireport/map.dart';


class SplashScreen extends StatefulWidget{
  @override
  SplashScreenState createState() => new SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>{
  static var imageList = ['keke.png', 'lekki.png', 'road.png'];

  final _randomItem = new Random();
  var image;
  Position currentLocation;
  double latitude;
  double longitude;


  @override
  void initState(){
    image = imageList[_randomItem.nextInt(imageList.length)];
    super.initState();
    getUserLocation();
  }


  void navigateToHome(){
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => new MapApp(latitude: this.latitude, longitude: this.longitude,) ));
  }

  Future<Position> locateUser() {
    return Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  getUserLocation() async {
    currentLocation = await locateUser();
    if (currentLocation !=null) {
      this.latitude = currentLocation.latitude;
      this.longitude = currentLocation.longitude;
      navigateToHome();
    }


  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return (new WillPopScope(
        onWillPop: null,
      child: new Scaffold(
        body: new Container(
          decoration: new BoxDecoration(
            image: new DecorationImage(
                image: new AssetImage('assets/'+image),
              fit: BoxFit.cover
            )
          ),
          child: new Container(
            decoration: new BoxDecoration(
                gradient: new LinearGradient(
                    colors: <Color>[
                      const Color.fromRGBO(192, 100, 129, 0.8),
                      const Color.fromRGBO(51, 51, 63, 0.9)
                    ],
                    stops: [0.2,1.0],
                    begin: const FractionalOffset(0.0, 0.0),
                    end: const FractionalOffset(0.0, 1.0)
                )
            ),
          ),
        ),
      ),
      )
    );
  }
}