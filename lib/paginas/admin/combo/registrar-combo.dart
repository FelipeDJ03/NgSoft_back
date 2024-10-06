import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importar para FilteringTextInputFormatter
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:random_string/random_string.dart';
import 'package:ngcomanda/widgets/imagen_usuario.dart';
import 'package:ngcomanda/paginas/admin/combo/lista-combo.dart';
import 'combo-service.dart';

class REG_Combo extends StatefulWidget {
  final String alias;
  const REG_Combo({super.key,required this.alias});

  @override
  State<REG_Combo> createState() => _REG_ComboState();
}

class _REG_ComboState extends State<REG_Combo> {
  final _form = GlobalKey<FormState>();
  TextEditingController nombreController = TextEditingController();
  TextEditingController descripcionController = TextEditingController();
  TextEditingController precioController = TextEditingController();
  String? _disponibilidadSeleccionada;
  File? _imagenSeleccionada;
  var _subiendo = false;
  List<String> _categorias = [];
  String? _categoriaSeleccionada;
  List<Map<String, dynamic>> _productosSeleccionados = [];
  String? _filtroCategoria;

  void _submit() async {
    final isValid = _form.currentState!.validate();

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

    _form.currentState!.save();

    try {
      setState(() {
        _subiendo = true;
      });

      String Id = randomAlphaNumeric(10);
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('combo_images')
          .child('$Id.jpg');

      await storageRef.putFile(_imagenSeleccionada!);
      final imagenUrl = await storageRef.getDownloadURL();

      List productosIds = _productosSeleccionados.map((producto) => producto['id']).toList();

      Map<String, dynamic> comboInfoMap = {
        "nombre": nombreController.text,
        "descripcion": descripcionController.text,
        "precio": double.parse(precioController.text),
        "disponibilidad": _disponibilidadSeleccionada == 'Disponible',
        "categoria": _categoriaSeleccionada,
        "imagen_url": imagenUrl,
        "productos": productosIds,
        "Id": Id,
        "alias":widget.alias,
      };

      await FirebaseFirestore.instance
          .collection('combos')
          .doc(Id)
          .set(comboInfoMap)
          .then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'El Combo se ha registrado de forma exitosa',
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

      setState(() {
        _subiendo = false;
      });
    }
  }

