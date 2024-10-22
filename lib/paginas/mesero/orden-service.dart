import 'package:cloud_firestore/cloud_firestore.dart';

class OrdenService {
  final CollectionReference _carritoCollection =
      FirebaseFirestore.instance.collection('Carrito_platillo');

  Future<void> agregarProductoAlCarrito({
    required String Id,
    required String nombre,
    required double precio,
    required String imagenUrl,
    required String mesaId,
    required int numeroComensal,
    required String alias,
    required String cocina,
    int cantidad = 1, required categoria,
  }) async {
    try {
      await _carritoCollection.add({
        'Id':Id,
        'nombre': nombre,
        'precio': precio,
        'imagen_url': imagenUrl,
        'mesa': mesaId,
        'comensal': numeroComensal,
        'cantidad': cantidad,
        'nota':'normal',
        'alias':alias,
        'cocina':cocina,
        'categoria':categoria,
      });
    } catch (e) {
      print('Error al agregar producto al carrito: $e');
    }
  }


  Stream<QuerySnapshot> obtenerCarrito(String mesaId, int numeroComensal) {
    return _carritoCollection
        .where('mesa', isEqualTo: mesaId)
        .where('comensal', isEqualTo: numeroComensal)
        .snapshots();
  }

  Future<void> eliminarProductoDelCarrito(String productoId) async {
    try {
      await _carritoCollection.doc(productoId).delete();
    } catch (e) {
      print('Error al eliminar producto del carrito: $e');
    }
  }

  Future<void> sumarcomensalmesa({required String mesaId}) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection("mesa").doc(mesaId).get();

  if (doc.exists) {
    return await FirebaseFirestore.instance.collection("mesa").doc(mesaId).update({
      'comensales': FieldValue.increment(1),
    });
  } else {
    print('Documento no encontrado para ID: $mesaId');
    return Future.error('Documento no encontrado');
  }
  }
  Future<void> restarcomensalmesa({required String mesaId}) async {
   DocumentSnapshot doc = await FirebaseFirestore.instance.collection("mesa").doc(mesaId).get();

    if (doc.exists) {
      print('Documento encontrado: ${doc.data()}');
      return await FirebaseFirestore.instance.collection("mesa").doc(mesaId).update({
        'comensales': FieldValue.increment(-1), // Usar decrement para restar 1
      });
    } else {
      print('Documento no encontrado para ID: $mesaId');
      return Future.error('Documento no encontrado');
    }
  }
}



