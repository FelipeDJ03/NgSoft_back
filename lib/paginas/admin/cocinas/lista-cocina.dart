import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ngcomanda/paginas/admin/cocinas/editar-cocina.dart';
import 'package:ngcomanda/paginas/admin/cocinas/registrar-cocina.dart';
import 'package:ngcomanda/paginas/splash.dart';
import 'cocina-service.dart';

class Listacocina extends StatefulWidget {
  final String alias;
      final List<Color?> coloresRestaurante;

  const Listacocina({super.key,required this.alias,required this.coloresRestaurante});
    
 


  @override
  _ListacocinaState createState() => _ListacocinaState();
}

class _ListacocinaState extends State<Listacocina> {
  TextEditingController namecontroller = new TextEditingController();
  TextEditingController apellidocontroller = new TextEditingController();
  TextEditingController locationcontroller = new TextEditingController();
  Stream? cocinaStream;
  


  @override
  void initState() {
    getontheload();
    super.initState();
  }

  void editarDetallescocina(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Editarcocina(userId: userId,coloresRestaurante:widget.coloresRestaurante),
      ),
    );
  }

  getontheload() async {
    cocinaStream = await DatabaseMethods().Obtenercocinas(widget.alias);
    setState(() {});
  }

  Widget Todoslascocinas() {
    return StreamBuilder(
      stream: cocinaStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SplashPantalla();
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
                      color: widget.coloresRestaurante[1],
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: 120.0,
                            child: Image.asset(
                              'assets/be1.png',
                            ),
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
                                  color: widget.coloresRestaurante[3],
                                  fontSize: 20.0,
                                ),
                              ),
                              SizedBox(height: 10.0),
                              Text(
                                "${ds['descripcion']}",
                                style: TextStyle(
                                  color: widget.coloresRestaurante[3],
                                  fontSize: 14.0,
                                ),
                              ),
                              SizedBox(height: 10.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      editarDetallescocina(ds.id);
                                    },
                                    child: Icon(
                                      Icons.edit,
                                      color: widget.coloresRestaurante[3],
                                      size: 20,
                                    ),
                                  ),
                                  SizedBox(width: 5.0),
                                  GestureDetector(
                                    onTap: () {
                                      ModalEliminar(ds.id);
                                    },
                                    child: Icon(
                                      Icons.delete,
                                      color: widget.coloresRestaurante[3],
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
              context, MaterialPageRoute(builder: (context) => REG_cocina(alias: widget.alias,coloresRestaurante:widget.coloresRestaurante)));
        },
        child: Icon(Icons.add, color: widget.coloresRestaurante[3]),
        backgroundColor: widget.coloresRestaurante[2],
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
            backgroundColor: widget.coloresRestaurante[0],
            elevation: 0,
            title: Text(
              'Cocinas',
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
      body: Container(
        margin:
            EdgeInsets.only(left: 20.0, right: 20.0, top: 15.0, bottom: 45.0),
        child: Column(
          children: [
            Expanded(
              child: Todoslascocinas(),
            ),
          ],
        ),
      ),
    );
  }

  void ModalEliminar(String cocinaID) {
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
                  '¿Estás seguro que quieres eliminar esta Cocina? ',
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
                          await DatabaseMethods().Eliminarcocina(cocinaID);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Se ha eliminado una categoría',
                                style: TextStyle(color: widget.coloresRestaurante[3]),
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
                          foregroundColor: widget.coloresRestaurante[3],
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
                          foregroundColor: widget.coloresRestaurante[3],
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
