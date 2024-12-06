import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ngcomanda/paginas/admin/categorias/editar-categoria.dart';
import 'package:ngcomanda/paginas/admin/categorias/registrar-categoria.dart';
import 'package:ngcomanda/paginas/splash.dart';
import 'ventas-service.dart';
import 'package:flutter/material.dart';

class ListaVentas extends StatefulWidget {
  final String alias;
      final List<Color?> coloresRestaurante;

  const ListaVentas({super.key,required this.alias,required this.coloresRestaurante});

  @override
  _ListaVentasState createState() => _ListaVentasState();
}

class _ListaVentasState extends State<ListaVentas> {
  Stream? ventaStream;

  @override 
  void initState() {
    getontheload();
    super.initState();
  }

  getontheload() async {
    ventaStream = await VentasService().ObtenerDetalleventas(alias:widget.alias);
    setState(() {});
  }

  Widget Todoslosventas() {
    return StreamBuilder(
      stream: ventaStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SplashPantalla(); // Muestra la pantalla de carga mientras se cargan los datos
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = snapshot.data.docs[index];
             
              return Container(
              margin: EdgeInsets.only(bottom: 18.0),
              child: Material(
                elevation: 2.0,
                borderRadius: BorderRadius.circular(2),
                child: ExpansionTile(
                  title: 
                  Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0), 
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Folio: ${ds['folio']}",
                        style: TextStyle(
                          color: widget.coloresRestaurante[4],
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "\$${ds['total']}",
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
                  backgroundColor:  widget.coloresRestaurante[3],
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
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        
                                        "Método de Pago: ${ds['metodoPago']}",
                                        style: TextStyle(
                                          color: widget.coloresRestaurante[4],
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "Hora: ${ds['hora']}",
                                      style: TextStyle(
                                        color: widget.coloresRestaurante[4],
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ],
                                ),
                            SizedBox(height: 12),
                            Text(
                              "Productos:",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                for (var producto in ds['productos'])
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "${producto['nombre']}",
                                            style: TextStyle(
                                              color: widget.coloresRestaurante[4],
                                              fontSize: 16.0,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "\$${producto['precio']}",
                                          style: TextStyle(
                                            color: widget.coloresRestaurante[4],
                                            fontSize: 16.0,
                                          ),
                                        ),
                                      ],
                                    ),
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
                            Text(
                              "Total: ${ds['total']}",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
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
          );
        } else {
          return Container();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 233, 233, 233),
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
            backgroundColor: widget.coloresRestaurante[0]!,
            elevation: 0,
            title: Text(
              'Ventas',
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
      body: Container(
        margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
        child: Column(
          children: [
            Expanded(child: Todoslosventas()),
          ],
        ),
      ),
    );
  }
}
