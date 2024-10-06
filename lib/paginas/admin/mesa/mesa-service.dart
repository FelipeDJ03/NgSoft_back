import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods{
  Future addmesaDetalles(Map<String,dynamic>mesaInfoMap,String id)async{
    return await FirebaseFirestore.instance
    .collection("mesa")
    .doc(id)
    .set(mesaInfoMap);
  }


     Future<Stream<QuerySnapshot>> Obtenermesas(String alias) async {
    return FirebaseFirestore.instance
        .collection('mesa')
        .where('alias', isEqualTo: alias) // Filtrar por el campo alias
        .snapshots();
  }

  
  Future actualizardetallemesa(String id, Map<String,dynamic> actualizarinfo)async{
    return await FirebaseFirestore.instance.collection("mesa").doc(id).update(actualizarinfo);
  }

  Future Eliminarmesa(String id)async{
    return await FirebaseFirestore.instance.collection("mesa").doc(id).delete();
  }

  Future<Map<String, dynamic>?> ObtenerDetallemesas(String userId) async {
  try {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection("mesa").doc(userId).get();
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


