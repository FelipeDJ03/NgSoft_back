import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DatabaseMethods {

  Stream<QuerySnapshot> Obtenercategorias(String alias) {
    return FirebaseFirestore.instance.collection('categoria').where('alias', isEqualTo: alias).snapshots();
  }
  Stream<QuerySnapshot> Obtenercocinas(String alias) {
    return FirebaseFirestore.instance.collection('cocina').where('alias', isEqualTo: alias).snapshots();
  }
  

  Future<Stream<QuerySnapshot>> ObtenerDetalleproductos(String alias) async {
    return await FirebaseFirestore.instance.collection('productos').where('alias', isEqualTo: alias).snapshots();
  }

  Future<void> actualizardetalleproductos(String id, Map<String, dynamic> actualizarinfo) async {
    return await FirebaseFirestore.instance.collection("productos").doc(id).update(actualizarinfo);
  }

  Future<void> Eliminarproducto(String id) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection("productos").doc(id).get();
    if (doc.exists) {
      String? imageUrl = doc['imagen_url'];
      await FirebaseFirestore.instance.collection("productos").doc(id).delete();
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

  Future<Map<String, dynamic>?> obtenerDetalleproducto(String userId) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection("productos").doc(userId).get();
      if (documentSnapshot.exists) {
        return documentSnapshot.data() as Map<String, dynamic>;
      } else {
        print("El producto con el ID $userId no existe.");
        return null;
      }
    } catch (e) {
      print("Error al obtener los detalles del producto: $e");
      return null;
    }
  }

  Future<void> actualizarDetalleproducto(String userId, Map<String, dynamic> actualizarInfo) async {
    try {
      await FirebaseFirestore.instance.collection("productos").doc(userId).update(actualizarInfo);
      print("Detalles del producto actualizados correctamente.");
    } catch (e) {
      print("Error al actualizar los detalles del producto: $e");
    }
  }

 
  
}
