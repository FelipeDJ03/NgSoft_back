import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ngcomanda/paginas/admin/categorias/lista-categoria.dart';
import 'package:ngcomanda/paginas/admin/cocinas/lista-cocina.dart';
import 'package:ngcomanda/paginas/admin/combo/lista-combo.dart';
import 'package:ngcomanda/paginas/admin/configuracion.dart';
import 'package:ngcomanda/paginas/admin/mesa/lista-mesa.dart';
import 'package:ngcomanda/paginas/admin/producto/lista-producto.dart';
import 'package:ngcomanda/paginas/admin/ventas/resumen.dart';
import 'package:ngcomanda/paginas/admin/usuario/lista-usuario.dart';
import 'package:ngcomanda/paginas/cocinero/ordenes_cocina.dart';
import 'package:ngcomanda/paginas/mesero/iniciar_comanda.dart';
import 'package:ngcomanda/paginas/mesero/orden_entregar.dart';

class INICIOPantalla extends StatefulWidget {
  const INICIOPantalla({super.key});

  @override
  State<INICIOPantalla> createState() => _INICIOPantallaState();
} 

class _INICIOPantallaState extends State<INICIOPantalla> {
  String? _userRole;
  String? _userName;
  String? _userImageUrl;
  String? alias;
  String? status;
  String? usuarioid;


  Color? color1 ;
  Color? color2 ;
  Color? color3 ;
  Color? color4 ;
  Color? color5;
  List<Color?> coloresRestaurante = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

       alias = userDoc['alias'];
       usuarioid = user.uid;
      // Consultamos el restaurante con el alias como ID
      final restaurantDoc = await FirebaseFirestore.instance
          .collection('restaurantes')
          .doc(alias)
          .get();

      if (restaurantDoc.exists) {
      setState(() {
        // Obtenemos el estado del restaurante
        status = restaurantDoc['estado'];
        _userRole = userDoc['rol'];
        _userName = userDoc['nombre'];
        _userImageUrl = userDoc['image_url'];

         // Definimos los colores del restaurante
       // Almacenamos los colores en las variables locales
        color1 = _convertirHexAColor(restaurantDoc['color1']);
        color2 = _convertirHexAColor(restaurantDoc['color2']);
        color3 = _convertirHexAColor(restaurantDoc['color3']);
        color4 = _convertirHexAColor(restaurantDoc['color4']);
        color5 = _convertirHexAColor(restaurantDoc['color5']);

        coloresRestaurante = [
          color1,
          color2,
          color3,
          color4,
          color5,
        ];
        _isLoading = false;
      });
    }
    }

 
  }

  // Función para convertir de hex string a Color en Flutter
