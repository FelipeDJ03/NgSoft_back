import 'package:flutter/material.dart';
import 'categoria-service.dart'; // Asegúrate de importar correctamente tu servicio de categoria

class Editarcategoria extends StatefulWidget {
  final String userId;

  const Editarcategoria({Key? key, required this.userId}) : super(key: key);

  @override
  _EditarcategoriaState createState() => _EditarcategoriaState();
}

class _EditarcategoriaState extends State<Editarcategoria> {
  TextEditingController nombreController = TextEditingController();
  TextEditingController descripcionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    obtenerDetallecategoria();
  }

  Future<void> obtenerDetallecategoria() async {
    print(widget.userId);
    // Utiliza el método de tu servicio para obtener los detalles del categoria
    Map<String, dynamic>? categoria = await DatabaseMethods().ObtenerDetallecategorias(widget.userId);
    setState(() {
      nombreController.text = categoria?['nombre'];
      descripcionController.text = categoria?['descripcion'];
    });
  }

  Future<void> actualizarCategoria() async {
    try {
      Map<String, dynamic> actualizarInfo = {
        "nombre": nombreController.text,
        "descripcion": descripcionController.text,
      };
      await DatabaseMethods().actualizardetallecategoria(widget.userId, actualizarInfo);


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
              'Editar Categoría',
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
            SizedBox(height: 20.0),
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
            Center(
              child: ElevatedButton(
                onPressed: actualizarCategoria,
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
