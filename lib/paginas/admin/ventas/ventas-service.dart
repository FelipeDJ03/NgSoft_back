import 'package:cloud_firestore/cloud_firestore.dart';

class VentasService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

 Stream<QuerySnapshot> streamTotalVentasPorMetodoPago( {required String alias}) {
    // Obtener la fecha de hoy
    DateTime today = DateTime.now();
    DateTime startOfDay = DateTime(today.year, today.month, today.day);
    DateTime endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    // Convertir DateTime a Timestamp
    Timestamp startTimestamp = Timestamp.fromDate(startOfDay);
    Timestamp endTimestamp = Timestamp.fromDate(endOfDay);

    return _firestore
    .collection('venta')
    .where('alias', isEqualTo: alias)
    .where('fecha', isGreaterThanOrEqualTo: startTimestamp)
    .where('fecha', isLessThanOrEqualTo: endTimestamp)
    .snapshots();
  }



  Future<Stream<QuerySnapshot>> ObtenerDetalleventas( {required String alias}) async {
  // Obtener la fecha de hoy
  DateTime today = DateTime.now();
  DateTime startOfDay = DateTime(today.year, today.month, today.day);
  DateTime endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

  // Convertir DateTime a Timestamp
  Timestamp startTimestamp = Timestamp.fromDate(startOfDay);
  Timestamp endTimestamp = Timestamp.fromDate(endOfDay);

  // Retornar el stream filtrado por fecha
  return FirebaseFirestore.instance
      .collection('venta')
      .where('alias', isEqualTo: alias)
      .where('fecha', isGreaterThanOrEqualTo: startTimestamp)
      .where('fecha', isLessThanOrEqualTo: endTimestamp)
      .snapshots();
}
}
