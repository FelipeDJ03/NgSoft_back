import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ngcomanda/paginas/admin/categorias/editar-categoria.dart';
import 'package:ngcomanda/paginas/admin/categorias/registrar-categoria.dart';
import 'package:ngcomanda/paginas/admin/combo/editar-combo.dart';
import 'package:ngcomanda/paginas/admin/combo/registrar-combo.dart';
import 'package:ngcomanda/paginas/splash.dart';
import 'combo-service.dart';
import 'package:flutter/material.dart';

class ListaCombo extends StatefulWidget {
  final String alias;
      final List<Color?> coloresRestaurante;

  const ListaCombo({super.key, required this.alias,required this.coloresRestaurante});

  @override
  _ListaComboState createState() => _ListaComboState();
}

class _ListaComboState extends State<ListaCombo> {
  TextEditingController namecontroller = new TextEditingController();
  TextEditingController apellidocontroller = new TextEditingController();
  TextEditingController locationcontroller = new TextEditingController();
  Stream? ComboStream;

 

  @override
  void initState() {
    getontheload();
    super.initState();
  }

  void editarDetallesCombo(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarCombo(comboId: userId,coloresRestaurante:widget.coloresRestaurante),
      ),
    );
  }
 getontheload() async {
    ComboStream = await DatabaseMethods().ObtenerDetallecombos(widget.alias);
    setState(() {});
  }
  Widget TodoslosCombos() {
    return StreamBuilder(
      stream: ComboStream,
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
                      SizedBox(width: 10.0), 
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "${ds['nombre']}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              "${ds['descripcion']}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    editarDetallesCombo(ds.id);
                                  },
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: 5.0),
                                GestureDetector(
                                  onTap: () async {
                                    await DatabaseMethods().Eliminarcombo(ds.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Se ha eliminado un combo',
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
      backgroundColor: Color.fromARGB(255, 233, 233, 233),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => REG_Combo(alias:widget.alias,coloresRestaurante:widget.coloresRestaurante)));
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
              'Combos',
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
            Expanded(child: TodoslosCombos()),
          ],
        ),
      ),
    );
  }
}
