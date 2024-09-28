import 'package:ngcomanda/widgets/imagen_usuario.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

final _firebase = FirebaseAuth.instance;

class REG_USUARIOPagina extends StatefulWidget {
  final String alias;
  const REG_USUARIOPagina({super.key,required this.alias});

  @override
  State<StatefulWidget> createState() {
    return _REG_USUARIOPaginaState();
  }
}

class _REG_USUARIOPaginaState extends State<REG_USUARIOPagina> {
  final _formKey = GlobalKey<FormState>();
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredConfirmPassword = '';
  var _enteredUsername = '';
  var _enteredLastname = '';
  var _enteredRole = 'mesero';
  var _enteredcel = '';
  var _enteredAddress = '';
  File? _imagenSeleccionada;
  var _autenticando = false;

  void _submit() async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid || _imagenSeleccionada == null) {
      if (_imagenSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se ha agregado una imagen.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black.withOpacity(0.7),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          duration: Duration(milliseconds: 900),
        ),
      );
    }
      return;
    }

    _formKey.currentState!.save();

    if (_enteredPassword != _enteredConfirmPassword) {
      showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        backgroundColor: Colors.transparent,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 40), // Space for the icon
                  Text(
                    'Error',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Las contraseñas no coinciden.',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        child: Text(
                          'Aceptar',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: -30,
              child: Container(
                padding: EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.warning,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
          ],
        ),
      ),
    );

      return;
    }

    try {
      setState(() {
        _autenticando = true;
      });

      final userCredentials = await _firebase.createUserWithEmailAndPassword(
        email: _enteredEmail,
        password: _enteredPassword,
      );

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child('${userCredentials.user!.uid}.jpg');

      await storageRef.putFile(_imagenSeleccionada!);
      final imagenUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userCredentials.user!.uid)
          .set({
        'nombre': _enteredUsername,
        'apellido': _enteredLastname,
        'email': _enteredEmail,
        'rol': _enteredRole,
        'direccion': _enteredAddress,
        'celular': _enteredcel,
        'image_url': imagenUrl,
        'alias':widget.alias
      });

      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          backgroundColor: Colors.transparent,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 40), 
                    Text(
                      'Operación exitosa',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Registro completado exitosamente.',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          child: Text(
                            'Aceptar',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -30,
                child: Container(
                  padding: EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

    } on FirebaseAuthException catch (error) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Error'),
          content: Text(error.message ?? 'Registro fallido.'),
          actions: <Widget>[
            TextButton(
              child: Text('Aceptar'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            )
          ],
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
      backgroundColor: Color.fromARGB(255, 247, 246, 244),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Color(0xFF556B2F),
            elevation: 0,
            title: const Text(
              'Usuarios',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            iconTheme: IconThemeData(
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 40,
          right: 40,
          top: 20,
          bottom: 40,
        ),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ImagenUsuarioPicker(
                  onPickImage: (imagenElegida) {
                    _imagenSeleccionada = imagenElegida;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFffffff),
                    labelText: 'Correo electrónico',
                    labelStyle: TextStyle(
                      color: Colors.black,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFD2691E),
                        width: 1.3,
                      ),
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFD2691E),
                        width: 1.3,
                      ),
                      borderRadius: BorderRadius.circular(18.0),
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
                SizedBox(height: 25),
                TextFormField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFffffff),
                    labelText: 'Nombre de Usuario',
                    labelStyle: TextStyle(
                      color: Colors.black,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFD2691E),
                        width: 1.3,
                      ),
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFD2691E),
                        width: 1.3,
                      ),
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                  enableSuggestions: false,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length < 4) {
                      return 'Por favor introduce al menos 4 caracteres.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _enteredUsername = value!;
                  },
                ),
                SizedBox(height: 25),
                TextFormField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFffffff),
                    labelText: 'Apellidos',
                    labelStyle: TextStyle(
                      color: Colors.black,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFD2691E),
                        width: 1.3,
                      ),
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFD2691E),
                        width: 1.3,
                      ),
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                  enableSuggestions: false,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length < 2) {
                      return 'Por favor introduce al menos 2 caracteres.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _enteredLastname = value!;
                  },
                ),
                SizedBox(height: 25),
                DropdownButtonFormField<String>(
                  value: _enteredRole,
                  items: [
                    DropdownMenuItem(
                      value: 'administrador',
                      child: Text('Administrador'),
                    ),
                    DropdownMenuItem(
                      value: 'mesero',
                      child: Text('Mesero'),
                    ),
                    DropdownMenuItem(
                      value: 'cocinero',
                      child: Text('Cocinero'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _enteredRole = value!;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFffffff),
                    labelText: 'Rol',
                    labelStyle: TextStyle(
                      color: Colors.black,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFD2691E),
                        width: 1.3,
                      ),
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFD2691E),
                        width: 1.3,
                      ),
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor selecciona un rol.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _enteredRole = value!;
                  },
                ),
                SizedBox(height: 25),
                TextFormField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFffffff),
                    labelText: 'Dirección',
                    labelStyle: TextStyle(
                      color: Colors.black,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFD2691E),
                        width: 1.3,
                      ),
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFD2691E),
                        width: 1.3,
                      ),
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                  enableSuggestions: false,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length < 5) {
                      return 'Por favor introduce al menos 5 caracteres.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _enteredAddress = value!;
                  },
                ),
             SizedBox(height: 25),
              TextFormField(
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFFffffff),
                  labelText: 'N° Telefónico',
                  labelStyle: TextStyle(
                    color: Colors.black,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFFD2691E),
                      width: 1.3,
                    ),
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFFD2691E),
                      width: 1.3,
                    ),
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                ),
                enableSuggestions: false,
                validator: (value) {
                  if (value == null || value.isEmpty || value.trim().length < 10) {
                    return 'Por favor introduce el número telefonico';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredcel = value!;
                },
              ),
                SizedBox(height: 25),
                TextFormField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFffffff),
                    labelText: 'Contraseña',
                    labelStyle: TextStyle(
                      color: Colors.black,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFD2691E),
                        width: 1.3,
                      ),
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFD2691E),
                        width: 1.3,
                      ),
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                  obscureText: true,
                  validator: (value) {
                   if (value == null || value.trim().isEmpty) {
                      return 'La contraseña no puede estar vacía.';
                    }

                    // Verificar que tenga al menos 8 caracteres
                    if (value.trim().length < 8) {
                      return 'La contraseña debe tener al menos 8 caracteres.';
                    }

                    // Verificar que contenga al menos una mayúscula
                    if (!value.contains(RegExp(r'[A-Z]'))) {
                      return 'La contraseña debe contener al menos una letra mayúscula.';
                    }

                    // Verificar que contenga al menos una minúscula
                    if (!value.contains(RegExp(r'[a-z]'))) {
                      return 'La contraseña debe contener al menos una letra minúscula.';
                    }

                    // Verificar que contenga al menos un carácter especial
                    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                      return 'La contraseña debe contener al menos un carácter especial.';
                    }

                    // Si pasa todas las validaciones, retornar null
                    return null;
                  },
                  onSaved: (value) {
                    _enteredPassword = value!;
                  },
                ),
                SizedBox(height: 25),
                TextFormField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFffffff),
                    labelText: 'Confirmar Contraseña',
                    labelStyle: TextStyle(
                      color: Colors.black,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFD2691E),
                        width: 1.3,
                      ),
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFD2691E),
                        width: 1.3,
                      ),
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().length < 8) {
                      return 'La confirmación de la contraseña debe tener al menos 8 caracteres.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _enteredConfirmPassword = value!;
                  },
                ),
                const SizedBox(height: 25),
                if (_autenticando)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 50,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      backgroundColor: Color(0xFFFFA500),
                    ),
                    child: const Text(
                        'Registrar',
                        style: TextStyle(
                        fontSize: 17, 
                        color: Colors.white, 
                        fontWeight: FontWeight.bold,
                      ), 
                    ),
                    
                  ),
                  SizedBox(height: 15,),
                  TextButton(
                            onPressed: () => _mostrarAvisoPrivacidad(context),
                            child: Text(
                              'Politicas de privacidad',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _mostrarAvisoPrivacidad(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aviso de Privacidad y Seguridad de Datos',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.0),
                Text(
                  'Tu privacidad es muy importante para nosotros. Este aviso de privacidad explica cómo recopilamos, usamos, divulgamos y protegemos tu información personal.',
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 10.0),
                Text(
                  '1. Recolección de Información: Recopilamos información que nos proporcionas directamente, como tu nombre, dirección de correo electrónico y cualquier otra información que decidas compartir con nosotros.',
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 10.0),
                Text(
                  '2. Uso de la Información: Utilizamos la información que recopilamos para proporcionarte nuestros servicios, mejorar nuestra plataforma y comunicarnos contigo.',
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 10.0),
                Text(
                  '3. Divulgación de Información: No compartimos tu información personal con terceros, excepto según lo permitido por la ley o con tu consentimiento expreso.',
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 10.0),
                Text(
                  '4. Seguridad de los Datos: Implementamos medidas de seguridad adecuadas para proteger tu información personal contra accesos no autorizados, alteraciones y destrucción.',
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 10.0),
                Text(
                  '5. Cambios a este Aviso: Podemos actualizar este aviso de privacidad periódicamente. Te notificaremos sobre cualquier cambio publicando el nuevo aviso en nuestra plataforma.',
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 10.0),
                Text(
                  'Si tienes alguna pregunta o inquietud acerca de nuestra política de privacidad, no dudes en contactarnos.',
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 20.0),
                Center(
                  child: 
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 50,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      backgroundColor: Color(0xFFFFA500),
                    ),
                    child: const Text(
                        'Cerrar',
                        style: TextStyle(
                        fontSize: 17, 
                        color: Colors.white, 
                        fontWeight: FontWeight.bold,
                      ), 
                    ),            
                  ),                
                ),
                SizedBox(height: 10.0),
              ],
            ),
          ),
        );
      },
    );
  }