class OrdenService2 {
  final CollectionReference ordenes = FirebaseFirestore.instance.collection('Orden');
  final CollectionReference carrito = FirebaseFirestore.instance.collection('Carrito_platillo');
  final CollectionReference mesas = FirebaseFirestore.instance.collection('mesa');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> enviarOrden(String mesaId,String alias, List<Map<String, dynamic>> platillos) async {
    if (mesaId == null || mesaId.isEmpty) {
      throw ArgumentError("El ID de la mesa no puede ser nulo o vacío.");
    }

    if (platillos == null || platillos.isEmpty) {
      throw ArgumentError("La lista de platillos no puede ser nula o vacía.");
    }

    double subtotal = 0.0;

    // Calcular subtotal
    for (var platillo in platillos) {
      if (platillo.containsKey('precio') && platillo.containsKey('cantidad')) {
        subtotal += platillo['precio'] * platillo['cantidad'];
      } else {
        throw ArgumentError("Cada platillo debe contener 'precio' y 'cantidad'.");
      }
    }

    double total = subtotal; // Si hay impuestos o descuentos, se pueden agregar aquí

   try {
  QuerySnapshot ordenSnapshot = await ordenes.where('mesa', isEqualTo: mesaId).get();
  
      // Agregar el campo 'status' a cada platillo en la lista de platillos
      List<Map<String, dynamic>> platillosConStatus = platillos.map((platillo) {
        platillo['status'] = 'pendiente';
        return platillo;
      }).toList();
      if (ordenSnapshot.docs.isNotEmpty) {
        // Existe una orden para la mesa, actualizarla
        DocumentReference ordenExistenteRef = ordenSnapshot.docs.first.reference;
        DocumentSnapshot ordenExistente = await ordenExistenteRef.get();
        List<dynamic> platillosExistentes = List.from(ordenExistente.get('platillos'));

        // Actualizar lista de platillos
        platillosExistentes.addAll(platillos);

        // Calcular nuevo subtotal y total
        double nuevoSubtotal = ordenExistente.get('subtotal') + subtotal;
        double nuevoTotal = ordenExistente.get('total') + total;

        await ordenExistenteRef.update({
          'platillos': platillosExistentes,
          'subtotal': nuevoSubtotal,
          'total': nuevoTotal,
        });
      } else {
        // No existe una orden para la mesa, crear una nueva
        DocumentReference nuevaOrdenRef = await ordenes.add({
          'platillos': platillos,
          'subtotal': subtotal,
          'total': total,
          'mesa': mesaId,
          'alias':alias,
        });

        // Actualizar la disponibilidad de la mesa
        await mesas.doc(mesaId).update({
          'disponibilidad': 'Ocupado',
        });
      }

      // Eliminar los platillos del carrito
      QuerySnapshot carritoSnapshot = await carrito.where('mesa', isEqualTo: mesaId).get();
      for (var doc in carritoSnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      // Manejo de errores
      print("Error al enviar la orden: $e");
      rethrow; // Opcional: re-lanzar el error para que el llamador pueda manejarlo
    }
  }


  Future<void> registrarVenta({
  required List<Map<String, dynamic>> productos,
  required double subtotal,
  required double total,
  required double cambio,
  required String folio,
  required DateTime fecha,
  required String hora,
  required String mesa,
  required String idMesero,
  required String metodoPago,
  required String alias,
}) async {
  try {
    // Convertir DateTime a Timestamp
    Timestamp fechaTimestamp = Timestamp.fromDate(fecha);

    // Registrar la venta en la colección 'venta'
    DocumentReference ventaRef = await _firestore.collection('venta').add({
      'productos': productos,
      'subtotal': subtotal,
      'metodoPago': metodoPago,
      'total': total,
      'cambio': cambio,
      'folio': folio,
      'fecha': fechaTimestamp,
      'hora': hora,
      'mesa': mesa,
      'id_mesero': idMesero,
      'alias': alias,
    });

    // Actualizar el campo 'ventas' en la colección 'productos'
    for (var producto in productos) {
      String productId = producto['Id']; // ID del producto

      // Obtener el documento del producto en la colección 'productos'
      DocumentReference productoRef = _firestore.collection('productos').doc(productId);

      // Usar una transacción para leer y actualizar el campo 'ventas' atómicamente
      try {
        await _firestore.runTransaction((transaction) async {
          DocumentSnapshot productoSnapshot = await transaction.get(productoRef);

          if (productoSnapshot.exists) {
            // Obtener el valor actual de 'ventas' y sumarle 1
            int ventasActuales = productoSnapshot['ventas'] ?? 0; // Si el campo 'ventas' no existe, asumir que es 0
            transaction.update(productoRef, {'ventas': ventasActuales + 1});
          } else {
            print('Producto no encontrado para ID: $productId');
          }
        });
      } catch (e) {
        print('Error al actualizar ventas del producto: $e');
      }
    }

   // Actualizar el campo 'ventas' en la colección 'categorías'
for (var producto in productos) {
  String categoriaId = producto['categoria'];
  print('Procesando categoría ID: $categoriaId');

  DocumentReference categoriaRef = _firestore.collection('categoria').doc(categoriaId);

  // Usar una transacción para leer y actualizar el campo 'ventas' atómicamente
  // Usar una transacción para leer y actualizar el campo 'ventas' atómicamente
try {
  await _firestore.runTransaction((transaction) async {
    DocumentSnapshot categoriaSnapshot = await transaction.get(categoriaRef);

    if (categoriaSnapshot.exists) {
      int ventasActuales = (categoriaSnapshot.data() as Map<String, dynamic>).containsKey('ventas') ? categoriaSnapshot['ventas'] : 0; // Verificar el valor
      print('Ventas actuales: $ventasActuales');
      transaction.update(categoriaRef, {'ventas': ventasActuales + 1});
    } else {
      print('Categoría no encontrada para ID: $categoriaId');
    }
  });
} catch (e) {
  print('Error al actualizar ventas de la categoría: ${e.toString()}');
}

}


    // Eliminar el registro de la orden en la colección 'Orden'
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('Orden').where('mesa', isEqualTo: mesa).get();
      await Future.wait(querySnapshot.docs.map((doc) => doc.reference.delete())); // Eliminar todos los documentos encontrados
    } catch (e) {
      print('Error al eliminar la orden: $e');
    }

    // Actualizar el campo 'disponibilidad' en la colección 'mesa'
    try {
      await _firestore.collection('mesa').doc(mesa).update({
        'disponibilidad': 'Disponible',
      });
    } catch (e) {
      print('Error al actualizar disponibilidad de mesa: $e');
    }

  } catch (e) {
    print('Error al registrar la venta: $e');
    throw Exception('Error al registrar la venta');
  }
}



 Future<void> agregarNotaAlProducto(String productoCarritoId, String nota) async {
    await FirebaseFirestore.instance
        .collection('Carrito_platillo')
        .doc(productoCarritoId)
        .update({'nota': nota});
  }

}

