import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // ReceiveSharingIntent.getInitialText().then((value) {
    //   if (value != null) {
    //     print('1');
    //     Navigator.of(context).pushReplacement(MaterialPageRoute(
    //       builder: (context) => MainScreen(value),
    //     ));
    //   }
    // });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: FlutterLogo(
          size: 50,
        ),
      ),
    );
  }
}
