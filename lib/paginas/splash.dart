import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SplashPantalla extends StatelessWidget {
  const SplashPantalla({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Reemplaza el texto con el icono de carga
      ),
    );
  }
}
