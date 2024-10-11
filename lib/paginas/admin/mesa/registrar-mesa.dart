import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:random_string/random_string.dart';
import 'mesa-service.dart';

enum Disponibilidad { disponible, ocupado }

class REG_Mesa extends StatefulWidget {
  final String alias;
      final List<Color?> coloresRestaurante;

  const REG_Mesa({Key? key, required this.alias, required this.coloresRestaurante}) : super(key: key);

  @override
  State<REG_Mesa> createState() => _REG_MesaState();
}

class _REG_MesaState extends State<REG_Mesa> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nombreController = TextEditingController();
  TextEditingController descripcionController = TextEditingController();
  Disponibilidad? _selectedDisponibilidad;
  TextEditingController comensalesController = TextEditingController();

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
            backgroundColor: widget.coloresRestaurante[0],
            elevation: 0,
            title: const Text(
              'Registrar Mesa',
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
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.0),
              TextFormField(
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              TextFormField(
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una descripción';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              DropdownButtonFormField<Disponibilidad>(
                value: _selectedDisponibilidad,
                items: [
                  DropdownMenuItem(
                    value: Disponibilidad.disponible,
                    child: Text('Disponible'),
                  ),
                  DropdownMenuItem(
                    value: Disponibilidad.ocupado,
                    child: Text('Ocupado'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedDisponibilidad = value;
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
                validator: (value) {
                  if (value == null) {
                    return 'Por favor selecciona una disponibilidad';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              TextFormField(
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el número de comensales';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'El número de comensales debe ser mayor que cero';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      String Id = randomAlphaNumeric(10);
                      Map<String, dynamic> mesaInfoMap = {
                        "nombre": nombreController.text,
                        "descripcion": descripcionController.text,
                        "disponibilidad": _selectedDisponibilidad == Disponibilidad.disponible ? 'Disponible' : 'Ocupado',
                        "comensales": int.parse(comensalesController.text),
                        "Id": Id,
                        "alias":widget.alias,

                      };
                      try {
                        await DatabaseMethods().addmesaDetalles(mesaInfoMap, Id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'La Mesa se ha registrado de forma exitosa',
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
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Error al registrar la mesa',
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
                    "Agregar",
                    style: TextStyle(
                      fontSize: 17, 
                      color: Colors.white, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
