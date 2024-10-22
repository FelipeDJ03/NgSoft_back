import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ngcomanda/paginas/admin/mesa/editar-mesa.dart';
import 'package:ngcomanda/paginas/admin/mesa/registrar-mesa.dart';
import 'package:ngcomanda/paginas/splash.dart';
import 'mesa-service.dart';

class ListaMesa extends StatefulWidget {
  final String alias;
    final List<Color?> coloresRestaurante;

  const ListaMesa({super.key, required this.alias,required this.coloresRestaurante});

  @override
  _ListaMesaState createState() => _ListaMesaState();
}

class _ListaMesaState extends State<ListaMesa> {
  Stream<QuerySnapshot>? mesaStream;
  TextEditingController searchController = TextEditingController();
  String searchText = '';

  @override 
  void initState() {
    super.initState();
    getontheload();
  }

  void editarDetallesmesa(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Editarmesa(userId: userId,coloresRestaurante:widget.coloresRestaurante),
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

          // Apply search filter
          var filteredMesas = mesas.where((mesa) {
            String mesaNombre = mesa['nombre'].toString().toLowerCase();
            return mesaNombre.contains(searchText.toLowerCase());
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: (filteredMesas.length / 2).ceil(),
            itemBuilder: (context, rowIndex) {
              int startIndex = rowIndex * 2;
              int endIndex = startIndex + 2;

              if (endIndex > filteredMesas.length) {
                endIndex = filteredMesas.length;
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(2, (index) {
                  if (startIndex + index >= filteredMesas.length) {
                    return Expanded(child: Container());
                  }
                  var mesa = filteredMesas[startIndex + index];
                  String disponibilidad = mesa['disponibilidad'];
                  Color containerColor = disponibilidad == 'Disponible'
                      ? widget.coloresRestaurante[1]!
                      : widget.coloresRestaurante[2]!;

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
                                  color: widget.coloresRestaurante[3],
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "${mesa['descripcion']}",
                                style: TextStyle(
                                  color: widget.coloresRestaurante[3],
                                  fontSize: 17.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "${mesa['comensales']} comensales",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: widget.coloresRestaurante[3],
                                  fontSize: 17.0,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit_note_sharp, color: widget.coloresRestaurante[3]),
                                    onPressed: () {
                                      editarDetallesmesa(mesa.id);
                                    },
                                  ),
                                  SizedBox(width: 8.0),
                                  GestureDetector(
                                    onTap: () {
                                      ModalEliminar(mesa.id);
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
            MaterialPageRoute(builder: (context) => REG_Mesa(alias: widget.alias,coloresRestaurante:widget.coloresRestaurante)
          ));
        },
        child: Icon(Icons.add, color: widget.coloresRestaurante[3]),
        backgroundColor: widget.coloresRestaurante[0],
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
            title: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Buscar mesa...',
                hintStyle: TextStyle(color: widget.coloresRestaurante[3]),
                border: InputBorder.none,
              ),
              style: TextStyle(color: widget.coloresRestaurante[3], fontSize: 18.0),
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
            ),
            centerTitle: true,
            iconTheme: IconThemeData(
              color: widget.coloresRestaurante[3],
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


  void ModalEliminar(String mesaID) {
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
                  '¿Estás seguro que quieres eliminar esta Mesa?',
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
                          await DatabaseMethods().Eliminarmesa(mesaID);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Se ha eliminado una categoría',
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