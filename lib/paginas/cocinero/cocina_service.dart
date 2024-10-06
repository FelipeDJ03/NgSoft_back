import 'package:cloud_firestore/cloud_firestore.dart';

class CocinaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> empezarCocinar(String ordenId, String platilloId) async {
    try {
      // Referencia al documento de la orden
      DocumentReference ordenRef = _firestore.collection('Orden').doc(ordenId);

      // Obtener el documento de la orden
      DocumentSnapshot ordenSnapshot = await ordenRef.get();

      if (ordenSnapshot.exists) {
        // Obtener los platillos de la orden
        List<dynamic> platillos = ordenSnapshot.get('platillos');

        // Actualizar el estado del platillo correspondiente
        List platillosActualizados = platillos.map((platillo) {
          if (platillo['Id'] == platilloId) {
            platillo['status'] = 'empezado'; // Cambiar el estado a 'empezado'
          }
          return platillo;
        }).toList();

        // Actualizar el documento de la orden con los platillos modificados
        await ordenRef.update({
          'platillos': platillosActualizados,
        });
      }
    } catch (e) {
      print("Error al actualizar el estado del platillo: $e");
      throw Exception("Error al actualizar el estado del platillo");
    }
  }

Future<void> terminarCocinar(String ordenId, String platilloId, String mesa, String alias) async {
  try {
    // Referencia al documento de la orden
    DocumentReference ordenRef = _firestore.collection('Orden').doc(ordenId);

    // Obtener el documento de la orden
    DocumentSnapshot ordenSnapshot = await ordenRef.get();

    if (ordenSnapshot.exists) {
      // Obtener los platillos de la orden
      List<dynamic> platillos = ordenSnapshot.get('platillos');

      // Variable para verificar si se ha encontrado el platillo
      bool platilloEncontrado = false;

      // Actualizar el estado del platillo correspondiente
      List platillosActualizados = platillos.map((platillo) {
        if (platillo['Id'] == platilloId && !platilloEncontrado) {
          platillo['status'] = 'terminado'; // Cambiar el estado a 'terminado'
          platilloEncontrado = true;

          // Crear un nuevo registro en la colección 'entregar'
          _firestore.collection('entregar').add({
            'ordenId': ordenId,
            'platilloId': platilloId,
            'mesa': mesa,
            'platilloNombre': platillo['nombre'], // Asegúrate de que este campo exista en tu documento
            'status': 'terminado',
            'alias': alias,
            'timestamp': FieldValue.serverTimestamp(), // Timestamp para cuando se agregó el registro
          });
        }
        return platillo;
      }).toList();

      // Actualizar el documento de la orden con los platillos modificados
      await ordenRef.update({
        'platillos': platillosActualizados,
      });
    }
  } catch (e) {
    print("Error al actualizar el estado del platillo: $e");
    throw Exception("Error al actualizar el estado del platillo");
  }
}
}