  void _mostrarSeleccionProductos(BuildContext context) {
    
    showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  builder: (ctx) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: DatabaseMethods().Obtenercategorias(widget.alias),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      height: 56.0,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Text('No hay categorías disponibles.');
                  } else {
                    var categorias = snapshot.data!.docs;
                    return ClipRect(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: categorias.map((doc) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ChoiceChip(
                                  label: Text(
                                    doc['nombre'],
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  selected: _filtroCategoria == doc.id,
                                  onSelected: (bool selected) {
                                    setModalState(() {
                                      _filtroCategoria = selected ? doc.id : null;
                                    });
                                  },
                                  backgroundColor: Color(0xFFD2691E),
                                  selectedColor: Color(0xFFFFA500),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    side: BorderSide(color: Colors.transparent),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
             
              Expanded(
                child: FutureBuilder<List<QuerySnapshot>>(
                  future: Future.wait([
                    FirebaseFirestore.instance.collection('productos').where('alias', isEqualTo: widget.alias).get(),
                    FirebaseFirestore.instance.collection('combos').where('alias', isEqualTo: widget.alias).get(),
                  ]),
                  builder: (ctx, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height - 56.0,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text('No hay productos disponibles.');
                    } else {
                      var productos = snapshot.data![0].docs + snapshot.data![1].docs;

                      if (_filtroCategoria != null) {
                        productos = productos.where((producto) => producto['categoria'] == _filtroCategoria).toList();
                      }

                      

                      if (productos.isEmpty) {
                        return Center(child: Text('No se encontraron productos.'));
                      }

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('${productos.length} resultados encontrados', style: TextStyle(color: Colors.black)),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: productos.length,
                              itemBuilder: (ctx, index) {
                                var producto = productos[index];
                                return Container(
                                  margin: EdgeInsets.only(bottom: 17.0, left: 20, right: 20),
                                  child: Material(
                                    elevation: 5.0,
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      padding: const EdgeInsets.all(18),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFFFA500),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: ListTile(
                                        leading: Image.network(
                                          producto['imagen_url'],
                                          width: 50, height: 50,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Icon(
                                            Icons.food_bank,
                                            size: 50,
                                            color: Colors.white,
                                          ),
                                        ),
                                        title: Text(producto['nombre'], style: TextStyle(color: Colors.white)),
                                        onTap: () {
                                          setState(() {
                                            _productosSeleccionados.add({
                                              'id': producto.id,
                                              'nombre': producto['nombre'],
                                              'imagen_url': producto['imagen_url']
                                            });
                                          });
                                          Navigator.of(ctx).pop();
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );      
      },
    );
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
              'Agregar Combo',
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 40,
            right: 40,
            top: 20,
            bottom: 40,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _form,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ImagenUsuarioPicker(
                    onPickImage: (imagenElegida) {
                      _imagenSeleccionada = imagenElegida;
                    },
                  ),
                  SizedBox(height: 25,),
                  TextFormField(
                    controller: nombreController,
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
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor ingresa un precio.';
                      }
                      if (double.tryParse(value) == null || double.parse(value) <= 0) {
                        return 'Por favor ingresa un número positivo.';
                      }
                      return null;
                    },
                  ),
                    SizedBox(height: 25,),
                    DropdownButtonFormField<String>(
                      value: _disponibilidadSeleccionada,
                      items: ['Disponible', 'No Disponible'].map((String estado) {
                        return DropdownMenuItem<String>(
                          value: estado,
                          child: Text(estado),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _disponibilidadSeleccionada = value; 
                        });
                      },
                      decoration: InputDecoration(
                      filled: true, 
                      fillColor: Color(0xFFffffff),
                      labelText: 'Disponibilidad',
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
                          return 'Por favor selecciona la disponibilidad.';
                        }
                        return null;
                      },
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
                            fillColor: Color(0xFFffffff),
                            labelText: 'Categoría',
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
                                return 'Por favor selecciona una categoría.';
                              }
                              return null;
                            },
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: () => _mostrarSeleccionProductos(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFA500),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                        minimumSize: Size(250, 20),
                      ),
                      child: Text(
                        'Agregar Producto',
                        style: TextStyle(
                          fontSize: 17, 
                          color: Colors.white, 
                          fontWeight: FontWeight.bold,
                        ), 
                      ),
                    ),
                    const SizedBox(height: 25),
                    if (_productosSeleccionados.isNotEmpty)
                      Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Productos Agregados:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._productosSeleccionados.map((producto) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 12.0, left: 16, right: 16), // Ajusta el margen
                            child: Material(
                              elevation: 3.0, // Reducción de la elevación
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Ajusta el padding
                                decoration: BoxDecoration(
                                  color: Color(0xFFFFA500), // Color de fondo de la tarjeta
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListTile(
                                  leading: producto['imagen_url'] != null && producto['imagen_url'].isNotEmpty
                                      ? Image.network(
                                          producto['imagen_url'],
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Icon(
                                            Icons.food_bank,
                                            size: 50,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Icon(
                                          Icons.food_bank,
                                          size: 50,
                                          color: Colors.white,
                                        ),
                                  title: Text(
                                    producto['nombre'],
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.remove_circle, color: Colors.white),
                                    onPressed: () {
                                      setState(() {
                                        _productosSeleccionados.remove(producto);
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),                
                    if (_subiendo) const CircularProgressIndicator(),
                    if (!_subiendo)
                      ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFD2691E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                        minimumSize: Size(250, 20),
                      ),
                        child: Text(
                          'Registrar',
                          style: TextStyle(
                            fontSize: 17, 
                            color: Colors.white, 
                          ), 
                        ),
                      )

                  ],
                ),
              ),
            ),
        
        ),
      ),
    );
  }
}
