import 'package:flutter/material.dart';
import 'cocina-service.dart'; // Asegúrate de importar correctamente tu servicio de cocina

class Editarcocina extends StatefulWidget {
  final String userId;
    final List<Color?> coloresRestaurante;

  const Editarcocina({Key? key, required this.userId,required this.coloresRestaurante}) : super(key: key);

  @override
  _EditarcocinaState createState() => _EditarcocinaState();
}

class _EditarcocinaState extends State<Editarcocina> {
  TextEditingController nombreController = TextEditingController();
  TextEditingController descripcionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    obtenerDetallecocina();
  }

  Future<void> obtenerDetallecocina() async {
    print(widget.userId);
    // Utiliza el método de tu servicio para obtener los detalles del cocina
    Map<String, dynamic>? cocina = await DatabaseMethods().ObtenerDetallecocinas(widget.userId);
    setState(() {
      nombreController.text = cocina?['nombre'];
      descripcionController.text = cocina?['descripcion'];
    });
  }

  Future<void> actualizarcocina() async {
    try {
      Map<String, dynamic> actualizarInfo = {
        "nombre": nombreController.text,
        "descripcion": descripcionController.text,
      };
      await DatabaseMethods().actualizardetallecocina(widget.userId, actualizarInfo);


      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Datos actualizados correctamente',
            style: TextStyle(color: widget.coloresRestaurante[3]),
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
            style: TextStyle(color: widget.coloresRestaurante[3]),
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
            backgroundColor: widget.coloresRestaurante[0],
            elevation: 0,
            title: Text(
              'Editar Categoría',
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
                fillColor: widget.coloresRestaurante[3],
                labelText: 'Nombre',
                labelStyle: TextStyle(
                  color: widget.coloresRestaurante[4], 
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: widget.coloresRestaurante[1]!,
                    width: 1.3,
                  ),
                  borderRadius: BorderRadius.circular(18.0), 
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: widget.coloresRestaurante[1]!,
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
                fillColor: widget.coloresRestaurante[3],
                labelText: 'Descripción',
                labelStyle: TextStyle(
                  color: widget.coloresRestaurante[4], 
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: widget.coloresRestaurante[1]!,
                    width: 1.3,
                  ),
                  borderRadius: BorderRadius.circular(18.0), 
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: widget.coloresRestaurante[1]!,
                    width: 1.3,
                  ),
                  borderRadius: BorderRadius.circular(18.0), 
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Center(
              child: ElevatedButton(
                onPressed: actualizarcocina,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.coloresRestaurante[1], 
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
                    color: widget.coloresRestaurante[3], 
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
