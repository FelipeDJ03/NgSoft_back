import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'orden-service.dart'; 
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class CobrarPantalla extends StatefulWidget {
  final String mesaId;
  final String alias;
  final String usuarioid;
      final List<Color?> coloresRestaurante;

  CobrarPantalla({required this.mesaId,required this.alias,required this.usuarioid,required this.coloresRestaurante});

  @override
  _CobrarPantallaState createState() => _CobrarPantallaState();
}

class _CobrarPantallaState extends State<CobrarPantalla> {
  List<Map<String, dynamic>> _platillos = [];
  double _subtotal = 0.0;
  double _total = 0.0;
  double _cambio = 0.0;
  final TextEditingController _amountController = TextEditingController();
   final TextEditingController _phoneController = TextEditingController();
  bool _isFinalizable = false;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  void _fetchOrderDetails() async {
    QuerySnapshot orderSnapshot = await FirebaseFirestore.instance
        .collection('Orden')
        .where('mesa', isEqualTo: widget.mesaId)
        .get();

    if (orderSnapshot.docs.isNotEmpty) {
      var order = orderSnapshot.docs.first.data() as Map<String, dynamic>;
      setState(() {
        _platillos = List<Map<String, dynamic>>.from(order['platillos'] ?? []);
        _subtotal = order['subtotal']?.toDouble() ?? 0.0;
        _total = order['total']?.toDouble() ?? 0.0;
      });
    }
  }

  List<int> _getSortedComensales() {
    List<int> comensales = _platillos.map<int>((platillo) => platillo['comensal'] ?? 0).toSet().toList();
    comensales.sort();
    return comensales;
  }

  Map<int, List<Map<String, dynamic>>> _groupPlatillosByComensal() {
    Map<int, List<Map<String, dynamic>>> platillosPorComensal = {};

    for (var platillo in _platillos) {
      int comensal = platillo['comensal'] ?? 0;
      if (!platillosPorComensal.containsKey(comensal)) {
        platillosPorComensal[comensal] = [];
      }
      platillosPorComensal[comensal]!.add(platillo);
    }

    return platillosPorComensal;
  }

  Map<int, double> _calculateTotalPerComensal() {
    Map<int, double> totalPorComensal = {};
    var platillosPorComensal = _groupPlatillosByComensal();

    platillosPorComensal.forEach((comensal, platillos) {
      double totalComensal = 0.0;
      for (var platillo in platillos) {
        totalComensal += platillo['precio'] * platillo['cantidad'];
      }
      totalPorComensal[comensal] = totalComensal;
    });

    return totalPorComensal;
  }

  void _finalizarCobro(String metodoPago) async {
  try {
    String folio = DateTime.now().millisecondsSinceEpoch.toString(); // Generar folio único
    DateTime now = DateTime.now(); // Obtener la fecha y hora actual

    await OrdenService2().registrarVenta(
      productos: _platillos,
      subtotal: _subtotal,
      total: _total,
      cambio: _cambio, // Cambio inicialmente 0, se puede ajustar según necesidad
      folio: folio,
      fecha: now, // Pasar DateTime en lugar de String
      hora: "${now.hour}:${now.minute}", // Si todavía necesitas el campo hora como String
      mesa: widget.mesaId,
      metodoPago: metodoPago, // Pasar el método de pago
      alias:widget.alias,
      idMesero:widget.usuarioid,
    );
    _showCobrarDialog2();
  } catch (e) {
    print('Error al finalizar el cobro: $e');
  }

  //Navigator.popUntil(context, ModalRoute.withName('/'));
}


