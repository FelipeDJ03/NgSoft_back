import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'producto-service.dart';
import 'package:ngcomanda/paginas/admin/producto/editar-producto.dart';
import 'package:ngcomanda/paginas/admin/producto/registrar-producto.dart';
import 'package:ngcomanda/paginas/splash.dart';

class ListaProducto extends StatefulWidget {
  final String alias;
      final List<Color?> coloresRestaurante;

  const ListaProducto({super.key, required this.alias,required this.coloresRestaurante});

  @override
  _ListaProductoState createState() => _ListaProductoState();
}

class _ListaProductoState extends State<ListaProducto> {
  TextEditingController searchController = TextEditingController();

  Stream? productosStream;
  List<DocumentSnapshot> productosFiltrados = [];
  List<DocumentSnapshot> todosLosProductos = [];

  @override
  void initState() {
    super.initState();
    getontheload();
  }

  // Método para obtener los productos
  getontheload() async {
    productosStream = await DatabaseMethods().ObtenerDetalleproductos(widget.alias);
    setState(() {});
  }
  
  void editarDetallesUsuario(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Editarproducto(userId: userId, coloresRestaurante:widget.coloresRestaurante),
      ),
    );
  }
  // Método para filtrar productos por nombre
  void filtrarProductos(String query) {
    setState(() {
      if (query.isEmpty) {
        productosFiltrados = todosLosProductos; // Mostrar todos si el campo está vacío
      } else {
        productosFiltrados = todosLosProductos.where((producto) {
          return producto['nombre']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  // Widget para mostrar la lista de productos
  Widget TodoslosProductos() {
    return StreamBuilder(
      stream: productosStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SplashPantalla(); // Pantalla de carga
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          todosLosProductos = snapshot.data.docs;
          
          // Si el campo de búsqueda está vacío, muestra todos los productos
          if (searchController.text.isEmpty) {
            productosFiltrados = todosLosProductos;
          }

          return ListView.builder(
            itemCount: productosFiltrados.length,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = productosFiltrados[index];

              return Container(
                margin: EdgeInsets.only(bottom: 17.0),
                child: Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFA500),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Image.network(
                            ds['imagen_url'],
                            height: 120.0,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.food_bank,
                              size: 100,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 25.0),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "${ds['nombre']}",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10.0),
                              Text(
                                "${ds['descripcion']}",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.0,
                                ),
                              ),
                              SizedBox(height: 10.0),
                              Text(
                                "${ds['disponibilidad']}",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.0,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                "\$${ds['precio']}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      editarDetallesUsuario(ds.id);
                                    },
                                    child: Icon(Icons.edit, color: Colors.white),
                                  ),
                                  SizedBox(height: 5.0),
                                  GestureDetector(
                                    onTap: () async {
                                      await DatabaseMethods().Eliminarproducto(ds.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Se ha eliminado un producto',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                          backgroundColor: Colors.black.withOpacity(0.7),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(18),
                                          ),
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 30, vertical: 20),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 10),
                                          duration: Duration(milliseconds: 800),
                                        ),
                                      );
                                    },
                                    child: Icon(Icons.delete, color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        } else {
          return Container();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 247, 246, 244),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => REG_Producto(alias: widget.alias,coloresRestaurante:widget.coloresRestaurante)));
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Color(0xFFD2691E),
      ),
      appBar: AppBar(
        backgroundColor: Color(0xFF556B2F),
        title: const Text(
          'Productos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 45.0),
        child: Column(
          children: [
            // Buscador de productos
            TextField(
              controller: searchController,
              onChanged: (value) {
                filtrarProductos(value); // Filtrar en tiempo real
              },
              decoration: InputDecoration(
                labelText: 'Buscar Producto',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(child: TodoslosProductos()),
          ],
        ),
      ),
    );
  }
}
