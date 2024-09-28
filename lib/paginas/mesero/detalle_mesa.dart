import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ngcomanda/paginas/mesero/cobrar.dart';
import 'package:ngcomanda/paginas/mesero/ordenar.dart';
import 'seleccionar_platillos.dart';
import 'orden-service.dart'; 

class OrdenMesaPantalla extends StatefulWidget {
  final DocumentSnapshot mesa;
  final String alias;

  OrdenMesaPantalla({required this.mesa,required this.alias}); 

  @override
  _OrdenMesaPantallaState createState() => _OrdenMesaPantallaState();
}

class _OrdenMesaPantallaState extends State<OrdenMesaPantalla> {
  int _comensales = 0;
  int _usuarioSeleccionado = -1; // Índice del usuario seleccionado
  PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _comensales = widget.mesa['comensales'];
  }

  void _seleccionarUsuario(int index) {
    setState(() {
      _usuarioSeleccionado = index;
    });
    // Desplaza el PageView a la página correspondiente después de que se haya construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageController.jumpToPage(index);
    });
  }

  void _agregarUsuario() async {
    setState(() {
      _comensales++;
    });

    await OrdenService().sumarcomensalmesa(mesaId: widget.mesa.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Se agregó un nuevo usuario',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black.withOpacity(0.7),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        duration: Duration(milliseconds: 500),
      ),
    );
  }

  void _eliminarUsuario(int index) async {
    setState(() {
      if (_usuarioSeleccionado == index) {
        _usuarioSeleccionado = -1; // Desmarcar si el usuario eliminado está seleccionado
      }
      _comensales--;
    });

    await OrdenService().restarcomensalmesa(mesaId: widget.mesa.id);
  }

  void _ordenar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrdenarPantalla(mesaId: widget.mesa.id,alias:widget.alias),
      ),
    );
  }

  void _cobrar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CobrarPantalla(mesaId: widget.mesa.id,alias:widget.alias),
      ),
    );
  }

  Widget _buildUsuarioCard(int index) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => _seleccionarUsuario(index),
          child: Card(
            color: _usuarioSeleccionado == index ? Color(0xFFD2691E) : Color(0xFFFFFDD0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person,
                    size: 50,
                    color: _usuarioSeleccionado == index ? Colors.white : Colors.black,
                  ),
                  Text(
                    'Usuario ${index + 1}',
                    style: TextStyle(
                      color: _usuarioSeleccionado == index ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: 
          IconButton(
            icon: Icon(Icons.close, color: Color(0xFFD2691E), size: 22),
            onPressed: () {
              _eliminarUsuario(index);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Se eliminó un usuario',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.black.withOpacity(0.7),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  duration: Duration(milliseconds: 500),
                // Ajusta el ancho del SnackBar aquí
                ),
              );
            },
          )

        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF556B2F),
        elevation: 0,
        title: Text(
          'Mesa: ${widget.mesa['nombre']}',
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
        leading: _usuarioSeleccionado == -1
            ? null
            : IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _usuarioSeleccionado = -1;
                  });
                },
              ),
      ),
      body: Container(
        color: Color.fromARGB(255, 247, 246, 244),
        child: _usuarioSeleccionado == -1
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Descripción: ${widget.mesa['descripcion']}',
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Comensales: $_comensales',
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Seleccionar comensal:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // Tres columnas
                          mainAxisSpacing: 10.0,
                          crossAxisSpacing: 10.0,
                        ),
                        itemCount: _comensales,
                        itemBuilder: (context, index) {
                          return _buildUsuarioCard(index);
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    if (widget.mesa['disponibilidad'] == 'Ocupado')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ElevatedButton(
                            onPressed: _cobrar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFFA500),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              minimumSize: Size(120, 30), 
                            ),
                            child: Text(
                              'Cobrar',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _ordenar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFFA500),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              minimumSize: Size(120, 30), 
                            ),
                            child: Text(
                              'Ver para ordenar',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Center(
                        child: ElevatedButton(
                          onPressed: _ordenar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFFA500),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            minimumSize: Size(200, 30),
                          ),
                          child: Text(
                            'Ver para ordenar',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              )
            : PageView.builder(
                controller: _pageController,
                itemCount: _comensales,
                itemBuilder: (context, index) {
                  return SeleccionarPlatillosPantalla(
                    mesaId: widget.mesa.id,
                    numeroComensal: index + 1,
                    alias:widget.alias,
                  );
                },
              ),
      ),
      floatingActionButton: _usuarioSeleccionado == -1 
          ? FloatingActionButton(
              onPressed: _agregarUsuario,
              child: Icon(Icons.add, color: Colors.white),
              backgroundColor: Color(0xFFD2691E),
            )
          : null, 
    );
  }
}
