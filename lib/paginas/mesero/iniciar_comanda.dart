import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ngcomanda/paginas/mesero/detalle_mesa.dart';
import '../admin/mesa/mesa-service.dart';
import 'dart:math';

class ListaMesas extends StatefulWidget {
  final String alias;
  final String usuarioid;
      final List<Color?> coloresRestaurante;

  const ListaMesas({required this.alias,required this.usuarioid, required this.coloresRestaurante,Key? key}) : super(key: key);

  @override
  _ListaMesasState createState() => _ListaMesasState();
}

class _ListaMesasState extends State<ListaMesas> {
  String? cocinaSeleccionada;
  int filasPorPagina = 8; 
  int totalFilas = 34; 
  int paginaActual = 1; 
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
                  'No hay mesas disponibles',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.coloresRestaurante[4],
                  ),
                ),
              );
            }

            Map<String, List<DocumentSnapshot>> ordenesPorMesa = {};
            snapshot.data!.docs.forEach((orden) {
              var mesa = orden['mesa'];
              if (!ordenesPorMesa.containsKey(mesa)) {
                ordenesPorMesa[mesa] = [];
              }
              ordenesPorMesa[mesa]!.add(orden);
            });

            return SingleChildScrollView(
              child: Column(
                children: ordenesPorMesa.entries.map((entry) {
                  var mesa = entry.key;
                  var ordenes = entry.value;

                  return Column(
                    children: [
                      
                      ...ordenes.map((orden) {
                        List platillos = orden['platillos'];

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
                                            'Cantidad: ${platillo['cantidad']}',
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
                        );
                      }).toList(),
                     
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
                        'Mesas',
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
                          // Indicador de filas
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

                // Contenido principal
                Expanded(
                child: Container(
                  color: Color.fromARGB(255, 244, 247, 251),
                  child: Row(
                    children: [
                      

                      Expanded(
                      child: StreamBuilder<QuerySnapshot>(
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

                       

                        // Columna izquierda
                      return Expanded(
                      flex: 1,
                      child: Container(
                        
                        margin: EdgeInsets.symmetric(horizontal: 15.0), 
                        child: Center(


                          child: GridView.builder(
                           
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1,
                            ),
                            itemCount: (mesas.length / 2).ceil(),
                            itemBuilder: (ctx, rowIndex) {
                              int startIndex = rowIndex * 2;
                              int endIndex = startIndex + 2;

                              if (endIndex > mesas.length) {
                                endIndex = mesas.length;
                              }
                             return Expanded(
                            child: GridView.builder(
                              padding: EdgeInsets.only(right: 12.0, left: 10.0, top: 12.0, bottom: 12.0),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    
                              crossAxisCount: 4,
                              childAspectRatio: 0.99,
                              crossAxisSpacing: 18.0,
                              mainAxisSpacing: 16.0,
                          ),
                          itemCount: mesas.length,
                          itemBuilder: (context, index) {
                            var mesa = mesas[index];
                            var disponibilidad = mesa['disponibilidad'];
                            var comensales = mesa['comensales'];
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
                                                      mesa['nombre'],
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
                            child: SingleChildScrollView(
                              child: Column(
                                    children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                mesa['descripcion'],
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12.0,
                                                
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 5),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                              Text(
                                                  'Estado: $disponibilidad',
                                                  style: TextStyle(
                                                  color: Colors.grey, 
                                                ),
                                                ),
                                          ]),
                                            SizedBox(height: 20),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '${comensales} comensales',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 11.0,
                                                  ),
                                                ),
                                                
                                        
                                              
                                              ],
                                            ),
                                          
                                          ],
                                        ),
                            ]  )))])
                            ))))
                            );})
                      );})))
                      );
                      }})
                      ),

           // Columna derecha
              Container(
                width: 100,
                margin: EdgeInsets.only(top: 20, right: 8),
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
                      child: ListView.builder(
                        itemCount: 10, 
                        itemBuilder: (context, index) {
                          Color borderColor = index % 2 == 0 ? const Color.fromARGB(255, 135, 182, 161) : const Color.fromARGB(255, 228, 162, 176);
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
                      ),
                    ),
                  ],
                ),
              ),
                    ])
        ))])),
                  
            ],
          ),
        );
        }
        

          Stream<QuerySnapshot> obtenerOrdenes() {
          return FirebaseFirestore.instance.collection('Orden').where('alias', isEqualTo: widget.alias).snapshots();
        }
      }