import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods{
  Future addcocinaDetalles(Map<String,dynamic>cocinaInfoMap,String id)async{
    return await FirebaseFirestore.instance
    .collection("cocina")
    .doc(id)
    .set(cocinaInfoMap);
  }


  Future<Stream<QuerySnapshot>> Obtenercocinas(String alias)async{
    return await FirebaseFirestore.instance.collection('cocina').where('alias', isEqualTo: alias).snapshots();
  }

  Future actualizardetallecocina(String id, Map<String,dynamic> actualizarinfo)async{
    return await FirebaseFirestore.instance.collection("cocina").doc(id).update(actualizarinfo);
  }

Future<void> Eliminarcocina(String id) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Obtener todos los documentos de "productos" donde la categoría coincida con el id
  QuerySnapshot productosSnapshot = await firestore
      .collection("productos")
      .where("cocina", isEqualTo: id)
      .get();

  // Eliminar todos los documentos de "productos" que coincidan
  for (DocumentSnapshot doc in productosSnapshot.docs) {
    await firestore.collection("productos").doc(doc.id).delete();
  }

  // Obtener todos los documentos de "combos" donde la categoría coincida con el id
  QuerySnapshot combosSnapshot = await firestore
      .collection("combos")
      .where("cocina", isEqualTo: id)
      .get();

  // Eliminar todos los documentos de "combos" que coincidan
  for (DocumentSnapshot doc in combosSnapshot.docs) {
    await firestore.collection("combos").doc(doc.id).delete();
  }

  // Finalmente, eliminar el documento de la categoría
  await firestore.collection("cocina").doc(id).delete();
}

  Future<Map<String, dynamic>?> ObtenerDetallecocinas(String userId) async {
  try {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection("cocina").doc(userId).get();
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

}


