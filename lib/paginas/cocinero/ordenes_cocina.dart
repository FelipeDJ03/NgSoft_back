import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:ngcomanda/paginas/cocinero/ordenes_cocina_por_cocinas.dart';
import 'cocina_service.dart';
import 'dart:math';

class OrdenesCocinaPage extends StatefulWidget {
  final String alias;
  final List<Color?> coloresRestaurante;

  OrdenesCocinaPage({required this.alias, required this.coloresRestaurante});


  @override
  _OrdenesCocinaPageState createState() => _OrdenesCocinaPageState();
}

class _OrdenesCocinaPageState extends State<OrdenesCocinaPage> {
  String? cocinaSeleccionada;
  
  int filasPorPagina = 8; 
  int totalFilas = 34; 
  int paginaActual = 1;

  @override
  Widget build(BuildContext context) { 
    return Scaffold(
      body: Row(
        children: [
//columna izquierda
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
                        'Pedidos por Mesas',
                        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold), 
                      ),
                      Row(
                        children: [
                          Text('Filas por página', style: TextStyle(color: Colors.grey, fontSize: 12.0)), 
                          SizedBox(width: 15),
                          // Selector de filas por página
                          DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: filasPorPagina,
                              items: [8, 16, 32].map((int value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text(value.toString(), style: TextStyle(color: Colors.grey, fontSize: 12.0)), 
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  filasPorPagina = newValue!;
                                });
                              },
                            ), 
                          ),
                          SizedBox(width: 28.0),
                          Row(
                            children: [
                              Text('${(paginaActual - 1) * filasPorPagina + 1} - ${min(paginaActual * filasPorPagina, totalFilas)} de $totalFilas filas', style: TextStyle(color: Colors.grey, fontSize: 12.0)), 
                            ],
                          ),
                          SizedBox(width: 25.0),
                          IconButton(
                            icon: Icon(color: Colors.grey, Icons.chevron_left),
                            onPressed: () {
                              setState(() {
                                if (paginaActual > 1) {
                                  paginaActual--;
                                }
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(color: Colors.grey, Icons.chevron_right),
                            onPressed: () {
                              setState(() {
                                if (paginaActual < (totalFilas / filasPorPagina).ceil()) {
                                  paginaActual++;
                                }
                              });
                            },
                          ),
                          SizedBox(width: 25.0),
                          // Icono de notificación
                          Stack(
                            children: [
                              IconButton(
                                icon: Icon(Icons.notifications, color: Colors.grey,),
                                onPressed: () {
                                  // Acción al tocar el icono de notificaciones
                                },
                              ),
                            ],
                          ),
                          SizedBox(width: 20.0),
                          Container(
                            height: 40.0,
                            child: VerticalDivider(
                              thickness: 1,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nombre del Usuario', 
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.0), 
                              ),
                              Text(
                                'Rol del Usuario', 
                                style: TextStyle(color: Colors.grey, fontSize: 10.0), 
                              ),
                            ],
                          ),
                          SizedBox(width: 18.0),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2), 
                            ),
                            child: ClipOval(
                              child: CircleAvatar(
                                backgroundImage: NetworkImage('URL_DE_LA_IMAGEN'), 
                                radius: 18,
                              ),
                            ),
                          ),
                          SizedBox(width: 20.0),
                        ],
                      ),
                    ],
                  ),
                ),

               Row(
              children: [
                Container(
                  color: Color.fromARGB(255, 244, 247, 251), 
                  padding: EdgeInsets.only(left: 30, right: 5, top: 2, bottom: 5), 
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start, 
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); 
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrdenesCocina_porCocinaPage(
                                alias: widget.alias, 
                                coloresRestaurante: widget.coloresRestaurante,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: widget.coloresRestaurante[2],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        child: Text('Ver por cocinas'),
                      ),
                      SizedBox(width: 15.0),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            cocinaSeleccionada = null;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: widget.coloresRestaurante[2], 
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0), 
                          ),
                        ),
                        child: Text('General'), 
                      ),
                    ],
                  ),
                ),
                
                Expanded( 
                  child: StreamBuilder<QuerySnapshot>(
                    stream: obtenerCocinas(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return LinearProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Text('No hay cocinas');
                      }
                      return Container(
                        color: Color.fromARGB(255, 244, 247, 251), 
                        padding: EdgeInsets.only(left: 30, right: 5, top: 2, bottom: 5), 
                        child: SingleChildScrollView(
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
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white, 
                                    backgroundColor: widget.coloresRestaurante[2], 
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0), 
                                    ),
                                  ),
                                  child: Text(doc['nombre']),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
              // Contenido principal
                Expanded(
                child: Container(
                  color: Color.fromARGB(255, 244, 247, 251),
                  child: Row(
                    children: [                     
                      Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: obtenerOrdenes(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return Center(child: Text('No hay órdenes disponibles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: widget.coloresRestaurante[4],),));
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

                        // Columna izquierda
                      return Expanded(
                      flex: 1,
                      child: Container(
                        
                        margin: EdgeInsets.symmetric(horizontal: 15.0), 
                        child: Center(
                          child: GridView.builder(
                            padding: EdgeInsets.only(right: 12.0, left: 10.0, top: 12.0),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 0.8,
                              crossAxisSpacing: 18.0,
                              mainAxisSpacing: 16.0,
                            ),
                            itemCount: ordenesPorMesa.entries.length, 
                            itemBuilder: (context, index) {
                       
                              var entry = ordenesPorMesa.entries.elementAt(index);
                              String mesa = entry.key;
                              List<DocumentSnapshot> ordenes = entry.value;
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
                                                      'Orden #${index + 1}',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16.0,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Mesa #$mesa', 
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 12.0, 
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end, 
                                                  children: [
                                                    Text(
                                                      '16:00', 
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 14.0,
                                                      ),
                                                    ),
                                                    Text(
                                                      '08:28 PM', // Tiempo
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 12.0
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 10), 
                                          ],
                               ),
                      Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: ordenes.map((orden) {
                            List platillos = orden['platillos'];

                            // Agrupar platillos por ID y filtrar por estado
                            Map<String, Map<String, dynamic>> platillosAgrupados = {};
                            for (var platillo in platillos) {
                              var id = platillo['Id'];
                              if (platillo['status'] == 'terminado') continue;
                              if (cocinaSeleccionada != null && platillo['cocina'] != cocinaSeleccionada) continue;

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
                                            fontWeight: FontWeight.bold
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
                                                  orden.id,
                                                  entry.key, 
                                                  platillo['nombre'],
                                                  platillo['Id'], 
                                                ),
                                                child: Text('Empezar',
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
                                                  orden.id,
                                                  entry.key, 
                                                  platillo['nombre'],
                                                  platillo['Id'],
                                                  orden['mesa'], 
                                                ),
                                                child: Text('Terminar',
                                                style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 11.0,
                                              ),),
                                                
                                              ),
                                        ],
                                      ),
                                      Divider(),
                                    ],
                                  ),
                                  
                                );
                                
                              }).toList(),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    // Contenido en la parte inferior
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'x3 Platillos',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14.0,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                margin: EdgeInsets.only(right: 5.0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color.fromARGB(255, 228, 162, 176),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(7),
                                  color: Colors.white,
                                ),
                                child: Icon(
                                  Icons.clear,
                                  color: const Color.fromARGB(255, 228, 162, 176),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color.fromARGB(255, 135, 182, 161),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(7),
                                  color: Colors.white,
                                ),
                                child: Icon(
                                  Icons.check,
                                  color: const Color.fromARGB(255, 135, 182, 161),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ]),)));}))));
                  },
                )
              ),

