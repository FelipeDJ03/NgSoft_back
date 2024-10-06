import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


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
  // Primero, elimina el registro de Firestore
  

    // Ahora, realiza la petición HTTP para eliminar al usuario en Firebase Auth
    final url = Uri.parse('http://localhost:4242/eliminarUsuario');  // Cambia '/eliminarUsuario' si es necesario
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'uid': id,  // El 'id' que le pasas a tu endpoint
        }),
      );

      if (response.statusCode == 200) {
        print("Usuario eliminado exitosamente de Firebase Auth");
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection("usuarios").doc(id).get();
        if (doc.exists) {
          String? imageUrl = doc['image_url'];
          await FirebaseFirestore.instance.collection("usuarios").doc(id).delete();
          if (imageUrl != null) {
            await eliminarImagen(imageUrl);
          }
        }
      } else {
        print("Error al eliminar el usuario: ${response.body}");
      }
    } catch (e) {
      print("Error de conexión al eliminar el usuario: $e");
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
