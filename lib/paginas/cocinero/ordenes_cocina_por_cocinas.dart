import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:ngcomanda/paginas/cocinero/ordenes_cocina.dart';
import 'cocina_service.dart';


class OrdenesCocina_porCocinaPage extends StatefulWidget {
  final String alias;
    final List<Color?> coloresRestaurante;

  OrdenesCocina_porCocinaPage({required this.alias,required this.coloresRestaurante});

  @override
  _OrdenesCocina_porCocinaPageState createState() => _OrdenesCocina_porCocinaPageState();
}


class _OrdenesCocina_porCocinaPageState extends State<OrdenesCocina_porCocinaPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Órdenes por Cocina'),
      ),
      body: Column(
        children: [
           Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                   Navigator.of(context).pop(); 
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrdenesCocinaPage(alias:widget.alias,coloresRestaurante: widget.coloresRestaurante),
                        ),
                      );
                },
                child: Text('Ver por cocina'),
              ),
            ),
          // Mostrar las cocinas en una fila vertical
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.8, // Ajusta según la altura deseada
            child: StreamBuilder<QuerySnapshot>(
              stream: obtenerCocinas(),
              builder: (context, cocinaSnapshot) {
                if (cocinaSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!cocinaSnapshot.hasData || cocinaSnapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No hay cocinas disponibles'));
                }
                // Mostrar las cocinas en un listview vertical
                return ListView.builder(
                  itemCount: cocinaSnapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot cocina = cocinaSnapshot.data!.docs[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: InkWell(
                          onTap: () {},
                          child: Container(
                            padding: EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Icono de la cocina y nombre
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(
                                      Icons.kitchen,
                                      size: 40,
                                      color: Colors.orange,
                                    ),
                                    Expanded(
                                      child: Text(
                                        cocina['nombre'],
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                // Mostrar lista de productos por cocina
                                StreamBuilder<QuerySnapshot>(
                                  stream: obtenerOrdenes(),
                                  builder: (context, ordenSnapshot) {
                                    if (ordenSnapshot.connectionState == ConnectionState.waiting) {
                                      return Center(child: CircularProgressIndicator());
                                    }
                                    if (!ordenSnapshot.hasData || ordenSnapshot.data!.docs.isEmpty) {
                                      return Center(child: Text('No hay órdenes disponibles'));
                                    }

                                    // Filtrar platillos por cocina
                                    List<Map<String, dynamic>> productosPorCocina = [];
                                    for (var orden in ordenSnapshot.data!.docs) {
                                      List<dynamic> platillos = orden['platillos'];
                                      for (var platillo in platillos) {
                                          if (platillo['status'] == 'terminado') {
                                              continue; // Omitir platillos con estado 'terminado'
                                            }
                                        if (platillo['cocina'] == cocina.id) {
                                          productosPorCocina.add({
                                            ...platillo,
                                            'orden_id': orden.id, // ID de la orden
                                            'mesa': orden['mesa'], // Mesa de la orden
                                          });
                                        }
                                      }
                                    }

                                    return ListView.builder(
                                      physics: NeverScrollableScrollPhysics(), // Evitar scroll en los platillos dentro de la card
                                      shrinkWrap: true, // Hace que el ListView se ajuste a su contenido
                                      itemCount: productosPorCocina.length,
                                      itemBuilder: (context, index) {
                                        var platillo = productosPorCocina[index];

                                        return Container(
                                          margin: EdgeInsets.only(bottom: 10.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Image.network(
                                                  platillo['imagen_url'],
                                                  height: 80.0,
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
                                                        fontSize: 16.0,
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
                                                      'Mesa: ${platillo['mesa']}',
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 14.0,
                                                      ),
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
                                                    // Botón "Empezar" cuando el platillo está pendiente
                                                    if (platillo['status'] == 'pendiente')
                                                      TextButton(
                                                        onPressed: () => ModalEmpezar(
                                                          context,
                                                          platillo['orden_id'], // ID de la orden
                                                          platillo['Id'], // ID del platillo
                                                          platillo['nombre'],
                                                          platillo['Id'], // ID del platillo
                                                        ),
                                                        child: Text('Empezar'),
                                                        style: TextButton.styleFrom(
                                                          foregroundColor: Colors.white,
                                                          backgroundColor: Colors.green,
                                                        ),
                                                      ),
                                                    // Botón "Terminar" cuando el platillo está empezado
                                                    if (platillo['status'] == 'empezado')
                                                      TextButton(
                                                        onPressed: () => ModalTerminar(
                                                          context,
                                                          platillo['orden_id'], // ID de la orden
                                                          platillo['Id'], // ID del platillo
                                                          platillo['nombre'],
                                                          platillo['Id'], // ID del platillo
                                                          platillo['mesa'], // Mesa asociada a la orden
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
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
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
