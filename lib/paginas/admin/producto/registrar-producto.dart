import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ngcomanda/paginas/admin/producto/producto-service.dart';
import 'package:ngcomanda/paginas/admin/producto/lista-producto.dart';
import 'package:ngcomanda/widgets/imagen_usuario.dart';
import 'package:random_string/random_string.dart';
import 'package:flutter/services.dart';

enum Disponibilidad { disponible, nodisponible }
enum Habilitado { disponible, nodisponible }
enum Disponibilidad_inventario{ disponible, nodisponible }

class REG_Producto extends StatefulWidget {
  final String alias;
      final List<Color?> coloresRestaurante;

  const REG_Producto({super.key,required this.alias,required this.coloresRestaurante});

  @override
  State<REG_Producto> createState() => _REG_ProductoState();
}
 
class _REG_ProductoState extends State<REG_Producto> {
  final _form = GlobalKey<FormState>();
  TextEditingController nombreController = TextEditingController();
  TextEditingController descripcionController = TextEditingController();
  TextEditingController precioController = TextEditingController();
  TextEditingController categoriaController = TextEditingController();
  TextEditingController cocinaController = TextEditingController();
  TextEditingController minutosController = TextEditingController();
TextEditingController unidadesController = TextEditingController();

    Disponibilidad? _selectedDisponibilidad;
    Disponibilidad_inventario? _selectedDisponibilidadinventario;
    Habilitado? _selectedHabilitado;

