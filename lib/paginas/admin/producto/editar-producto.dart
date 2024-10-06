import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../../../widgets/imagen_usuario.dart';
import 'producto-service.dart';

enum Disponibilidad { disponible, nodisponible }

class Editarproducto extends StatefulWidget {
  final String userId;

  const Editarproducto({Key? key, required this.userId}) : super(key: key);

  @override
  _EditarproductoState createState() => _EditarproductoState();
}
 
class _EditarproductoState extends State<Editarproducto> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descripcionController = TextEditingController();
  TextEditingController precioController = TextEditingController();
    Disponibilidad? _selectedDisponibilidad;

  File? _imagenSeleccionada;
  String? _imagenUrl;

  @override
  void initState() {
    super.initState();
    obtenerDetalleproducto();
  }

  Future<void> obtenerDetalleproducto() async {
    Map<String, dynamic>? producto = await DatabaseMethods().obtenerDetalleproducto(widget.userId);
    if (producto != null) {
      setState(() {
        nameController.text = producto['nombre'];
        descripcionController.text = producto['descripcion'];
        precioController.text = producto['precio'].toString();
        _imagenUrl = producto['imagen_url'];
        _selectedDisponibilidad = producto['delivery'] ; // Establece el valor seleccionado

      });
    }
  }

  Future<void> actualizarproducto() async {
    try {
      Map<String, dynamic> actualizarInfo = {
        "nombre": nameController.text,
        "descripcion": descripcionController.text,
        "delivery": _selectedDisponibilidad  == Disponibilidad.disponible ? 'Disponible' : 'nodisponible',
        "precio": double.parse(precioController.text),
      };

      if (_imagenSeleccionada != null) {
        // Subir la nueva imagen a Firebase Storage
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('product_images')
            .child('${widget.userId}.jpg');
        await storageRef.putFile(_imagenSeleccionada!);
        _imagenUrl = await storageRef.getDownloadURL();
        actualizarInfo['imagen_url'] = _imagenUrl;
      }

      await DatabaseMethods().actualizarDetalleproducto(widget.userId, actualizarInfo);

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
              'Editar Producto',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 10.0),
              ImagenUsuarioPicker(
                onPickImage: (imagenElegida) {
                  setState(() {
                    _imagenSeleccionada = imagenElegida;
                  });
                },
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFFffffff),
                  labelText: 'Nombre',
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
                controller: descripcionController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFFffffff),
                  labelText: 'Descripción',
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
                controller: precioController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFFffffff),
                  labelText: 'Precio',
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
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
              ),
               SizedBox(height: 25,),
                     DropdownButtonFormField<Disponibilidad>(
                      value: _selectedDisponibilidad,
                      items: [
                        DropdownMenuItem(
                          value: Disponibilidad.disponible,
                          child: Text('Disponible'),
                        ),
                        DropdownMenuItem(
                          value: Disponibilidad.nodisponible,
                          child: Text('No disponible'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedDisponibilidad = value;
                        });
                      },
                      decoration: InputDecoration(
                        filled: true, 
                        fillColor: Color(0xFFffffff),
                        labelText: 'Disponibilidad en delivery',
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
                        if (value == null) {
                          return 'Por favor selecciona una disponibilidad';
                        }
                        return null;
                      },
                    ),
              SizedBox(height: 25.0),
              Center(
                child: ElevatedButton(
                  onPressed: actualizarproducto,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFA500),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                    minimumSize: Size(300, 30),
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