// Columna derecha
       Container(
  width: 100,
  margin: EdgeInsets.only(top: 0, right: 8),
  alignment: Alignment.centerRight,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(
        'Orden list',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16.0,
        ),
      ),
      SizedBox(height: 10),
      Expanded(
        child: StreamBuilder<QuerySnapshot>(
          stream: obtenerOrdenes(), // Stream de órdenes desde Firestore
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No hay órdenes disponibles'));
            }

            // Crear la lista de órdenes con colores según el estado de los platillos
            return ListView.builder(
              itemCount: snapshot.data!.docs.length, // Número de órdenes
              itemBuilder: (context, index) {
                var orden = snapshot.data!.docs[index];
                List platillos = orden['platillos'];

                // Verificar si todos los platillos están en estado 'terminado'
                bool todosTerminados = platillos.every((platillo) => platillo['status'] == 'terminado');
                Color borderColor = todosTerminados
                    ? Colors.green // Verde si todos están terminados
                    : Colors.red;  // Rojo si alguno no está terminado

                return Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  padding: EdgeInsets.only(left: 8, right: 8, top: 12, bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: borderColor, width: 1),
                      bottom: BorderSide(color: borderColor, width: 1),
                      left: BorderSide(color: borderColor, width: 1),
                      right: BorderSide(color: borderColor, width: 6),
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                      topRight: Radius.zero,
                      bottomRight: Radius.zero,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '# ${index + 1}',
                      style: TextStyle(color: borderColor),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    ],
  ),
)

      ],
    ),
  ),
  )]
  )
  ),
  
  ])
);
  }
  
  Stream<QuerySnapshot> obtenerCocinas() {
    return FirebaseFirestore.instance.collection('cocina').where('alias', isEqualTo: widget.alias).snapshots();
  }
  Stream<QuerySnapshot> obtenerOrdenes() {
    return FirebaseFirestore.instance.collection('Orden').where('alias', isEqualTo: widget.alias).snapshots();
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
