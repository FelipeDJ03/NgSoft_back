import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'orden-service.dart';
import '../admin/combo/combo-service.dart';

class SeleccionarPlatillosPantalla extends StatefulWidget {
  final String mesaId;
  final String alias;
  final int numeroComensal;

  SeleccionarPlatillosPantalla({required this.mesaId, required this.numeroComensal,required this.alias});

  @override
  _SeleccionarPlatillosPantallaState createState() => _SeleccionarPlatillosPantallaState();
}

class _SeleccionarPlatillosPantallaState extends State<SeleccionarPlatillosPantalla> {
  List<String> _categorias = [];
  String? _categoriaSeleccionada;
  String? _filtroCategoria;
  bool _isModalAbierto = false;
  TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  void _mostrarSeleccionProductos(BuildContext context) {
    if (_isModalAbierto) return;

    setState(() {
      _isModalAbierto = true;
    });

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
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Buscar producto',
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: Colors.orange,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: Colors.orange,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: Colors.orange,
                          ),
                        ),
                        suffixIcon: _searchText.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  setModalState(() {
                                    _searchController.clear();
                                    _searchText = '';
                                  });
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        setModalState(() {
                          _searchText = value.toLowerCase();
                        });
                      },
                    ),

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

                          if (_searchText.isNotEmpty) {
                            productos = productos.where((producto) {
                              return producto['nombre'].toLowerCase().contains(_searchText);
                            }).toList();
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
                                            leading:                                       
                                            Image.network(
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
                                            onTap: () async {
                                              await OrdenService().agregarProductoAlCarrito(
                                                Id:producto['Id'],
                                                nombre: producto['nombre'],
                                                precio: producto['precio'],
                                                imagenUrl: producto['imagen_url'],
                                                mesaId: widget.mesaId,
                                                numeroComensal: widget.numeroComensal,
                                                alias:widget.alias,
                                              );
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
    ).whenComplete(() {
      setState(() {
        _isModalAbierto = false;
      });
    });
  }

  Future<void> _agregarNota(BuildContext context, String productoCarritoId) async {
    TextEditingController _notaController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Agregar Nota',
            style: TextStyle(color: Colors.black),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20),
              TextFormField(
                controller: _notaController,
                decoration: InputDecoration(
                  labelText: 'Escribe una nota',
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.orange),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.orange),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.orange),
                  ),
                ),
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.orange),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            TextButton(
              child: Text(
                'Guardar',
                style: TextStyle(color: Colors.orange),
              ),
              onPressed: () async {
                try {
                  await OrdenService2().agregarNotaAlProducto(productoCarritoId, _notaController.text);
                  Navigator.of(ctx).pop();
                  setState(() {}); // Refresca el carrito
                } catch (e) {
                  print('Error al agregar nota: $e');
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color.fromARGB(255, 247, 246, 244),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Comensal ${widget.numeroComensal} - Mesa ${widget.mesaId}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: OrdenService().obtenerCarrito(widget.mesaId, widget.numeroComensal),
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.black));
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'No se ha seleccionado ningún platillo',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              _mostrarSeleccionProductos(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFD2691E),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                              minimumSize: Size(300, 30),
                            ),
                            child: Text(
                              'Agregar Más Productos',
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    var carrito = snapshot.data!.docs;

                    return Column(
                      children: [
                        Expanded( 
                          child: ListView.builder(
                            itemCount: carrito.length,
                            itemBuilder: (ctx, index) {
                              var productoCarrito = carrito[index];

                              return Container(
                                margin: EdgeInsets.only(bottom: 17.0, left: 20, right: 20),
                                child: Material(
                                  elevation: 5.0,
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.only(bottom: 8.0, left: 14, right: 14, top: 8.0),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFFFA500),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Row(
                                      children: [  
                                        SizedBox(width: 15.0),                                  
                                        Expanded(
                                          flex: 4,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                productoCarrito['nombre'],
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              
                                              Text(
                                                'Cantidad: ${productoCarrito['cantidad']}',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                              Text(
                                                'Nota: ${productoCarrito['nota'] ?? ''}',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15.0,
                                                ),
                                              ),
                                              SizedBox(height: 5,),
                                              Text(
                                                "\$${productoCarrito['precio']}",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),  
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 25.0),
                                        Expanded(
                                          flex: 2,
                                          child: Column(                                         
                                            children: [
                                            Image.network(
                                            productoCarrito['imagen_url'],
                                            height: 110.0,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Icon(
                                              Icons.food_bank,
                                              size: 90,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  IconButton(
                                                    icon: Icon(Icons.note_add, color: Colors.white),
                                                    onPressed: () {
                                                      _agregarNota(context, productoCarrito.id);
                                                    },
                                                  ),
                                                  SizedBox(width: 1.0),
                                                  IconButton(
                                                    icon: Icon(Icons.delete, color: Colors.white),
                                                    onPressed: () async {
                                                      await OrdenService().eliminarProductoDelCarrito(productoCarrito.id);
                                                    },
                                                  ),
                                                ],
                                              ),
                                          ],)
                                  
                                        ),
                                        
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              _mostrarSeleccionProductos(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFD2691E),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                              minimumSize: Size(300, 30),
                            ),
                            child: Text(
                              'Agregar Más Productos',
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
      ),
    );
  }
}