  void _sendWhatsAppMessage(String phoneNumber, String message) async {
    final url = 'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }


void _showCobrarDialog() {
  TextEditingController amountController = TextEditingController();
  String selectedMethod = 'Efectivo';
  bool isFinalizable = false;
  double change = 0.0;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              'Método de pago',
              style: TextStyle(color: widget.coloresRestaurante[0],),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total a cobrar: \$${_total.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: 150,
                    child: DropdownButton<String>(
                      value: selectedMethod,
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedMethod = newValue!;
                        });
                      },
                      items: <String>['Efectivo', 'Transferencia']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                  width: 150,
                  child: TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Cantidad',
                      labelStyle: TextStyle(color: Colors.black),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(color: widget.coloresRestaurante[1]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(color: widget.coloresRestaurante[1]!),
                      ),
                    ),
                    onChanged: (value) {
                      if (double.tryParse(value) != null && double.parse(value) >= 0) {
                        double? amount = double.tryParse(value);
                        if (amount != null && amount >= _total) {
                          setState(() {
                            isFinalizable = true;
                            change = amount - _total;
                          });
                        } else {
                          setState(() {
                            isFinalizable = false;
                            change = 0.0;
                          });
                        }
                      } else {
                        setState(() {
                          isFinalizable = false;
                          change = 0.0;
                        });
                      }
                    },
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                  SizedBox(height: 12,),
                  if (change > 0)
                    Text(
                      'Cambio: \$${change.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: Text(
                  'Finalizar',
                  style: TextStyle(color: widget.coloresRestaurante[3]),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.coloresRestaurante[1]!,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: isFinalizable
                    ? () {
                        Navigator.of(context).pop(); // Cierra el diálogo actual
                        _finalizarCobro(selectedMethod);

                      }
                    : null,
              ),
            ],
          );
        },
      );
    },
  );
}

void _showCobrarDialog2() {
  showDialog(
    context: context,
    barrierDismissible: false, // El diálogo no se cierra al tocar fuera de él
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async => false, // Previene el cierre al presionar el botón de retroceso
        child: StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Venta Finalizada',
                style: TextStyle(color: widget.coloresRestaurante[0],),
              ),
              content: SingleChildScrollView(
                child: Column(),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'Regresar al menú',
                    style: TextStyle(color: widget.coloresRestaurante[4]),
                  ),
                  onPressed: () {
                    Navigator.popUntil(context, ModalRoute.withName('/'));
                  },
                ),
                ElevatedButton(
                  child: Text('Enviar WhatsApp', style: TextStyle(color: widget.coloresRestaurante[3]),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: _showCobrarDialog3,
                ),
              ],
            );
          },
        ),
      );
    },
  );
}

void _showCobrarDialog3() {
  TextEditingController _phoneController = TextEditingController();
  bool isFinalizable = false;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              'Enviar comprobante',
              style: TextStyle(color: widget.coloresRestaurante[0],),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 10),
                  Container(
                    width: 150,
                    child: 
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.number, 
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly, 
                      ],
                      decoration: InputDecoration(
                        labelText: 'Número de teléfono', 
                        labelStyle: TextStyle(color: widget.coloresRestaurante[4]),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: widget.coloresRestaurante[1]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: widget.coloresRestaurante[1]!),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          isFinalizable = _phoneController.text.isNotEmpty;
                        });
                      },
                    ),

                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: widget.coloresRestaurante[4]),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: Text('Enviar WhatsApp', style: TextStyle(color: widget.coloresRestaurante[3]),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: isFinalizable
                    ? () {
                        String message = _createWhatsAppMessage();
                        _sendWhatsAppMessage(_phoneController.text, message);
                      }
                    : null,
              ),
            ],
          );
        },
      );
    },
  );
}

