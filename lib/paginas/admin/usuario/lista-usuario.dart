import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ngcomanda/paginas/admin/usuario/editar-usuario.dart';
import 'package:ngcomanda/paginas/admin/usuario/registrar-usuario.dart';
import 'package:ngcomanda/paginas/splash.dart';
import 'usuario-service.dart';
import 'package:flutter/material.dart';

class ListaUsuario extends StatefulWidget {
  final String alias;
      final List<Color?> coloresRestaurante;

  const ListaUsuario({super.key,required this.alias,required this.coloresRestaurante});

  @override
  _ListaUsuarioState createState() => _ListaUsuarioState();
}

class _ListaUsuarioState extends State<ListaUsuario> {
  TextEditingController namecontroller = TextEditingController();
  TextEditingController apellidocontroller = TextEditingController();
  TextEditingController locationcontroller = TextEditingController();
  Stream? EmployeeStream;

  getontheload() async {
    EmployeeStream = await DatabaseMethods().ObtenerDetalleusuarios(widget.alias);
    setState(() {});
  }

  @override
  void initState() {
    getontheload();
    super.initState();
  }

  void editarDetallesUsuario(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarUsuario(userId: userId,coloresRestaurante:widget.coloresRestaurante,
      ),
    ));
  }

  Widget TodoslosUsuarios() {
    return StreamBuilder(
      stream: EmployeeStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SplashPantalla();
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = snapshot.data.docs[index];
              return Container(
                margin: EdgeInsets.only(bottom: 20.0),
                child: Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(0),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: widget.coloresRestaurante[1],
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: widget.coloresRestaurante[3]!, width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: ds['image_url'] != null
                                    ? NetworkImage(ds['image_url']!)
                                    : null,
                                radius: 25,
                                child: ds['image_url'] == null
                                    ? Icon(Icons.person, size: 50)
                                    : null,
                              ),
                              SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${ds['nombre']} ${ds['apellido']}",
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 17.0,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "(${ds['rol']})",
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 15.0,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Divider(color: widget.coloresRestaurante[3]!, thickness: 2, height: 0),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  SizedBox(width: 15),
                                  Icon(Icons.location_on, color: widget.coloresRestaurante[3], size: 16),
                                  SizedBox(width: 5),
                                  Text(
                                    "(${ds['direccion']})",
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  SizedBox(width: 15),
                                  Icon(Icons.email, color: widget.coloresRestaurante[3], size: 16),
                                  SizedBox(width: 5),
                                  Text(
                                    "(${ds['email']})",
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  SizedBox(width: 15),
                                  Icon(Icons.phone, color: widget.coloresRestaurante[3], size: 16),
                                  SizedBox(width: 5),
                                  Text(
                                    "(${ds['celular']})",
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      editarDetallesUsuario(ds.id);
                                    },
                                    child: Icon(Icons.edit, color: widget.coloresRestaurante[3]),
                                  ),
                                  SizedBox(width: 16),
                                  GestureDetector(
                                    onTap: () {
                                      ModalEliminar(ds.id);
                                    },
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              )

                            ],
                          ),
                        ),
                      ],
                    ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => REG_USUARIOPagina(alias:widget.alias,coloresRestaurante:widget.coloresRestaurante)));
        },
        child: Icon(Icons.add, color: widget.coloresRestaurante[3]),
        backgroundColor: widget.coloresRestaurante[2],
      ),
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
              'Usuarios',
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
        margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 45.0),
        child: Column(
          children: [
            Expanded(child: TodoslosUsuarios()),
          ],
        ),
      ),
    );
  }


void ModalEliminar(String usuarioID) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: 300,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20),
                Icon(
                  Icons.check_circle_outline,
                  color: widget.coloresRestaurante[1],
                  size: 80,
                ),
                SizedBox(height: 20),
                Text(
                  'Confirmar Acción',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '¿Estás seguro que quieres eliminar este Usuario? ',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await DatabaseMethods().Eliminarusuario(usuarioID);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Se ha eliminado un Usuario',
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.black.withOpacity(0.7),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              margin: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 20),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              duration: Duration(milliseconds: 800),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: Text(
                          'Sí',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: Text(
                          'No',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
