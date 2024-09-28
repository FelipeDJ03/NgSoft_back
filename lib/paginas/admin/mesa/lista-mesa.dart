import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ngcomanda/paginas/admin/mesa/editar-mesa.dart';
import 'package:ngcomanda/paginas/admin/mesa/registrar-mesa.dart';
import 'package:ngcomanda/paginas/splash.dart';
import 'mesa-service.dart';

class ListaMesa extends StatefulWidget {
  final String alias;
  const ListaMesa({super.key,required this.alias});

  @override
  _ListaMesaState createState() => _ListaMesaState();
}

class _ListaMesaState extends State<ListaMesa> {
  Stream<QuerySnapshot>? mesaStream;

  @override
  void initState() {
    super.initState();
    getontheload();
  }

  void editarDetallesmesa(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Editarmesa(userId: userId),
      ),
    );
  }

  void getontheload() async {
    mesaStream = await DatabaseMethods().Obtenermesas(widget.alias);
    setState(() {});
  }

  Widget Todoslasmesas() {
    return StreamBuilder<QuerySnapshot>(
      stream: mesaStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SplashPantalla(); 
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}')); 
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No hay mesas disponibles.'));
        } else {
          var mesas = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: (mesas.length / 2).ceil(),
            itemBuilder: (context, rowIndex) {
              int startIndex = rowIndex * 2;
              int endIndex = startIndex + 2;

              if (endIndex > mesas.length) {
                endIndex = mesas.length;
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(2, (index) {
                  if (startIndex + index >= mesas.length) {
                    return Expanded(child: Container()); 
                  }
                  var mesa = mesas[startIndex + index];
                  String disponibilidad = mesa['disponibilidad'];
                  Color containerColor = disponibilidad == 'Disponible' ? Color(0xFFFFA500) : Color(0xFFD2691E);

                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.all(10.0),
                      child: Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: containerColor,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "${mesa['nombre']}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "${mesa['descripcion']}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "${mesa['comensales']} comensales",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17.0,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit_note_sharp, color: Colors.white),
                                    onPressed: () {
                                      editarDetallesmesa(mesa.id);
                                    },
                                  ),
                                  SizedBox(width: 8.0),
                                  IconButton(
                                    icon: Icon(Icons.delete_outline, color: Colors.white, size: 20),
                                    onPressed: () async {
                                      await DatabaseMethods().Eliminarmesa(mesa.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Se ha eliminado una Mesa',
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
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          );
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
            context, 
            MaterialPageRoute(builder: (context) => REG_Mesa(alias:widget.alias))
          );
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
              'Mesas',
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
        margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 15.0, bottom: 45.0),
        child: Todoslasmesas(),
      ),
    );
  }
}
