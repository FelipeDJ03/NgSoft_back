import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ngcomanda/paginas/admin/producto/editar-producto.dart';
import 'package:ngcomanda/paginas/admin/producto/registrar-producto.dart';
import 'package:ngcomanda/paginas/splash.dart';
import 'producto-service.dart';
import 'package:flutter/material.dart';
import 'package:ngcomanda/widgets/imagen_usuario.dart'; 

class ListaProducto extends StatefulWidget {
  final String alias;
  const ListaProducto({super.key, required this.alias});

  @override
  _ListaProductoState createState() => _ListaProductoState();
}

class _ListaProductoState extends State<ListaProducto> {
  TextEditingController namecontroller = new TextEditingController();
  TextEditingController apellidocontroller = new TextEditingController();
  TextEditingController locationcontroller = new TextEditingController();
  Stream? ProductosStream;

  getontheload() async {
    ProductosStream = await DatabaseMethods().ObtenerDetalleproductos(widget.alias);
    setState(() {});
  }

  @override
  void initState() {
    getontheload();
    super.initState();
  }

  void editarDetallesUsuario(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Editarproducto(userId: userId),
      ),
    );
  } 

  Widget TodoslosUsuarios() {
    return StreamBuilder(
      stream: ProductosStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SplashPantalla(); // Muestra la pantalla de carga mientras se cargan los datos
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {

          return ListView.builder(
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = snapshot.data.docs[index];

              return Container(
                margin: EdgeInsets.only(bottom: 17.0),
                child: Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Color(0xFFFFA500),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    
                    child: Row(
                    children: [
                        Expanded(
                        flex: 1,
                        child: Image.network(
                          ds['imagen_url'] ,
                          height: 120.0,
                          fit: BoxFit.cover, 
                          errorBuilder: (context, error, stackTrace) => Icon(Icons.food_bank, size: 100, color: Colors.white,), 
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
                                          margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              context, MaterialPageRoute(builder: (context) => REG_Producto(alias:widget.alias)));
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Color(0xFFD2691E),
      ),
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
              'Productos',
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
      body: Container(
        margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 45.0),
        child: Column(
          children: [
            Expanded(child: TodoslosUsuarios()),
          ],
        ),
      ),
    );
  }
}