Color _convertirHexAColor(String hexColor) {
  // Elimina el símbolo '#' si está presente
  hexColor = hexColor.replaceAll("#", "");

  // Si el color tiene solo 6 caracteres (sin transparencia), añade 'FF' para la opacidad
  if (hexColor.length == 6) {
    hexColor = "FF$hexColor"; // Añade 'FF' al inicio para que sea 100% opaco
  }

  // Convierte el string en un valor entero y luego crea el objeto Color
  return Color(int.parse("0x$hexColor"));
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 233, 233, 233), // Color de fondo
      appBar: AppBar(
  backgroundColor: color1,
  iconTheme: IconThemeData(
    color: Colors.white, // Color blanco para el ícono de menú y flecha de regreso
  ),
  title: Row(
    children: [
      _userImageUrl != null
          ? CircleAvatar(
              backgroundImage: NetworkImage(_userImageUrl!),
            )
          : Icon(Icons.person),
      SizedBox(width: 10),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _userName ?? 'Usuario',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            _userRole ?? 'Rol',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ],
  ),
  leading: _userRole == 'admininistrador'
      ? Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        )
      : null,
  actions: [
    if(_userRole!= 'administrador' && _userRole!= 'cocinero')
    IconButton(
      onPressed: () {
      Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListaMesas(alias: alias!,usuarioid:usuarioid!,coloresRestaurante: coloresRestaurante
),
      ),
    );
      },
      
      icon: Icon(
        Icons.notifications_rounded,
        color: Colors.white,
      ),
    ),
    IconButton(
      onPressed: () {
        FirebaseAuth.instance.signOut();
      },
      icon: Icon(
        Icons.exit_to_app,
        color: Colors.white,
      ),
    ),
  ],
),
    drawer: (_userRole == 'administrador' && status != 'inactivo')

    ? Drawer(
       
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: color2,
              ),
              child: Row(
                children: [
                  _userImageUrl != null
                      ? CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(_userImageUrl!),
                        )
                      : Icon(Icons.person, size: 60, color: Colors.white),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _userName ?? 'Admin',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
      
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _userRole ?? 'Administrador',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_userRole == 'administrador') 
              Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.person, color: color2, size: 35,),
                    title: Text(
                      'Usuarios',
                      style: TextStyle(
                        fontSize: 18, 
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop(); 
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ListaUsuario(alias: alias!,coloresRestaurante: coloresRestaurante),
                        ),
                      );
                    },
                  ),
                  Divider(thickness: 1, color: Colors.grey[300]),
                ],
              ),
            if (_userRole == 'administrador')
              Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.category, color: color2, size: 35,),
                    title: Text(
                      'Categorías',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop(); 
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ListaCategoria(alias: alias!,coloresRestaurante: coloresRestaurante),
                        ),
                      );
                    },
                  ),
                  Divider(thickness: 1, color: Colors.grey[300]),
                ],
              ),
            if (_userRole == 'administrador')
              Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.kitchen, color: color2, size: 35,),
                    title: Text(
                      'Cocinas',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop(); 
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Listacocina(alias: alias!,coloresRestaurante: coloresRestaurante),
                        ),
                      );
                    },
                  ),
                  Divider(thickness: 1, color: Colors.grey[300]),
                ],
              ),
            if (_userRole == 'administrador')
              Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.fastfood, color: color2, size: 35,),
                    title: Text(
                      'Productos',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop(); 
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ListaProducto(alias: alias!,coloresRestaurante: coloresRestaurante),
                        ),
                      );
                    },
                  ),
                  Divider(thickness: 1, color: Colors.grey[300]),
                ],
              ),
            if (_userRole == 'administrador')
              Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.table_bar, color: color2, size: 35,),
                    title: Text(
                      'Mesas',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop(); 
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ListaMesa(alias: alias!,coloresRestaurante: coloresRestaurante),
                        ),
                      );
                    },
                  ),
                  Divider(thickness: 1, color: Colors.grey[300]),
                ],
              ),
            if (_userRole == 'administrador')
              Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.local_offer, color: color2, size: 35,),
                    title: Text(
                      'Combos',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop(); 
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ListaCombo(alias: alias!,coloresRestaurante: coloresRestaurante),
                        ),
                      );
                    },
                  ),
                  Divider(thickness: 1, color: Colors.grey[300]),
                ],
              ),
            if (_userRole == 'administrador')
              Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.settings, color: color2, size: 35,),
                    title: Text(
                      'Configuración',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop(); 
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Configuracion(alias: alias!,coloresRestaurante:coloresRestaurante),
                        ),
                      );
                    },
                  ),
                  Divider(thickness: 1, color: Colors.grey[300]),
                ],
              ),
           
          ],
        ),
      ):null,
       body: Center(
            child: _isLoading
                ? CircularProgressIndicator()
                 : status == 'inactivo'
            ? Center(
                child: Text(
                  'Restaurante inactivo',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_userRole == 'administrador')
                    Expanded(child: ResumenVWidget(alias:alias!,coloresRestaurante: coloresRestaurante)),
                  if (_userRole == 'cocinero')
                    Expanded(child: OrdenesCocinaPage(alias:alias!,coloresRestaurante: coloresRestaurante)),
                  if (_userRole == 'mesero')
                    Expanded(child: OrdenEntregar(alias:alias!,coloresRestaurante: coloresRestaurante)),
                ],
              ),
          ),

    ); 

    
  }
}
