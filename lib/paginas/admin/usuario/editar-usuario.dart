import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../widgets/imagen_usuario.dart';
import 'usuario-service.dart';

class EditarUsuario extends StatefulWidget {
  final String userId;
 
  const EditarUsuario({super.key, required this.userId});

  @override
  _EditarUsuarioState createState() => _EditarUsuarioState();
}

class _EditarUsuarioState extends State<EditarUsuario> {
  TextEditingController nameController = TextEditingController();
  TextEditingController apellidoController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController celController = TextEditingController();
  File? _imagenSeleccionada;
  String? _imagenUrl;
  var _enteredRole = 'mesero';

  @override
  void initState() {
    super.initState();
    obtenerDetalleUsuario();
  }

  Future<void> obtenerDetalleUsuario() async {
    Map<String, dynamic>? usuario = await DatabaseMethods().obtenerDetalleUsuario(widget.userId);
    if (usuario != null) {
      setState(() {
        nameController.text = usuario['nombre'];
        apellidoController.text = usuario['apellido'];
        locationController.text = usuario['direccion'];
        celController.text = usuario['celular'];
        _imagenUrl = usuario['image_url'];
      });
    }
  }

  Future<void> actualizarUsuario() async {
    try {
      Map<String, dynamic> actualizarInfo = {
        "nombre": nameController.text,
        "apellido": apellidoController.text,
        "direccion": locationController.text,
        "celular": celController.text,
        'rol': _enteredRole,

      };

      if (_imagenSeleccionada != null) {
        // Subir la nueva imagen a Firebase Storage
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${widget.userId}.jpg');
        await storageRef.putFile(_imagenSeleccionada!);
        _imagenUrl = await storageRef.getDownloadURL();
        actualizarInfo['image_url'] = _imagenUrl;
      }

      await DatabaseMethods().actualizarDetalleUsuario(widget.userId, actualizarInfo);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Datos actualizados correctamente',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black.withOpacity(0.7),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          duration: Duration(milliseconds: 800),
        ),
      );

      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al actualizar los datos',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black.withOpacity(0.7),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          duration: Duration(milliseconds: 800),
        ),
      );
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
              'Editar Usuario',
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ImagenUsuarioPicker(
                onPickImage: (imagenElegida) {
                  setState(() {
                    _imagenSeleccionada = imagenElegida;
                  });
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
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
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: apellidoController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFFffffff),
                  labelText: 'Apellido',
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
              ),
             SizedBox(height: 20.0),
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
              SizedBox(height: 20.0),
              TextField(
                controller: locationController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFFffffff),
                  labelText: 'Direccion',
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
              ),
              SizedBox(height: 20.0),
              TextField(
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                controller: celController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFFffffff),
                  labelText: 'Telefono',
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
              ),
              SizedBox(height: 20.0),
              Center(
                child: ElevatedButton(
                  onPressed: actualizarUsuario,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFA500),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                    minimumSize: Size(250, 30),
                  ),
                  child: Text(
                    'Actualizar',
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
