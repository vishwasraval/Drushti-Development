import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import '../main.dart';
import 'home_screen.dart';
class MySplash extends StatefulWidget {
  const MySplash({Key? key}) : super(key: key);

  @override
  _MySplashState createState() => _MySplashState();
}

class _MySplashState extends State<MySplash> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 3,
      navigateAfterSeconds:  HomePage(cameras),
      backgroundColor: Colors.white,
      photoSize: 150,
      loaderColor: Colors.black,
      image: Image.asset('assets/icon.png'),
    );
  }
}
