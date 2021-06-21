import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/lotties/dog_walking.json'),
            // Icon(
            //   Icons.apartment_outlined,
            //   size: MediaQuery.of(context).size.width * 0.785,
            // ),
          ],
        ),
      ),
    );
  }
}
