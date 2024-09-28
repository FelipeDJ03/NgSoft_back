import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'mesa-service.dart'; 

class Editarmesa extends StatefulWidget {
  final String userId;

  const Editarmesa({Key? key, required this.userId}) : super(key: key);

  @override
  _EditarmesaState createState() => _EditarmesaState();
}

class _EditarmesaState extends State<Editarmesa> {
  TextEditingController nombreController = TextEditingController();
  TextEditingController descripcionController = TextEditingController();
  String disponibilidad = 'Disponible'; // Valor predeterminado
  TextEditingController comensalesController = TextEditingController();

  final List<String> opcionesDisponibilidad = ['Disponible', 'Ocupado'];

  @override
  void initState() {
    super.initState();
    obtenerDetallemesa(); 
  }

  obtenerDetallemesa() async {
    // Utiliza el método de tu servicio para obtener los detalles del mesa
    Map<String, dynamic>? mesa = await DatabaseMethods().ObtenerDetallemesas(widget.userId);
    setState(() {
      nombreController.text = mesa?['nombre'] ?? '';
      descripcionController.text = mesa?['descripcion'] ?? '';
      disponibilidad = mesa?['disponibilidad'] ?? 'Disponible'; // Establece el valor seleccionado
      comensalesController.text = mesa?['comensales']?.toString() ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 247, 246, 244),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3), 
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Color(0xFF556B2F),
            elevation: 0,
            title: const Text(
              'Editar Mesa',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            iconTheme: IconThemeData(
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.0),
            TextField(
              controller: nombreController,
              decoration: InputDecoration(
                filled: true, 
                fillColor: Color(0xFFffffff),
                labelText: 'Nombre',
                labelStyle: TextStyle(
                  color: Colors.black, 
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFFD2691E),
                    width: 1.3,
                  ),
                  borderRadius: BorderRadius.circular(18.0), 
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFFD2691E),
                    width: 1.3,
                  ),
                  borderRadius: BorderRadius.circular(18.0), 
                ),
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: descripcionController,
              decoration: InputDecoration(
                filled: true, 
                fillColor: Color(0xFFffffff),
                labelText: 'Descripción',
                labelStyle: TextStyle(
                  color: Colors.black, 
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFFD2691E),
                    width: 1.3,
                  ),
                  borderRadius: BorderRadius.circular(18.0), 
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFFD2691E),
                    width: 1.3,
                  ),
                  borderRadius: BorderRadius.circular(18.0), 
                ),
              ),
            ),
            SizedBox(height: 20.0),
            DropdownButtonFormField<String>(
              value: disponibilidad,
              onChanged: (String? newValue) {
                setState(() {
                  disponibilidad = newValue!;
                });
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFFffffff),
                labelText: 'Disponibilidad',
                labelStyle: TextStyle(
                  color: Colors.black,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFFD2691E),
                    width: 1.3,
                  ),
                  borderRadius: BorderRadius.circular(18.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFFD2691E),
                    width: 1.3,
                  ),
                  borderRadius: BorderRadius.circular(18.0),
                ),
              ),
              items: opcionesDisponibilidad.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: comensalesController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'^[1-9]\d*')),
              ],
              decoration: InputDecoration(
                filled: true, 
                fillColor: Color(0xFFffffff),
                labelText: 'Comensales',
                labelStyle: TextStyle(
                  color: Colors.black, 
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFFD2691E),
                    width: 1.3,
                  ),
                  borderRadius: BorderRadius.circular(18.0), 
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFFD2691E),
                    width: 1.3,
                  ),
                  borderRadius: BorderRadius.circular(18.0), 
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    Map<String, dynamic> actualizarInfo = {
                      "nombre": nombreController.text,
                      "descripcion": descripcionController.text,
                      "disponibilidad": disponibilidad,
                      "comensales": int.parse(comensalesController.text),
                    };
                    await DatabaseMethods().actualizardetallemesa(widget.userId, actualizarInfo);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Datos actualizados correctamente',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.black.withOpacity(0.7),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        duration: Duration(milliseconds: 800),
                      ),
                    );

                    Navigator.pop(context);
                  } catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Error al actualizar los datos',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.black.withOpacity(0.7),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        duration: Duration(milliseconds: 800),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFFA500), 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25), 
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 18), 
                  minimumSize: Size(250, 30), 
                ),
                child: Text(
                  "Actualizar",
                  style: TextStyle(
                    fontSize: 17, 
                    color: Colors.white, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
