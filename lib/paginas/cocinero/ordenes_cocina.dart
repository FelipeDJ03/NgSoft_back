import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'cocina_service.dart';

class OrdenesCocinaPage extends StatefulWidget {
  final String alias;

  OrdenesCocinaPage({required this.alias});

  @override
  _OrdenesCocinaPageState createState() => _OrdenesCocinaPageState();
}

class _OrdenesCocinaPageState extends State<OrdenesCocinaPage> {
  String? cocinaSeleccionada;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  
      body: Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    cocinaSeleccionada = null;
                  });
                },
                child: Text('General'),
              ),
            ),
          // StreamBuilder para mostrar los registros de la colección 'cocina' como botones
          StreamBuilder<QuerySnapshot>(
            stream: obtenerCocinas(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Text('No hay  cocinas');
              }
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: snapshot.data!.docs.map((doc) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            cocinaSeleccionada = doc['Id'];
                          });
                        },
                        child: Text(doc['nombre']), // Ajusta según los campos de tu documento
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: obtenerOrdenes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No hay órdenes disponibles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black,),));
                }
                // Organizar las órdenes por mesa
                Map<String, List<DocumentSnapshot>> ordenesPorMesa = {};
                snapshot.data!.docs.forEach((orden) {
                  var mesa = orden['mesa'];
                  if (!ordenesPorMesa.containsKey(mesa)) {
                    ordenesPorMesa[mesa] = [];
                  }
                  ordenesPorMesa[mesa]!.add(orden);
                });

                return OrientationBuilder(
                  builder: (context, orientation) {
                    if (orientation == Orientation.portrait) {
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: ordenesPorMesa.entries.map((entry) {
                            String mesa = entry.key;
                            List<DocumentSnapshot> ordenes = entry.value;

                            return Container(
                              margin: EdgeInsets.only(bottom: 9.0, left: 15, right: 15, top: 6),
                              child: Card(
                                color: Color(0xFFFFFDD0),
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(10.0),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFFFA500),
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            spreadRadius: 1,
                                            blurRadius: 5,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Mesa: $mesa',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(10.0),
                                      child: Column(
                                        children: ordenes.map((orden) {
                                          List platillos = orden['platillos'];

                                          // Agrupar platillos por ID y filtrar por estado
                                          Map<String, Map<String, dynamic>> platillosAgrupados = {};
                                          for (var platillo in platillos) {
                                            var id = platillo['Id']; // Assuming there's an 'id' field
                                            if (platillo['status'] == 'terminado') {
                                              continue; // Omitir platillos con estado 'terminado'
                                            }

                                            if (cocinaSeleccionada != null && platillo['cocina'] != cocinaSeleccionada) {
                                              continue; // Filtrar por cocina seleccionada
                                            }

                                            if (!platillosAgrupados.containsKey(id)) {
                                              platillosAgrupados[id] = {
                                                'nombre': platillo['nombre'],
                                                'imagen_url': platillo['imagen_url'],
                                                'cantidad': 0,
                                                'precio': platillo['precio'],
                                                'status': platillo['status'],
                                                'cocina': platillo['cocina'],
                                                'notas': [],
                                              };
                                            }
                                            platillosAgrupados[id]!['cantidad'] += platillo['cantidad'];
                                            platillosAgrupados[id]!['notas'].add(platillo['nota']);
                                          }

                                          return Column(
                                            children: platillosAgrupados.entries.map((entry) {
                                              var platillo = entry.value;

                                              return Container(
                                                margin: EdgeInsets.only(bottom: 15.0),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 2,
                                                      child: Image.network(
                                                        platillo['imagen_url'],
                                                        height: 100.0,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context, error, stackTrace) =>
                                                            Icon(Icons.food_bank, size: 80, color: Color(0xFFD2691E)),
                                                      ),
                                                    ),
                                                    SizedBox(width: 10.0),
                                                    Expanded(
                                                      flex: 4,
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            platillo['nombre'],
                                                            textAlign: TextAlign.left,
                                                            style: TextStyle(
                                                              color: Colors.black,
                                                              fontSize: 18.0,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          Text(
                                                            'Cantidad: ${platillo['cantidad']}',
                                                            textAlign: TextAlign.left,
                                                            style: TextStyle(
                                                              color: Colors.black,
                                                              fontSize: 14.0,
                                                            ),
                                                          ),
                                                          Text(
                                                            'Estado: ${platillo['status']}',
                                                            textAlign: TextAlign.left,
                                                            style: TextStyle(
                                                              color: Colors.black,
                                                              fontSize: 14.0,
                                                            ),
                                                          ),
                                                          Text(
                                                            'Cocina: ${platillo['cocina']}',
                                                            textAlign: TextAlign.left,
                                                            style: TextStyle(
                                                              color: Colors.black,
                                                              fontSize: 14.0,
                                                            ),
                                                          ),
                                                          Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: platillo['notas'].map<Widget>((nota) {
                                                              return Text(
                                                                'Nota: $nota',
                                                                style: TextStyle(color: Colors.black),
                                                              );
                                                            }).toList(),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(width: 10.0),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          if (platillo['status'] == 'pendiente')
                                                            TextButton(
                                                              onPressed: () => ModalEmpezar(
                                                                context,
                                                                orden.id,
                                                                entry.key, // ID del platillo
                                                                platillo['nombre'],
                                                                platillo['Id'], // ID del platillo
                                                              ),
                                                              child: Text('Empezar'),
                                                              style: TextButton.styleFrom(
                                                                foregroundColor: Colors.white,
                                                                backgroundColor: Colors.green,
                                                              ),
                                                            ),
                                                          if (platillo['status'] == 'empezado')
                                                            TextButton(
                                                              onPressed: () => ModalTerminar(
                                                                context,
                                                                orden.id,
                                                                entry.key, // ID del platillo
                                                                platillo['nombre'],
                                                                platillo['Id'],
                                                                orden['mesa'], // ID del platillo
                                                              ),
                                                              child: Text('Terminar'),
                                                              style: TextButton.styleFrom(
                                                                foregroundColor: Colors.white,
                                                                backgroundColor: Color(0xFFFFA500),
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    } else {
                      // Código para orientación horizontal (landscape)
                      return SingleChildScrollView(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: ordenesPorMesa.entries.map((entry) {
                            String mesa = entry.key;
                            List<DocumentSnapshot> ordenes = entry.value;

                            return Expanded(
                              child: Container(
                                margin: EdgeInsets.only(bottom: 9.0, left: 15, right: 15, top: 6),
                                child: Card(
                                  color: Color(0xFFFFFDD0),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(10.0),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFFFA500),
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.2),
                                              spreadRadius: 1,
                                              blurRadius: 5,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Mesa: $mesa',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(10.0),
                                        child: Column(
                                          children: ordenes.map((orden) {
                                            List platillos = orden['platillos'];

                                            // Agrupar platillos por ID y filtrar por estado
                                            Map<String, Map<String, dynamic>> platillosAgrupados = {};
                                            for (var platillo in platillos) {
                                              var id = platillo['Id']; // Assuming there's an 'id' field
                                              if (platillo['status'] == 'terminado') {
                                                continue; // Omitir platillos con estado 'terminado'
                                              }

                                              if (cocinaSeleccionada != null && platillo['cocina'] != cocinaSeleccionada) {
                                                continue; // Filtrar por cocina seleccionada
                                              }

                                              if (!platillosAgrupados.containsKey(id)) {
                                                platillosAgrupados[id] = {
                                                  'nombre': platillo['nombre'],
                                                  'imagen_url': platillo['imagen_url'],
                                                  'cantidad': 0,
                                                  'precio': platillo['precio'],
                                                  'status': platillo['status'],
                                                  'cocina': platillo['cocina'],
                                                  'notas': [],
                                                };
                                              }
                                              platillosAgrupados[id]!['cantidad'] += platillo['cantidad'];
                                              platillosAgrupados[id]!['notas'].add(platillo['nota']);
                                            }

                                            return Column(
                                              children: platillosAgrupados.entries.map((entry) {
                                                var platillo = entry.value;

                                                return Container(
                                                  margin: EdgeInsets.only(bottom: 15.0),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 2,
                                                        child: Image.network(
                                                          platillo['imagen_url'],
                                                          height: 100.0,
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (context, error, stackTrace) =>
                                                              Icon(Icons.food_bank, size: 80, color: Color(0xFFD2691E)),
                                                        ),
                                                      ),
                                                      SizedBox(width: 10.0),
                                                      Expanded(
                                                        flex: 4,
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              platillo['nombre'],
                                                              textAlign: TextAlign.left,
                                                              style: TextStyle(
                                                                color: Colors.black,
                                                                fontSize: 18.0,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                            Text(
                                                              'Cantidad: ${platillo['cantidad']}',
                                                              textAlign: TextAlign.left,
                                                              style: TextStyle(
                                                                color: Colors.black,
                                                                fontSize: 14.0,
                                                              ),
                                                            ),
                                                            Text(
                                                              'Estado: ${platillo['status']}',
                                                              textAlign: TextAlign.left,
                                                              style: TextStyle(
                                                                color: Colors.black,
                                                                fontSize: 14.0,
                                                              ),
                                                            ),
                                                            Text(
                                                              'Cocina: ${platillo['cocina']}',
                                                              textAlign: TextAlign.left,
                                                              style: TextStyle(
                                                                color: Colors.black,
                                                                fontSize: 14.0,
                                                              ),
                                                            ),
                                                            Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: platillo['notas'].map<Widget>((nota) {
                                                                return Text(
                                                                  'Nota: $nota',
                                                                  style: TextStyle(color: Colors.black),
                                                                );
                                                              }).toList(),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(width: 10.0),
                                                      Expanded(
                                                        flex: 2,
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            if (platillo['status'] == 'pendiente')
                                                              TextButton(
                                                                onPressed: () => ModalEmpezar(
                                                                  context,
                                                                  orden.id,
                                                                  entry.key, // ID del platillo
                                                                  platillo['nombre'],
                                                                  platillo['Id'], // ID del platillo
                                                                ),
                                                                child: Text('Empezar'),
                                                                style: TextButton.styleFrom(
                                                                  foregroundColor: Colors.white,
                                                                  backgroundColor: Colors.green,
                                                                ),
                                                              ),
                                                            if (platillo['status'] == 'empezado')
                                                              TextButton(
                                                                onPressed: () => ModalTerminar(
                                                                  context,
                                                                  orden.id,
                                                                  entry.key, // ID del platillo
                                                                  platillo['nombre'],
                                                                  platillo['Id'],
                                                                  orden['mesa'], // ID del platillo
                                                                ),
                                                                child: Text('Terminar'),
                                                                style: TextButton.styleFrom(
                                                                  foregroundColor: Colors.white,
                                                                  backgroundColor: Color(0xFFFFA500),
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Stream<QuerySnapshot> obtenerOrdenes() {
    return FirebaseFirestore.instance.collection('Orden').where('alias', isEqualTo: widget.alias).snapshots();
  }
  Stream<QuerySnapshot> obtenerCocinas() {
    return FirebaseFirestore.instance.collection('cocina').where('alias', isEqualTo: widget.alias).snapshots();
  }

  void ModalEmpezar(BuildContext context, String ordenId, String platilloID, String platilloNombre, platillo) {
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
                  Icons.question_mark_outlined, 
                  color: Color(0xFFFFA500),
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
                  '¿Estás seguro de que deseas empezar a cocinar el platillo "$platilloNombre"?',
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
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Llamar al servicio para actualizar el estado
                          CocinaService().empezarCocinar(ordenId, platilloID);
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.green,
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
                          foregroundColor: Colors.white, backgroundColor: Colors.red,
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

  void ModalTerminar(BuildContext context, String ordenId, String platilloID, String platilloNombre, platillo, String mesa) {
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
                  color: Color(0xFFFFA500), 
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
                  '¿Estás seguro de que el platillo "$platilloNombre" ha sido terminado?',
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
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Llamar al servicio para actualizar el estado
                          CocinaService().terminarCocinar(ordenId, platilloID, mesa,widget.alias);
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
