import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DatabaseMethods {
  Future<void> addusuariosDetalles(Map<String, dynamic> usuariosInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("usuarios")
        .doc(id)
        .set(usuariosInfoMap);
  }

  Future<Stream<QuerySnapshot>> ObtenerDetalleusuarios(String alias) async {
    return await FirebaseFirestore.instance.collection('usuarios').where('alias', isEqualTo: alias).snapshots();
  }

  Future<void> actualizardetalleusuarios(String id, Map<String, dynamic> actualizarinfo) async {
    return await FirebaseFirestore.instance.collection("usuarios").doc(id).update(actualizarinfo);
  }

  Future<void> Eliminarusuario(String id) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection("usuarios").doc(id).get();
    if (doc.exists) {
      String? imageUrl = doc['image_url'];
      await FirebaseFirestore.instance.collection("usuarios").doc(id).delete();
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

  Future<Map<String, dynamic>?> obtenerDetalleUsuario(String userId) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection("usuarios").doc(userId).get();
      if (documentSnapshot.exists) {
        return documentSnapshot.data() as Map<String, dynamic>;
      } else {
        print("El usuario con el ID $userId no existe.");
        return null;
      }
    } catch (e) {
      print("Error al obtener los detalles del usuario: $e");
      return null;
    }
  }

  Future<void> actualizarDetalleUsuario(String userId, Map<String, dynamic> actualizarInfo) async {
    try {
      await FirebaseFirestore.instance.collection("usuarios").doc(userId).update(actualizarInfo);
      print("Detalles del usuario actualizados correctamente.");
    } catch (e) {
      print("Error al actualizar los detalles del usuario: $e");
    }
  }
}