import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:ngcomanda/paginas/cocinero/ordenes_cocina.dart';
import 'cocina_service.dart';
import 'dart:math';


class OrdenesCocina_porCocinaPage extends StatefulWidget {
  final String alias;
    final List<Color?> coloresRestaurante;

  OrdenesCocina_porCocinaPage({required this.alias,required this.coloresRestaurante});

  @override
  _OrdenesCocina_porCocinaPageState createState() => _OrdenesCocina_porCocinaPageState();
}


class _OrdenesCocina_porCocinaPageState extends State<OrdenesCocina_porCocinaPage> {

  String? cocinaSeleccionada;
  
  int filasPorPagina = 8; 
  int totalFilas = 34; 
  int paginaActual = 1; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
       Container(
  width: 250,
  color: widget.coloresRestaurante[0],
  padding: EdgeInsets.only(top: 18, bottom: 15),
  child: Column(
    children: [
      SizedBox(height: 16.0),
      Image.asset(
        'assets/logo2.png',
        height: 100.0,
      ),
      SizedBox(height: 16.0),
      Text(
        'Combos de Pedidos',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: 10.0),
      Divider(color: Colors.white),
      Expanded(
        child: StreamBuilder<QuerySnapshot>(
          stream: obtenerOrdenes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  'No hay órdenes disponibles',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.coloresRestaurante[4],
                  ),
                ),
              );
            }

            // Mapa para agrupar platillos de todas las órdenes
            Map<String, Map<String, dynamic>> platillosAgrupados = {};

            // Iteramos sobre cada orden y sobre cada platillo en esa orden
            snapshot.data!.docs.forEach((orden) {
              List platillos = orden['platillos'];

              for (var platillo in platillos) {
                var id = platillo['Id'];

                // Excluir platillos terminados
                if (platillo['status'] == 'terminado') continue;

                // Filtrar por cocina seleccionada si es necesario
                if (cocinaSeleccionada != null && platillo['cocina'] != cocinaSeleccionada) continue;

                // Agrupación de platillos a nivel general
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
                // Sumar cantidad del platillo
                platillosAgrupados[id]!['cantidad'] += platillo['cantidad'];
                platillosAgrupados[id]!['notas'].add(platillo['nota']);
              }
            });

            // Mostrar los platillos agrupados globalmente
            return SingleChildScrollView(
              child: Column(
                children: platillosAgrupados.entries.map((entry) {
                  var platillo = entry.value;
                  return Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 28.0),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(platillo['imagen_url']),
                            onBackgroundImageError: (exception, stackTrace) => Icon(
                              Icons.food_bank,
                              size: 80,
                              color: widget.coloresRestaurante[2],
                            ),
                          ),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                platillo['nombre'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.0,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 5),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: platillo['notas'].map<Widget>((nota) {
                                return Text(
                                  'Nota: $nota',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.0,
                                  ),
                                );
                              }).toList(),
                            ),
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Cantidad total: ${platillo['cantidad']}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 19.0),
                        child: Divider(color: Colors.white),
                      ),
                    ],
                  );
                }).toList(),
              ),
            );
          },
        ),
      ),
    ],
  ),
),


          Expanded(
            child: Column(
              children: [
                // AppBar
                Container(
                  color: Color.fromARGB(255, 244, 247, 251),
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pedidos por Cocinas',
                        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold), 
                      ),
        ]),
                ),
                Container(
                  color: Color.fromARGB(255, 244, 247, 251), 
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 30, right: 5, top: 2, bottom: 5), 
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrdenesCocinaPage(
                                  alias: widget.alias,
                                  coloresRestaurante: widget.coloresRestaurante,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white, 
                            backgroundColor: widget.coloresRestaurante[2], 
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0), 
                            ),
                          ),
                          child: Text('Ver por Mesas'),
                        ),
                      ),
                    ],
                  ),
                ),

                // Contenido principal
                Expanded(
                child: Container(
                  color: Color.fromARGB(255, 244, 247, 251),
                  child: Row(
                    children: [
                      

                      Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: obtenerCocinas(),
                        builder: (context, cocinaSnapshot) {
                          if (cocinaSnapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (!cocinaSnapshot.hasData || cocinaSnapshot.data!.docs.isEmpty) {
                            return Center(child: Text('No hay cocinas disponibles'));
                          }

                        // Columna izquierda
                      return Expanded(
                      flex: 1,
                      child: Container(                
                        margin: EdgeInsets.symmetric(horizontal: 15.0,), 
                        child: Center(
                          child: GridView.builder(
                            padding: EdgeInsets.only(right: 12.0, left: 10.0, top: 12.0, bottom: 12.0),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.99,
                              crossAxisSpacing: 18.0,
                              mainAxisSpacing: 16.0,
                            ),
                            itemCount: cocinaSnapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                            DocumentSnapshot cocina = cocinaSnapshot.data!.docs[index];
                              return Container(
                                margin: EdgeInsets.all(0),
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3), 
                                      spreadRadius: 2, 
                                      blurRadius: 6, 
                                      offset: Offset(0, 3), 
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(12), 
                                  color: Colors.white, 
                                ),
                                child: InkWell(
                                onTap: () {},

                                child: Card(
                                  color: Colors.white, 
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12), 
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(20.0), 
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                                      crossAxisAlignment: CrossAxisAlignment.start, 
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start, 
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start, 
                                                  children: [
                                                    Text(
                                                      cocina['nombre'],
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16.0,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              
                                              ],
                                            ),
                                            Divider(),
                                            SizedBox(height: 10), 
                                          ],
                                        ),                        
                                    Expanded(
                                          child: StreamBuilder<QuerySnapshot>(
                                            stream: obtenerOrdenes(), 
                                            builder: (context, ordenSnapshot) {
                                              if (ordenSnapshot.connectionState == ConnectionState.waiting) {
                                                return Center(child: CircularProgressIndicator());
                                              }
                                              if (!ordenSnapshot.hasData || ordenSnapshot.data!.docs.isEmpty) {
                                                return Center(child: Text('No hay órdenes disponibles'));
                                              }

                                              // Filtrar y agrupar platillos por cocina
                                              List<Map<String, dynamic>> productosPorCocina = [];
                                              for (var orden in ordenSnapshot.data!.docs) {
                                                List<dynamic> platillos = orden['platillos'];
                                                for (var platillo in platillos) {
                                                  if (platillo['status'] == 'terminado') continue; 
                                                  if (platillo['cocina'] == cocina.id) {
                                                    productosPorCocina.add({
                                                      ...platillo,
                                                      'orden_id': orden.id, 
                                                      'mesa': orden['mesa'], 
                                                    });
                                                  }
                                                }
                                              }

                                              // Agrupar platillos por ID
                                              Map<String, Map<String, dynamic>> platillosAgrupados = {};
                                              for (var platillo in productosPorCocina) {
                                                var id = platillo['Id'];
                                                if (!platillosAgrupados.containsKey(id)) {
                                                  platillosAgrupados[id] = {
                                                    'nombre': platillo['nombre'],
                                                    'imagen_url': platillo['imagen_url'],
                                                    'cantidad': 0,
                                                    'precio': platillo['precio'],
                                                    'status': platillo['status'],
                                                    'cocina': platillo['cocina'],
                                                    'notas': [],
                                                    'orden_id': platillo['orden_id'],
                                                    'mesa': platillo['mesa'],
                                                  };
                                                }
                                                platillosAgrupados[id]!['cantidad'] += platillo['cantidad'];
                                                platillosAgrupados[id]!['notas'].add(platillo['nota']);
                                              }

                                              return SingleChildScrollView(
                                                child: Column(
                                                  children: platillosAgrupados.entries.map((entry) {
                                                    var platillo = entry.value;

                                                    return ListTile(
                                                      contentPadding: EdgeInsets.symmetric(horizontal: 0.0),
                                                      leading: Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          color: Colors.white,
                                                          border: Border.all(color: Colors.black, width: 2),
                                                        ),
                                                        child: CircleAvatar(
                                                          backgroundImage: NetworkImage(platillo['imagen_url']),
                                                          onBackgroundImageError: (exception, stackTrace) => Icon(
                                                            Icons.food_bank,
                                                            size: 80,
                                                            color: widget.coloresRestaurante[2],
                                                          ),
                                                        ),
                                                      ),
                                                      title: Row(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              platillo['nombre'],
                                                              style: TextStyle(
                                                                color: Colors.black,
                                                                fontSize: 12.0,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      subtitle: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          SizedBox(height: 5),
                                                          Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: platillo['notas'].map<Widget>((nota) {
                                                              return Text(
                                                                'Nota: $nota',
                                                                style: TextStyle(
                                                                  color: Colors.grey,
                                                                  fontSize: 10.0,
                                                                ),
                                                              );
                                                            }).toList(),
                                                          ),
                                                          SizedBox(height: 5),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.end,
                                                            children: [
                                                              Text(
                                                                'Cantidad: ${platillo['cantidad']}',
                                                                style: TextStyle(
                                                                  color: Colors.black,
                                                                  fontSize: 11.0,
                                                                ),
                                                              ),
                                                              SizedBox(width: 2),
                                                              Container(
                                                                height: 15.0,
                                                                child: VerticalDivider(
                                                                  thickness: 1,
                                                                  color: Colors.grey,
                                                                ),
                                                              ),
                                                              if (platillo['status'] == 'pendiente')
                                                                TextButton(
                                                                  onPressed: () => ModalEmpezar(
                                                                    context,
                                                                    platillo['orden_id'], 
                                                                    entry.key, 
                                                                    platillo['nombre'],
                                                                    platillo['Id'],
                                                                  ),
                                                                  child: Text(
                                                                    'Empezar',
                                                                    style: TextStyle(
                                                                      color: Colors.black,
                                                                      fontSize: 11.0,
                                                                    ),
                                                                  ),
                                                                ),
                                                              if (platillo['status'] == 'empezado')
                                                                TextButton(
                                                                  onPressed: () => ModalTerminar(
                                                                    context,
                                                                    platillo['orden_id'], 
                                                                    entry.key, 
                                                                    platillo['nombre'],
                                                                    platillo['Id'],
                                                                    platillo['mesa'],
                                                                  ),
                                                                  child: Text(
                                                                    'Terminar',
                                                                    style: TextStyle(
                                                                      color: Colors.black,
                                                                      fontSize: 11.0,
                                                                    ),
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                          Divider(),
                                                        ],
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                    
                                      ]),))));}))));
                                    },
                                  )
                                ),
                             // Columna derecha
                             ],
                        ),
                      ),
                      )]
                      )
                      ),
                      
                      ])
                    );
                      }
  
  // Función para obtener las cocinas desde Firestore
  Stream<QuerySnapshot> obtenerCocinas() {
    return FirebaseFirestore.instance.collection('cocina').snapshots();
  }

  
  Stream<QuerySnapshot> obtenerOrdenes() {
    return FirebaseFirestore.instance.collection('Orden').where('alias', isEqualTo: widget.alias).snapshots();
  }
  Stream<QuerySnapshot> obtenerMesas() {
    return FirebaseFirestore.instance.collection('mesa').where('alias', isEqualTo: widget.alias).snapshots();
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
                  Icons.question_mark_outlined, 
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
                          foregroundColor: widget.coloresRestaurante[3], backgroundColor: const Color.fromARGB(255, 135, 182, 161),
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
                          foregroundColor: widget.coloresRestaurante[3], backgroundColor: const Color.fromARGB(255, 228, 162, 176),
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
                          foregroundColor: widget.coloresRestaurante[3], 
                          backgroundColor: const Color.fromARGB(255, 135, 182, 161),
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
                          backgroundColor: const Color.fromARGB(255, 228, 162, 176),
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
  }}
