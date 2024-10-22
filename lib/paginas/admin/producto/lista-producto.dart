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
                      color: widget.coloresRestaurante[1],
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
                              color: widget.coloresRestaurante[3],
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
                                  color: widget.coloresRestaurante[3],
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10.0),
                              Text(
                                "${ds['descripcion']}",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: widget.coloresRestaurante[3],
                                  fontSize: 14.0,
                                ),
                              ),
                              SizedBox(height: 10.0),
                              Text(
                                "${ds['disponibilidad']}",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: widget.coloresRestaurante[3],
                                  fontSize: 14.0,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                "\$${ds['precio']}",
                                style: TextStyle(
                                  color: widget.coloresRestaurante[3],
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
                                    child: Icon(Icons.edit, color: widget.coloresRestaurante[3],),
                                  ),
                                  SizedBox(height: 5.0),
                                  GestureDetector(
                                    onTap: () {
                                      ModalEliminar(ds.id);
                                    },
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                      size: 20,
                                    ),
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
        child: Icon(Icons.add, color: widget.coloresRestaurante[3],),
        backgroundColor: widget.coloresRestaurante[2],
      ),
      appBar: AppBar(
        backgroundColor: widget.coloresRestaurante[0],
        iconTheme: IconThemeData(
    color: Colors.white, // Color blanco para el ícono de menú y flecha de regreso
  ),
        title: Text(
          'Productos',
          style: TextStyle(
            color: widget.coloresRestaurante[3],
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
              filtrarProductos(value);
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: widget.coloresRestaurante[3],
              labelText: 'Buscar Producto',
              labelStyle: TextStyle(
                color: widget.coloresRestaurante[4],
                fontSize: 14,
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
              contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              prefixIcon: Icon(Icons.search, color: widget.coloresRestaurante[4]),
            ),
          ),
            SizedBox(height: 10),
            Expanded(child: TodoslosProductos()),
          ],
        ),
      ),
    );
  }


void ModalEliminar(String productoID) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: 300,
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
                SizedBox(height: 20),
                Icon(
                  Icons.check_circle_outline,
                  color: widget.coloresRestaurante[1],
                  size: 80,
                ),
                SizedBox(height: 20),
                Text(
                  'Confirmar Acción',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '¿Estás seguro de eliminar este producto?',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await DatabaseMethods().Eliminarproducto(productoID);
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
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: Text(
                          'Sí',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: Text(
                          'No',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
