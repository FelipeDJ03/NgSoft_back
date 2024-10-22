import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notificacion_service.dart';
import '../splash.dart';

class OrdenEntregar extends StatefulWidget {
  final String alias;
    final List<Color?> coloresRestaurante;

  OrdenEntregar({required this.alias,required this.coloresRestaurante});
  
  @override
  _OrdenEntregarState createState() => _OrdenEntregarState();
}

class _OrdenEntregarState extends State<OrdenEntregar> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, String> mesaNombres = {};
  bool isMesaNombresLoaded = false;
  Set<String> notifiedIds = {}; // Para mantener los IDs de los registros ya notificados
  Timer? _timer; // Controlador para el temporizador
  Timer? _audioTimer; // Controlador para el temporizador de audio
  bool hasPendingOrders = false; // Bandera para platillos pendientes

  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _initialize(); 
  }

  Future<void> _initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    await initNotifications();
    _fetchMesaNombres();
  }

  Future<void> _fetchMesaNombres() async {
    QuerySnapshot snapshot = await _firestore.collection('mesa').where('alias', isEqualTo: widget.alias).get();
    Map<String, String> nombres = {};
    snapshot.docs.forEach((doc) {
      nombres[doc.id] = doc['nombre'];
    });

    setState(() {
      mesaNombres = nombres;
      isMesaNombresLoaded = true;
    });
  }

  void _handleNotifications(List<DocumentSnapshot> documents) {
    for (var document in documents) {
      final data = document.data() as Map<String, dynamic>;
      final id = document.id;

      if (!notifiedIds.contains(id)) {
        mostrarNotificacion(
          'Platillo: ${data['platilloNombre']}',
        );
        notifiedIds.add(id); // Añade el ID al conjunto de notificaciones
      }
    }
  }

  Future<void> play() async {
    String audioPath = "notification_sound.mp3";
    await player.play(AssetSource(audioPath));
  }

  void _startAudioTimer() {
    _audioTimer?.cancel(); // Cancelar cualquier temporizador existente
    _audioTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (hasPendingOrders) {
        play();
      } else {
        timer.cancel(); // Detener el temporizador si no hay platillos
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Detener el temporizador cuando se salga de la pantalla
    _audioTimer?.cancel(); // Detener el temporizador de audio
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 247, 246, 244),
      body: isMesaNombresLoaded
          ? StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('entregar').where('alias', isEqualTo: widget.alias).orderBy('timestamp', descending: false).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SplashPantalla(); // Mostrar el widget de splash mientras carga
                }

                final List<DocumentSnapshot> documents = snapshot.data?.docs ?? [];

                // Si hay documentos, activar el temporizador de notificación
                if (documents.isNotEmpty) {
                  hasPendingOrders = true;
                  _startAudioTimer(); // Iniciar temporizador para el sonido
                } else {
                  hasPendingOrders = false; // Si no hay platillos, detener el temporizador
                  _audioTimer?.cancel();
                }

                // Mostrar notificación por cada nuevo registro
                if (snapshot.connectionState == ConnectionState.active && documents.isNotEmpty) {
                  _handleNotifications(documents);
                }

                // Agrupar documentos por mesa
                Map<String, List<DocumentSnapshot>> groupedDocuments = {};
                for (var document in documents) {
                  final String mesaId = document['mesa'];
                  if (groupedDocuments.containsKey(mesaId)) {
                    groupedDocuments[mesaId]!.add(document);
                  } else {
                    groupedDocuments[mesaId] = [document];
                  }
                }

                if (groupedDocuments.isEmpty) {
                  return Center(
                    child: Text('No hay platillos a entregar aun.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: widget.coloresRestaurante[4])),
                  );
                }

                return ListView(
                  children: groupedDocuments.entries.map((entry) {
                    final String mesaId = entry.key;
                    final String mesaNombre = mesaNombres[mesaId] ?? 'Mesa Desconocida';
                    final List<DocumentSnapshot> mesaDocuments = entry.value;

                    return Container(
                      margin: EdgeInsets.only(bottom: 9.0, left: 15, right: 15, top: 6),
                      child: Card(
                        color: widget.coloresRestaurante[3],
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
                                color: widget.coloresRestaurante[1],
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
                                  'Mesa: $mesaNombre',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: widget.coloresRestaurante[4]
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Column(
                                children: mesaDocuments.map((document) {
                                  final Map<String, dynamic> data = document.data() as Map<String, dynamic>;

                                  return Dismissible(
                                    key: Key(document.id),
                                    direction: DismissDirection.endToStart,
                                    onDismissed: (direction) async {
                                      // Eliminar el registro de Firestore
                                      await _firestore.collection('entregar').doc(document.id).delete();
                                      notifiedIds.remove(document.id); // Eliminar el ID del conjunto de notificaciones

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '${data['platilloNombre']} entregado',
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
                                    background: Container(
                                      color: Colors.red,
                                      alignment: Alignment.centerRight,
                                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                                      child: Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                    ),
                                    child: Container(
                                      margin: EdgeInsets.only(bottom: 10.0),
                                      child: ListTile(
                                        title: Text(data['platilloNombre'] ?? 'Sin nombre'),
                                        subtitle: Text('Estado: ${data['status']}'),
                                        trailing: Text(data['ordenId']),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            )
          : SplashPantalla(), // Mostrar el widget de splash mientras carga
    );
  }
}