  File? _imagenSeleccionada;
  var _subiendo = false;
  String? _categoriaSeleccionada;
  String? _cocinaSeleccionada;


 
  void _submit() async {
    final isValid = _form.currentState!.validate();

    if (!isValid || _imagenSeleccionada == null) {
    if (_imagenSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se ha agregado una imagen.',
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
    }
    return;
  }


    _form.currentState!.save();
    
    try {
      setState(() {
        _subiendo = true;
      });

      String Id = randomAlphaNumeric(10);
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('product_images')
          .child('$Id.jpg');

      await storageRef.putFile(_imagenSeleccionada!);
      final imagenUrl = await storageRef.getDownloadURL();

      Map<String, dynamic> productInfoMap = {
      "nombre": nombreController.text,
      "descripcion": descripcionController.text,
      "precio": double.parse(precioController.text),
      "categoria": _categoriaSeleccionada,
      "cocina": _cocinaSeleccionada,
      "imagen_url": imagenUrl,
      "delivery": _selectedDisponibilidad == Disponibilidad.disponible ? 'Disponible' : 'nodisponible',
      "disponibilidad": _selectedHabilitado == Habilitado.disponible ? 'Disponible' : 'nodisponible',
      "disponibilidad_inventario": _selectedDisponibilidadinventario == Disponibilidad_inventario.disponible ? 'Disponible' : 'nodisponible',
      "estado": 'activo',
      "tiempo": double.parse(minutosController.text),
      "Id": Id,
      "alias": widget.alias,
      // Agregar unidades solo si el inventario está habilitado
      if (_selectedDisponibilidadinventario == Disponibilidad_inventario.disponible) 
        "unidades": double.parse(unidadesController.text),
    };

      await FirebaseFirestore.instance
          .collection('productos')
          .doc(Id)
          .set(productInfoMap)
          .then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'El producto se ha registrado de forma exitosa',
            style: TextStyle(color: widget.coloresRestaurante[3]),
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
        // Regresar a la lista de productos (asumiendo que tienes una pantalla ListaProducto)
        Navigator.pop(context);
      });

    } catch (error) {
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
                color: widget.coloresRestaurante[3],
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
                    'Registro fallido. $error',
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
                          backgroundColor: widget.coloresRestaurante[3],
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
                  color: widget.coloresRestaurante[3],
                  size: 50,
                ),
              ),
            ),
          ],
        ),
      ),
    );
      setState(() {
        _subiendo = false;
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
              'Productos',
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
          left: 40,
          right: 40,
          top: 20,
          bottom: 40,
        ),
            child: Center(
              child: Form(
                key: _form,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ImagenUsuarioPicker(
                      onPickImage: (imagenElegida) {
                        _imagenSeleccionada = imagenElegida;
                      },
                    ),
                    const SizedBox(height: 20),
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
                    SizedBox(height: 25,),
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
                    SizedBox(height: 25,),               
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
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingresa un precio.';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Por favor ingresa un número válido.';
                        }
                        if (double.parse(value) < 0) {
                          return 'Por favor ingresa un número positivo.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 25,),               
                    TextFormField(
                      controller: minutosController, // Cambia este controlador para capturar los minutos
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: widget.coloresRestaurante[3],
                        labelText: 'Tiempo de preparacion (minutos)', // Cambia el texto para indicar que es para minutos
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
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly, // Solo permite dígitos (números enteros)
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingresa los minutos.';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Por favor ingresa un número válido.';
                        }
                        if (int.parse(value) < 0) {
                          return 'Por favor ingresa un número positivo.';
                        }
                        return null;
                      },
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
                        fillColor: widget.coloresRestaurante[3],
                        labelText: 'Disponibilidad en delivery',
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
                        if (value == null) {
                          return 'Por favor selecciona una disponibilidad';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 25,),
                     DropdownButtonFormField<Habilitado>(
                      value: _selectedHabilitado,
                      items: [
                        DropdownMenuItem(
                          value: Habilitado.disponible,
                          child: Text('Disponible'),
                        ),
                        DropdownMenuItem(
                          value: Habilitado.nodisponible,
                          child: Text('No disponible'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedHabilitado = value;
                        });
                      },
                      decoration: InputDecoration(
                        filled: true, 
                        fillColor: widget.coloresRestaurante[3],
                        labelText: 'Disponible en cocina',
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
                        if (value == null) {
                          return 'Por favor selecciona una disponibilidad';
                        }
                        return null;
                      },
                    ),
                   SizedBox(height: 25,),
                      DropdownButtonFormField<Disponibilidad_inventario>(
                        value: _selectedDisponibilidadinventario,
                        items: [
                          DropdownMenuItem(
                            value: Disponibilidad_inventario.disponible,
                            child: Text('Disponible'),
                          ),
                          DropdownMenuItem(
                            value: Disponibilidad_inventario.nodisponible,
                            child: Text('No disponible'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedDisponibilidadinventario = value;
                          });
                        },
                        decoration: InputDecoration(
                          filled: true, 
                          fillColor: widget.coloresRestaurante[3],
                          labelText: 'Habilitar inventario',
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
                          if (value == null) {
                            return 'Por favor selecciona una disponibilidad';
                          }
                          return null;
                        },
                      ),

                      // Campo de unidades (solo visible si el inventario está habilitado)
                      Visibility(
                        visible: _selectedDisponibilidadinventario == Disponibilidad_inventario.disponible,
                        child: Column(
                          children: [
                            SizedBox(height: 25,),
                            TextFormField(
                              controller: unidadesController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: widget.coloresRestaurante[3],
                                labelText: 'Unidades en inventario',
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
                                if (_selectedDisponibilidadinventario == Disponibilidad_inventario.disponible && (value == null || value.isEmpty)) {
                                  return 'Por favor ingresa las unidades';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: 25,),
                    StreamBuilder<QuerySnapshot>(
                      stream: DatabaseMethods().Obtenercategorias(widget.alias),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Text('No hay categorías disponibles.');
                        } else {
                          var categorias = snapshot.data!.docs.map((doc) {
                            return DropdownMenuItem<String>(
                              value: doc.id,
                              child: Text(doc['nombre']),
                            );
                          }).toList();

                          return DropdownButtonFormField<String>(
                            value: _categoriaSeleccionada,
                            items: categorias,
                            onChanged: (value) {
                              setState(() {
                                _categoriaSeleccionada = value;
                              });
                            },
                            decoration: InputDecoration(
                              filled: true, 
                              fillColor: widget.coloresRestaurante[3],
                              labelText: 'Categoría',
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
                                return 'Por favor selecciona una categoría.';
                              }
                              return null;
                            },
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 25),
                    StreamBuilder<QuerySnapshot>(
                      stream: DatabaseMethods().Obtenercocinas(widget.alias),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Text('No hay cocinas disponibles.');
                        } else {
                          var cocinas = snapshot.data!.docs.map((doc) {
                            return DropdownMenuItem<String>(
                              value: doc.id,
                              child: Text(doc['nombre']),
                            );
                          }).toList();

                          return DropdownButtonFormField<String>(
                            value: _cocinaSeleccionada,
                            items: cocinas,
                            onChanged: (value) {
                              setState(() {
                                _cocinaSeleccionada = value;
                              });
                            },
                            decoration: InputDecoration(
                              filled: true, 
                              fillColor: widget.coloresRestaurante[3],
                              labelText: 'Cocina',
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
                                return 'Por favor selecciona una cocina.';
                              }
                              return null;
                            },
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 25),
                    if (_subiendo) const CircularProgressIndicator(),
                    if (!_subiendo)
                      ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                        backgroundColor: widget.coloresRestaurante[1],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                        minimumSize: Size(300, 30),
                      ),
                      child: Text(
                        'Registrar',
                        style: TextStyle(
                          fontSize: 17, 
                          color: widget.coloresRestaurante[3], 
                          fontWeight: FontWeight.bold,
                        ), 
                      ),
                      ),
                  ],
                ),
              ),
            ),
          
        ),
      ),
    );
  }
}
