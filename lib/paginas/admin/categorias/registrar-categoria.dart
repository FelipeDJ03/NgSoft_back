import 'package:ngcomanda/paginas/admin/categorias/lista-categoria.dart';
import 'categoria-service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:random_string/random_string.dart';

class REG_Categoria extends StatefulWidget {
  final String alias;
      final List<Color?> coloresRestaurante;

  const REG_Categoria({super.key,required this.alias,required this.coloresRestaurante});

  @override
  State<REG_Categoria> createState() => _REG_CategoriaState();
}

class _REG_CategoriaState extends State<REG_Categoria> {
  final _formKey = GlobalKey<FormState>(); // Form key to identify the form
  TextEditingController nombrecontroller = TextEditingController();
  TextEditingController descripcioncontroller = TextEditingController();

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
              'Categorías',
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
        margin: const EdgeInsets.only(left: 20.0, top: 15.0, right: 20.0),
        child: Form(
          key: _formKey, // Attach the form key to the Form widget
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: nombrecontroller,
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
                    return 'Por favor ingrese un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: descripcioncontroller,
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
                    return 'Por favor ingrese una descripción';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      String Id = randomAlphaNumeric(10);
                      Map<String, dynamic> CategoriaInfoMap = {
                        "nombre": nombrecontroller.text,
                        "descripcion": descripcioncontroller.text,
                        "Id": Id,
                        "alias":widget.alias,
                      };
                      await DatabaseMethods().addcategoriaDetalles(CategoriaInfoMap, Id).then((value) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'La Categoría se ha registrado de forma exitosa',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.black.withOpacity(0.7),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            duration: Duration(milliseconds: 900),
                          ),
                        );
                        // Regresar a la lista de categorías
                        Navigator.pop(context);
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFA500), // Color de fondo del botón
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25), // Borde redondeado del botón
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 18), // Padding interno del botón
                    minimumSize: Size(250, 30), // Tamaño mínimo del botón
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
