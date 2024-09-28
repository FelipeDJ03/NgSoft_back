import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:ngcomanda/paginas/inicio.dart';
import 'package:ngcomanda/paginas/login.dart';
import 'package:ngcomanda/paginas/mesero/iniciar_comanda.dart';
import 'package:ngcomanda/paginas/splash.dart';
import 'package:ngcomanda/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'El Parador del Valle',
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),

      
      home: StreamBuilder(
        stream:FirebaseAuth.instance.authStateChanges(),
        builder:(ctx,snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
             return SplashPantalla();
          }
          if(snapshot.hasData){
            return INICIOPantalla();
          }
          return  LOGINPantalla();
        }
      ),
    );
  }
}
