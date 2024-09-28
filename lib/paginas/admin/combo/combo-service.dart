import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DatabaseMethods {

  Stream<QuerySnapshot> Obtenercategorias(String alias) {
    return FirebaseFirestore.instance.collection('categoria').where('alias', isEqualTo: alias).snapshots();
  }
  Stream<QuerySnapshot> Obtenerproductos(String alias) {
    return FirebaseFirestore.instance.collection('productos').where('alias', isEqualTo: alias).snapshots();
  }

  Future<Stream<QuerySnapshot>> ObtenerDetallecombos(String alias) async {
    return await FirebaseFirestore.instance.collection('combos').where('alias', isEqualTo: alias).snapshots();
  }

  Future<void> actualizardetallecombos(String id, Map<String, dynamic> actualizarinfo) async {
    return await FirebaseFirestore.instance.collection("combos").doc(id).update(actualizarinfo);
  }

  Future<void> Eliminarcombo(String id) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection("combos").doc(id).get();
    if (doc.exists) {
      String? imageUrl = doc['imagen_url'];
      await FirebaseFirestore.instance.collection("combos").doc(id).delete();
      if (imageUrl != null) {
        await eliminarImagen(imageUrl);
      }
    }
  }

  Future<void> eliminarImagen(String imageUrl) async {
    try {
      Reference storageReference = FirebaseStorage.instance.refFromURL(imageUrl);
      await storageReference.delete();
      print("Imagen eliminada con éxito");
    } catch (e) {
      print("Error al eliminar la imagen: $e");
    }
  }

  Future<Map<String, dynamic>?> obtenerDetallecombo(String userId) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection("combos").doc(userId).get();
      if (documentSnapshot.exists) {
        return documentSnapshot.data() as Map<String, dynamic>;
      } else {
        print("El combo con el ID $userId no existe.");
        return null;
      }
    } catch (e) {
      print("Error al obtener los detalles del combo: $e");
      return null;
    }
  }

  Future<void> actualizarDetallecombo(String userId, Map<String, dynamic> actualizarInfo) async {
    try {
      await FirebaseFirestore.instance.collection("combos").doc(userId).update(actualizarInfo);
      print("Detalles del combo actualizados correctamente.");
    } catch (e) {
      print("Error al actualizar los detalles del combo: $e");
    }
  }

}
