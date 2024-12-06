import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final _firebase = FirebaseAuth.instance;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Proyecto Integrador',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        scaffoldBackgroundColor: Color(0xFFF5EEC8),
      ),
      home: LOGINPantalla(),
    );
  }
}

class LOGINPantalla extends StatefulWidget {
  const LOGINPantalla({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LOGINPantallaState();
  }
}

class _LOGINPantallaState extends State<LOGINPantalla> with SingleTickerProviderStateMixin {
  final _form = GlobalKey<FormState>();
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _autenticando = false;

  late AnimationController _controller;
  int _currentFrame = 0;
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..addListener(() {
        setState(() {});
      });

    _controller.forward();

    Future.delayed(Duration(milliseconds: 750), () {
      setState(() {
        _currentFrame = 1;
        _controller.duration = Duration(milliseconds: 500);
        _controller.reset();
        _controller.forward();
      });
    });

    ///animacion de la pantalla naranja
    Future.delayed(Duration(milliseconds: 1500), () {
      setState(() {
        _currentFrame = 2;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() async {
  final isValid = _form.currentState!.validate();

  if (!isValid) {
    return;
  }

  _form.currentState!.save();
  try {
    setState(() {
      _autenticando = true;
    });

    final userCredentials = await _firebase.signInWithEmailAndPassword(
      email: _enteredEmail,
      password: _enteredPassword,
    );
    
  } on FirebaseAuthException catch (error) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error.code == 'wrong-password' ? 'Inicio de Sesión Fallido.' : 'Contraseña incorrecta',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        duration: Duration(milliseconds: 1000),
      ),
    );

    setState(() {
      _autenticando = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6), 
      body: Center(
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 500),
          child: _buildFrame(_currentFrame),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
        ),
      ),
    );
  }

  Widget _buildFrame(int frame) {
    switch (frame) {
      case 0:
        return _buildLoadingFrame();
      case 1:
        return _buildGreenFrame();
      case 2:
      default:
        return _buildLoginFrame();
    }
  }

  Widget _buildLoadingFrame() {
    return Container(
      key: ValueKey(0),
      color: Color(0xFF1E56A0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: SizedBox(
              width: 350,
              height: 350,
              child: Image.asset('assets/logo2.png'),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGreenFrame() {
    return Container(
      key: ValueKey(1),
      color: Color(0xFFB1CBE2),
    );
  }

  Widget _buildLoginFrame() {
    return Stack(
      children: [
        Column(
          children: [
            ClipPath(
              clipper: UShapedClipper(),
              child: Container(
                color: Color(0xFF1E56A0),
                height: MediaQuery.of(context).size.height * 0.6,
              ),
            ),
          ],
        ),
        SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 10), 
              Image.asset(
                'assets/logo2.png',
                height: 250,
              ),
              SizedBox(height: 10),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.all(45),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 7,
                      offset: Offset(0, 3), 
                    ),
                  ],
                ),
                child: Form(
                  key: _form,
                  child: Column(
                    children: [
                      Container(
                        child: Text(
                          'Inicia Sesión',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF266DCB),
                          ),
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xFFB1CBE2),
                              width: 3,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Correo Electrónico',
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: Color(0xFF1E56A0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: Color(0xFF1E56A0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: Color(0xFF1E56A0),
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        textCapitalization: TextCapitalization.none,
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty ||
                              !value.contains('@')) {
                            return 'Por favor ingresa un correo electrónico válido.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _enteredEmail = value!;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: Color(0xFF1E56A0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: Color(0xFF1E56A0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: Color(0xFF1E56A0),
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                          ),
                        ),
                        obscureText: !_passwordVisible,
                        validator: (value) {
                          if (value == null || value.trim().length < 6) {
                            return 'La contraseña debe ser mayor a 6 caracteres.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _enteredPassword = value!;
                        },
                      ),
                      SizedBox(height: 35),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.end,
                      //   children: [
                      //     Spacer(),
                      //     TextButton(
                      //       onPressed: () {},
                      //       child: Text(
                      //         '¿Olvidaste tu Contraseña?',
                      //         style: TextStyle(color: Colors.black),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      SizedBox(height: 35),
                      if (_autenticando) const CircularProgressIndicator(),
                      if (!_autenticando)
                        ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF266DCB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 70, vertical: 20),
                          ),
                          child: Text(
                            'Iniciar Sesión',
                            style: TextStyle(
                              fontSize: 18, 
                              color: Colors.white, 
                              fontWeight: FontWeight.bold,
                            ), 
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class UShapedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 100);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 100);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