String _createWhatsAppMessage() {



  StringBuffer message = StringBuffer();
  message.writeln("🌟 *Gracias por tu preferencia!* 🌟");
  message.writeln("El Parador del Valle te hace entrega de tu ticket.");
  message.writeln("--------------------------------------------------");
  message.writeln("🧾 *Detalle de la Venta*");
  message.writeln("--------------------------------------------------");

  for (var platillo in _platillos) {
    String nombre = platillo['nombre'];
    int cantidad = platillo['cantidad'];
    double precio = platillo['precio'];
    double subtotal = cantidad * precio;
    message.writeln("$nombre (x$cantidad) - \$${subtotal.toStringAsFixed(2)}");
  }

  message.writeln("--------------------------------------------------");
  message.writeln("💰 *Total*: \$${_total.toStringAsFixed(2)}");
  message.writeln("--------------------------------------------------");
  message.writeln("¡Gracias por tu compra! 😄");

  return message.toString();
}





  @override
  Widget build(BuildContext context) {
    var totalPorComensal = _calculateTotalPerComensal();
    return Scaffold(
      appBar: AppBar(
      backgroundColor: widget.coloresRestaurante[0]!,
      elevation: 0,
      title: Text(
        'Cobrar - Mesa ${widget.mesaId}',
        style: TextStyle(
          color: widget.coloresRestaurante[3],
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      iconTheme: IconThemeData(
        color: widget.coloresRestaurante[3],
      ),
    ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _getSortedComensales().length,
                itemBuilder: (ctx, index) {
                  var comensal = _getSortedComensales()[index];
                  var platillos = _groupPlatillosByComensal()[comensal] ?? [];

                  return Container(
                  margin: EdgeInsets.only(bottom: 18.0),
                  child: Material(
                    elevation: 2.0,
                    borderRadius: BorderRadius.circular(2),
                    child: ExpansionTile(
                      title: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Comensal $comensal',
                              style: TextStyle(
                                color: widget.coloresRestaurante[4],
                                fontSize: 17.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '\$${totalPorComensal[comensal]?.toStringAsFixed(2) ?? '0.00'}',
                              style: TextStyle(
                                color: widget.coloresRestaurante[4],
                                fontSize: 17.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      tilePadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      backgroundColor: widget.coloresRestaurante[3],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2),
                        side: BorderSide(color: widget.coloresRestaurante[0]!, width: 0.7),
                      ),
                      collapsedBackgroundColor: widget.coloresRestaurante[3],
                      collapsedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2),
                        side: BorderSide(color: widget.coloresRestaurante[0]!, width: 0.7),
                      ),
                      iconColor: widget.coloresRestaurante[2],
                      collapsedIconColor: widget.coloresRestaurante[2],
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 0),
                              child: Divider(
                                color: widget.coloresRestaurante[0]!,
                                thickness: 0.8,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10, bottom: 10, left: 30, right: 35),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Descripción",
                                              style: TextStyle(
                                                color: widget.coloresRestaurante[4],
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            ...platillos.asMap().entries.map((entry) {
                                              int index = entry.key + 1; // Add 1 to make it 1-based index
                                              var platillo = entry.value;
                                              return Padding(
                                                padding: const EdgeInsets.only(top: 5.0),
                                                child: Text(
                                                  "$index. ${platillo['nombre'] ?? 'Sin nombre'}",
                                                  style: TextStyle(
                                                    color: widget.coloresRestaurante[4],
                                                    fontSize: 16.0,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 20), // Space between columns
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Cantidad",
                                            style: TextStyle(
                                              color: widget.coloresRestaurante[4],
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          ...platillos.map((platillo) {
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 5.0),
                                              child: Text(
                                                "${platillo['cantidad'] ?? 0}",
                                                style: TextStyle(
                                                  color: widget.coloresRestaurante[4],
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ],
                                      ),
                                      SizedBox(width: 20), // Space between columns
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Precio",
                                            style: TextStyle(
                                              color: widget.coloresRestaurante[4],
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          ...platillos.map((platillo) {
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 5.0),
                                              child: Text(
                                                "\$${platillo['precio']?.toStringAsFixed(2) ?? '0.00'}",
                                                style: TextStyle(
                                                  color: widget.coloresRestaurante[4],
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Divider(
                                    color: widget.coloresRestaurante[0]!,
                                    thickness: 0.8,
                                    height: 20,
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "TOTAL",
                                          style: TextStyle(
                                            color: widget.coloresRestaurante[4],
                                            fontSize: 16.0,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '\$${totalPorComensal[comensal]?.toStringAsFixed(2) ?? '0.00'}',
                                        style: TextStyle(
                                          color: widget.coloresRestaurante[4],
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ],
                    ),
                  ),
                );



                },
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Subtotal: \$${_subtotal.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Total: \$${_total.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
                        onPressed: _showCobrarDialog,
                        style: ElevatedButton.styleFrom(
                        backgroundColor: widget.coloresRestaurante[1],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                        minimumSize: Size(300, 30),
                      ),
                      child: Text(
                        'Cobrar',
                        style: TextStyle(
                          fontSize: 17, 
                          color: widget.coloresRestaurante[3], 
                          fontWeight: FontWeight.bold,
                        ), 
                      ),
                      ),
          ],
        ),
      ),
    );
  }
} 
