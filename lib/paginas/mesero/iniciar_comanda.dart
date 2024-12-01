import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ngcomanda/paginas/mesero/detalle_mesa.dart';
import '../admin/mesa/mesa-service.dart';

class ListaMesas extends StatefulWidget {
  final String alias;
  final String usuarioid;
      final List<Color?> coloresRestaurante;

  const ListaMesas({required this.alias,required this.usuarioid, required this.coloresRestaurante,Key? key}) : super(key: key);

  @override
  _ListaMesasState createState() => _ListaMesasState();
}

class _ListaMesasState extends State<ListaMesas> {
  

  Stream<QuerySnapshot>? _mesasStream;

  @override
  void initState() {
    super.initState();
    _obtenerMesas();
  }

  void _obtenerMesas() async {
    _mesasStream = await DatabaseMethods().Obtenermesas(widget.alias);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 247, 246, 244),
      appBar: AppBar(
        title: Text(
          'Mesas',
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
        backgroundColor: widget.coloresRestaurante[0],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _mesasStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No hay mesas disponibles.'));
          } else {
            var mesas = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(10.0),
              itemCount: (mesas.length / 2).ceil(),
              itemBuilder: (ctx, rowIndex) {
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
                    var disponibilidad = mesa['disponibilidad'];
                    var comensales = mesa['comensales'];
                    Color cardColor = disponibilidad == 'Disponible' ? widget.coloresRestaurante[1]! : widget.coloresRestaurante[2]!;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrdenMesaPantalla(mesa: mesa,alias:widget.alias,usuarioid:widget.usuarioid,coloresRestaurante:widget.coloresRestaurante),
                            ),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.all(10.0),
                          child: Material(
                            elevation: 5.0,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: cardColor,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    mesa['nombre'],
                                    style: TextStyle(
                                      color: widget.coloresRestaurante[3],
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    mesa['descripcion'],
                                    style: TextStyle(
                                      color: widget.coloresRestaurante[3],
                                      fontSize: 17.0,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    '(${comensales} comensales)',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17.0,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Estado: $disponibilidad',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
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
      ),
    );
  }
}
