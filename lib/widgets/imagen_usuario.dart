import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagenUsuarioPicker extends StatefulWidget {
  const ImagenUsuarioPicker({
    super.key, 
    required this.onPickImage, 
    this.imagenPredeterminadaURL,
  });

  final void Function(File imagenElegida) onPickImage;
  final String? imagenPredeterminadaURL; // URL de la imagen predeterminada

  @override
  State<ImagenUsuarioPicker> createState() {
    return _ImagenUsuarioPickerState();
  }
}

class _ImagenUsuarioPickerState extends State<ImagenUsuarioPicker> {
  File? _imagenElegidaFile;

  void _pickImage(ImageSource source) async {
    final imagenElegida = await ImagePicker().pickImage(
      source: source,
      imageQuality: 50,
      maxWidth: 150,
    );

    if (imagenElegida == null) {
      return;
    }

    setState(() {
      _imagenElegidaFile = File(imagenElegida.path);
    });

    widget.onPickImage(_imagenElegidaFile!);
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Seleccione el origen de la imagen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('Cámara'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 155,
          height: 155,
          child: CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey,
            foregroundImage: _imagenElegidaFile != null
                ? FileImage(_imagenElegidaFile!)
                : (widget.imagenPredeterminadaURL != null
                    ? NetworkImage(widget.imagenPredeterminadaURL!) as ImageProvider
                    : null),
          ),
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: _showImageSourceDialog,
          icon: const Icon(Icons.camera_alt_outlined, color: Colors.black),
          label: const Text(
            'Añadir imagen',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }
}
