import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ngcomanda/paginas/login.dart';

// import 'package:ngcomanda/widgets/imagen_logo.dart';

class Configuracion extends StatefulWidget {
  final String alias;
      final List<Color?> coloresRestaurante;

  const Configuracion({super.key, required this.alias,required this.coloresRestaurante});

  @override
  _ConfiguracionState createState() => _ConfiguracionState();
}  

Color determineTextColor(Color backgroundColor) {
  double luminance = backgroundColor.computeLuminance();
  return luminance > 0.5 ? Color.fromARGB(255, 40, 40, 61) : Colors.white;
}

class _ConfiguracionState extends State<Configuracion> {
  File? _imagenSeleccionada;
  late Color color1;
  late Color color2;
  late Color color3;
  late Color color4;
  late Color color5;

 @override
  void initState() {
    super.initState();

    // Asignamos los colores de la lista a las variables locales
    color1 = widget.coloresRestaurante[0] ?? Colors.white; // Si es nulo, asignamos un color por defecto
    color2 = widget.coloresRestaurante[1] ?? Colors.white;
    color3 = widget.coloresRestaurante[2] ?? Colors.white;
    color4 = widget.coloresRestaurante[3] ?? Colors.white;
    color5 = widget.coloresRestaurante[4] ?? Colors.white;
  }
  List<List<Color>> sugerenciasPaletas = [];
  String? categoriaSeleccionada;

  final picker = ImagePicker();
  
 // Paletas de colores por categoría
  final Map<String, List<List<Color>>> paletasPorCategoria = {
    'Comida rápida': [
      [Color(0xFFFF0000), Color(0xFFFFC300), Color(0xFFFF8C00), Color(0xFFFFFFFF), Color(0xFF000000)],
    ],
    'Comida saludable': [
      [Color(0xFF00A676), Color(0xFFF5F5DC), Color(0xFF8B4513), Color(0xFFFFFFFF), Color(0xFF000000)],
    ],
    'Marisquería': [
      [Color(0xFF0077B6), Color(0xFF40E0D0), Color(0xFFFFE4B5), Color(0xFFFFFFFF), Color(0xFF000000)],
    ],
    'Restaurante gourmet': [
      [Color(0xFF800020), Color(0xFFD4AF37), Color(0xFFFFFDD0), Color(0xFFFFFFFF), Color(0xFF000000)],
    ],
    'Buffet': [
      [Color(0xFFFFA500), Color(0xFFA3C586), Color(0xFFFFFDD0), Color(0xFFFFFFFF), Color(0xFF000000)],
    ],
    'Taquería': [
      [Color(0xFFFF4500), Color(0xFF228B22), Color(0xFFFFD700), Color(0xFFFFFFFF), Color(0xFF000000)],
    ],
    'Parrilladas o asadores': [
      [Color(0xFF8B4513), Color(0xFFB22222), Color(0xFFA9A9A9), Color(0xFFFFFFFF), Color(0xFF000000)],
    ],
    'Pizzería': [
      [Color(0xFFFF6347), Color(0xFF32CD32), Color(0xFFFFD700), Color(0xFFFFFFFF), Color(0xFF000000)],
    ],
    'Cafetería': [
      [Color(0xFF6F4E37), Color(0xFFFFF8E7), Color(0xFFD2B48C), Color(0xFFFFFFFF), Color(0xFF000000)],
    ],
    'Restaurante de sushi': [
      [Color(0xFF003366), Color(0xFFFF7F50), Color(0xFF9ACD32), Color(0xFFFFFFFF), Color(0xFF000000)],
    ],
    'Restaurante mexicano tradicional': [
      [Color(0xFF006400), Color(0xFFB22222), Color(0xFFFFDA44), Color(0xFFFFFFFF), Color(0xFF000000)],
    ],
    'Comida mediterránea': [
      [Color(0xFF87CEEB), Color(0xFFFF8C00), Color(0xFFF4A460), Color(0xFFFFFFFF), Color(0xFF000000)],
    ],
    'Vegetariano/Vegano': [
      [Color(0xFF7FB77E), Color(0xFF8B4513), Color(0xFFFFFF99), Color(0xFFFFFFFF), Color(0xFF000000)],
    ],
  };

  void actualizarPaletasSugeridas() {
    setState(() {
      sugerenciasPaletas = paletasPorCategoria[categoriaSeleccionada] ?? [];
      if (sugerenciasPaletas.isNotEmpty) {
        color1 = sugerenciasPaletas[0][0];
        color2 = sugerenciasPaletas[0][1];
        color3 = sugerenciasPaletas[0][2];
        color4 = sugerenciasPaletas[0][3];
        color5 = sugerenciasPaletas[0][4];
      }
    });
  }

 Future<void> guardarEnFirebase() async {
  try {
    // Guardar los colores en Firebase
    await FirebaseFirestore.instance.collection('restaurantes').doc(widget.alias).update({
      'color1': color1.value.toRadixString(16),
      'color2': color2.value.toRadixString(16),
      'color3': color3.value.toRadixString(16),
      'color4': color4.value.toRadixString(16),
      'color5': color5.value.toRadixString(16),
    });

    // Cerrar la sesión después de que se guarden los datos
    await FirebaseAuth.instance.signOut();

    // Redirigir al usuario a la pantalla de LOGINPantalla
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => MyApp()),
    );
    
  } catch (e) {
    // Manejar el error si falla el guardado o el cierre de sesión
    print('Error al guardar los colores o cerrar la sesión: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Configuración Visual',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: color1,
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            // Sección de Selección de logo
            Text('Selecciona tu Logo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            // ImagenLogoPicker(
            //   onPickImage: (imagenElegida) {
            //     setState(() {
            //       _imagenSeleccionada = imagenElegida;
            //     });
            //   },
            // ),
            Divider(height: 30, thickness: 1),

            // Sección de Selección de categoría de restaurante
            Text('Selecciona la Categoría del Restaurante', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              hint: Text('Selecciona una categoría', style: TextStyle(color: Colors.grey[600])),
              value: categoriaSeleccionada,
              onChanged: (String? newValue) {
                setState(() {
                  categoriaSeleccionada = newValue;
                });
                actualizarPaletasSugeridas();
              },
              items: paletasPorCategoria.keys.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                );
              }).toList(),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[400]!, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: color1, width: 2),
                ),
              ),
            ),
            Divider(height: 30, thickness: 1),

            // Sección de Paleta de colores actual
            Text('Paleta de Colores', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [color1, color2, color3, color4, color5].map((color) => Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
              )).toList(),
            ),
            Divider(height: 30, thickness: 1),

            SizedBox(height: 15,),
            // Botón para guardar configuración
            ElevatedButton(
              onPressed: guardarEnFirebase,
              style: ElevatedButton.styleFrom(
                backgroundColor: color2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                minimumSize: Size(300, 30),
              ),
              child: Text(
                'Guardar Configuración',
                style: TextStyle(
                  fontSize: 16,
                  color: determineTextColor(color2),
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
