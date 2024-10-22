import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ngcomanda/paginas/admin/combo/lista-combo.dart';
import 'combo-service.dart';

class EditarCombo extends StatefulWidget {
  final String comboId;
    final List<Color?> coloresRestaurante;

  const EditarCombo({Key? key, required this.comboId,required this.coloresRestaurante}) : super(key: key);

  @override
  _EditarComboState createState() => _EditarComboState();
} 

class _EditarComboState extends State<EditarCombo> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nombreController = TextEditingController();
  TextEditingController descripcionController = TextEditingController();
  TextEditingController precioController = TextEditingController();
  String? _disponibilidadSeleccionada;
  File? _nuevaImagen;
  var _cargando = false;

  @override
  void initState() {
    super.initState();
    obtenerDetalleCombo();

    // Agregar un listener al controlador del precio
    precioController.addListener(_filterPriceInput);
  }

  void _filterPriceInput() {
    final input = precioController.text;
    final filtered = input.replaceAll(RegExp(r'[^0-9]'), ''); // Solo permite números

    // Solo actualiza el texto si ha cambiado
    if (input != filtered) {
      precioController.value = precioController.value.copyWith(
        text: filtered,
        selection: TextSelection.collapsed(offset: filtered.length),
      );
    }
  }

  @override
  void dispose() {
    // Eliminar el listener cuando se destruya el widget
    precioController.removeListener(_filterPriceInput);
    super.dispose();
  }

  void obtenerDetalleCombo() async {
    Map<String, dynamic>? combo = await DatabaseMethods().obtenerDetallecombo(widget.comboId);
    if (combo != null) {
      setState(() {
        nombreController.text = combo['nombre'];
        descripcionController.text = combo['descripcion'];
        precioController.text = combo['precio'].toString();
        _disponibilidadSeleccionada = combo['disponibilidad'] ? 'Disponible' : 'No Disponible';
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    try {
      setState(() {
        _cargando = true;
      });

      String imagenUrl = '';

      if (_nuevaImagen != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('combo_images')
            .child('${widget.comboId}.jpg');
        await storageRef.putFile(_nuevaImagen!);
        imagenUrl = await storageRef.getDownloadURL();
      }

      Map<String, dynamic> actualizarInfo = {
        'nombre': nombreController.text,
        'descripcion': descripcionController.text,
        'precio': double.parse(precioController.text),
        'disponibilidad': _disponibilidadSeleccionada == 'Disponible',
      };

      if (imagenUrl.isNotEmpty) {
        actualizarInfo['imagen_url'] = imagenUrl;
      }

      await DatabaseMethods().actualizarDetallecombo(widget.comboId, actualizarInfo);

      // Mostrar SnackBar de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'El combo se ha actualizado de forma exitosa',
            style: TextStyle(color: widget.coloresRestaurante[3]),
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

        Navigator.pop(context);
    } catch (error) {
      // Mostrar SnackBar de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al actualizar el combo',
            style: TextStyle(color: widget.coloresRestaurante[3]),
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

      setState(() {
        _cargando = false;
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
            backgroundColor: widget.coloresRestaurante[0],
            elevation: 0,
            title: Text(
              'Editar Combo',
              style: TextStyle(
                color: widget.coloresRestaurante[3],
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            iconTheme: IconThemeData(
              color: widget.coloresRestaurante[3],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _cargando
              ? Center(child: CircularProgressIndicator())
              : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 25,),
                      TextFormField(
                        controller: nombreController,
                        decoration: InputDecoration(
                          filled: true, 
                          fillColor: widget.coloresRestaurante[3],
                          labelText: 'Nombre',
                          labelStyle: TextStyle(
                            color: widget.coloresRestaurante[4], 
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: widget.coloresRestaurante[2]!,
                              width: 1.3,
                            ),
                            borderRadius: BorderRadius.circular(18.0), 
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: widget.coloresRestaurante[2]!,
                              width: 1.3,
                            ),
                            borderRadius: BorderRadius.circular(18.0), 
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor ingresa un nombre.';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20.0),
                      TextFormField(
                        controller: descripcionController,
                        decoration: InputDecoration(
                          filled: true, 
                          fillColor: widget.coloresRestaurante[3],
                          labelText: 'Descripción',
                          labelStyle: TextStyle(
                            color: widget.coloresRestaurante[4], 
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: widget.coloresRestaurante[2]!,
                              width: 1.3,
                            ),
                            borderRadius: BorderRadius.circular(18.0), 
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: widget.coloresRestaurante[2]!,
                              width: 1.3,
                            ),
                            borderRadius: BorderRadius.circular(18.0), 
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor ingresa una descripción.';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20.0),
                      TextFormField(
                        controller: precioController,
                        decoration: InputDecoration(
                          filled: true, 
                          fillColor: widget.coloresRestaurante[3],
                          labelText: 'Precio',
                          labelStyle: TextStyle(
                            color: widget.coloresRestaurante[4], 
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: widget.coloresRestaurante[2]!,
                              width: 1.3,
                            ),
                            borderRadius: BorderRadius.circular(18.0), 
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: widget.coloresRestaurante[2]!,
                              width: 1.3,
                            ),
                            borderRadius: BorderRadius.circular(18.0), 
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor ingresa un precio.';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Por favor ingresa un número válido.';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20.0),
                      DropdownButtonFormField<String>(
                        value: _disponibilidadSeleccionada,
                        items: ['Disponible', 'No Disponible']
                            .map((String estado) {
                              return DropdownMenuItem<String>(
                                value: estado,
                                child: Text(estado),
                              );
                            }) 
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _disponibilidadSeleccionada = value;
                          });
                        },
                        decoration: InputDecoration(
                          filled: true, 
                          fillColor: widget.coloresRestaurante[3],
                          labelText: 'Disponibilidad',
                          labelStyle: TextStyle(
                            color: widget.coloresRestaurante[4], 
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: widget.coloresRestaurante[2]!,
                              width: 1.3,
                            ),
                            borderRadius: BorderRadius.circular(18.0), 
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: widget.coloresRestaurante[2]!,
                              width: 1.3,
                            ),
                            borderRadius: BorderRadius.circular(18.0), 
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor selecciona la disponibilidad.';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20.0),
                      Center(
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.coloresRestaurante[1],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                            minimumSize: Size(300, 45),
                          ),
                          child: Text(
                            'Actualizar',
                            style: TextStyle(
                              fontSize: 17, 
                              color: widget.coloresRestaurante[3], 
                              fontWeight: FontWeight.bold,
                            ), 
                          ),
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
