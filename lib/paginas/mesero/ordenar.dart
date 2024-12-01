import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'orden-service.dart'; // Importar el servicio

class OrdenarPantalla extends StatefulWidget {
  final String mesaId;
  final String alias;
      final List<Color?> coloresRestaurante;

  OrdenarPantalla({required this.mesaId,required this.alias,required this.coloresRestaurante});

  @override
  _OrdenarPantallaState createState() => _OrdenarPantallaState();
}

class _OrdenarPantallaState extends State<OrdenarPantalla> {
  List<Map<String, dynamic>> _platillos = [];
  ValueNotifier<double> _total = ValueNotifier<double>(0.0);
  ValueNotifier<int> _tiempoEstimado = ValueNotifier<int>(0);

  void _calcularTotal() {
    _total.value = _platillos.fold(
      0.0,
      (sum, item) => sum + item['precio'] * item['cantidad'],
    );
  }

void _calcularTiempoEstimado() {
  _tiempoEstimado.value = _platillos.fold<int>(
    0,
    (sum, item) {
      // Imprimir el valor de 'tiempo' para verificarlo
      print("Tiempo de ${item['nombre']}: ${item['tiempo']}");
      return sum + ((item['tiempo'] ?? 0) as num).toInt();
    },
  );

  print("Tiempo total estimado: $_tiempoEstimado");
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 247, 246, 244), // Color de fondo
      appBar: AppBar(
        title: Text('Ordenar - Mesa ${widget.mesaId}', style: TextStyle(color: widget.coloresRestaurante[3])),
        backgroundColor: widget.coloresRestaurante[0],
        iconTheme: IconThemeData(
          color: widget.coloresRestaurante[3],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Carrito_platillo')
                    .where('mesa', isEqualTo: widget.mesaId)
                    .snapshots(),
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No hay platillos en el carrito.'));
                  } else {
                    var carrito = snapshot.data!.docs;

                    // Agrupar los productos por comensal
                    Map<int, List<DocumentSnapshot>> productosPorComensal = {};
                    for (var producto in carrito) {
                      int comensal = producto['comensal'];
                      if (!productosPorComensal.containsKey(comensal)) {
                        productosPorComensal[comensal] = [];
                      }
                      productosPorComensal[comensal]!.add(producto);
                    }
                    // Ordenar los comensales en forma ascendente
                    var comensalesOrdenados = productosPorComensal.keys.toList()..sort();

                    // Guardar platillos para enviar y calcular el total
                    _platillos = carrito.map((doc) {
                      return {
                        'Id': doc['Id'],
                        'nombre': doc['nombre'],
                        'precio': doc['precio'],
                        'cantidad': doc['cantidad'],
                        'comensal': doc['comensal'],
                        'nota': doc['nota'],
                        'imagen_url': doc['imagen_url'],
                        'alias':widget.alias,
                        'cocina':doc['cocina'],
                        'categoria':doc['categoria'],
                         'tiempo':doc['tiempo'],
                        'disponibilidad_inventario':doc['disponibilidad_inventario'],
                      };
                    }).toList();

                    // Calcular el nuevo total y actualizar el ValueNotifier
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _calcularTiempoEstimado();
                      _calcularTotal();
                
                    });

                    return ListView.builder(
                      itemCount: productosPorComensal.length,
                      itemBuilder: (ctx, index) {
                        int comensal = comensalesOrdenados[index]; // Obtener el comensal en orden ascendente
                        var productos = productosPorComensal[comensal];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Comensal $comensal',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8,),
                            ...productos!.map((productoCarrito) {
                              return Container(
                                margin: EdgeInsets.only(bottom: 17.0),
                                child: Material(
                                  elevation: 5.0, 
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.only(bottom: 5.0, left: 18, right: 18, top: 5.0),
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      color: widget.coloresRestaurante[1],
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Row(
                                      children: [                                                                          
                                        Expanded(
                                          flex: 4,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${productoCarrito['nombre']}",
                                                style: TextStyle(
                                                  color: widget.coloresRestaurante[3],
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              
                                              Text(
                                                "Cantidad: ${productoCarrito['cantidad']}",
                                                style: TextStyle(
                                                  color: widget.coloresRestaurante[3],
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                            
                                              Text(
                                                "Nota: ${productoCarrito['nota']}",
                                                style: TextStyle(
                                                  color: widget.coloresRestaurante[3],
                                                  fontSize: 15.0,
                                                ),
                                              ),
                                            
                                              Text(
                                                "\$${productoCarrito['precio']}",
                                                style: TextStyle(
                                                  color: widget.coloresRestaurante[3],
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                "Tiempo:${productoCarrito['tiempo']} min",
                                                style: TextStyle(
                                                  color: widget.coloresRestaurante[3],
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 25.0),
                                        Expanded(
                                          flex: 6,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Image.network(
                                                productoCarrito['imagen_url'],
                                                height: 110.0,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) => Icon(
                                                  Icons.food_bank,
                                                  size: 90,
                                                  color: widget.coloresRestaurante[3],
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () async {
                                                      await FirebaseFirestore.instance
                                                          .collection('Carrito_platillo')
                                                          .doc(productoCarrito.id)
                                                          .delete();
                                                      setState(() {
                                                        _platillos.removeWhere((platillo) =>
                                                            platillo['nombre'] == productoCarrito['nombre'] &&
                                                            platillo['comensal'] == productoCarrito['comensal']);
                                                        _calcularTotal();
                                                        _calcularTiempoEstimado();
                                                      });
                                                    },
                                                    child: Icon(Icons.delete, color: widget.coloresRestaurante[3]),
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
                            }).toList(),
                            Divider(),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            ),
           ValueListenableBuilder<double>(
              valueListenable: _total,
              builder: (context, value, child) {
                return Text(
                  'Total: \$${value.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                );
              },
            ),
            SizedBox(height: 10),
             ValueListenableBuilder<int>(
                valueListenable: _tiempoEstimado,
                builder: (context, value, child) {
                  return Text(
                    'Tiempo estimado: ${value} min',  // Eliminamos toStringAsFixed(2)
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  );
                },
              ),

            ElevatedButton(
              onPressed: () async {
                try {
                  await OrdenService2().enviarOrden(widget.mesaId,widget.alias, _platillos,);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Orden enviada a la cocina',
                        style: TextStyle(color: widget.coloresRestaurante[3]),
                      ),
                      backgroundColor: Colors.black.withOpacity(0.7),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      duration: Duration(milliseconds: 1500),
                    ),
                  );
                  Navigator.popUntil(context, ModalRoute.withName('/'));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error al enviar la orden: $e',
                        style: TextStyle(color: widget.coloresRestaurante[3]),
                      ),
                      backgroundColor: Colors.red.withOpacity(0.7),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      duration: Duration(milliseconds: 1500),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.coloresRestaurante[2],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                minimumSize: Size(300, 30),
              ),
              child: Text(
                'Enviar a la cocina',
                style: TextStyle(
                  fontSize: 17,
                  color: widget.coloresRestaurante[3],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _total.dispose();
    super.dispose();
  }
}
