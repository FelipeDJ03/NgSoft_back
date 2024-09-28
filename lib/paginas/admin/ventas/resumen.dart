import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ngcomanda/paginas/admin/ventas/lista-ventas.dart';
import 'package:ngcomanda/paginas/admin/ventas/ventas-service.dart';

class ResumenVWidget extends StatelessWidget {
   final String alias;

  ResumenVWidget({required this.alias}); 
  @override
  Widget build(BuildContext context) {
    final ventasService = VentasService();


    return StreamBuilder<QuerySnapshot>(
      stream: ventasService.streamTotalVentasPorMetodoPago(alias:alias),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text('No hay datos disponibles');
        }

        // Data is ready
        List<DocumentSnapshot> ventas = snapshot.data!.docs;
        Map<String, dynamic> totalVentasPorMetodoPago = {};
        int totalVentas = 0;

        // Calculate total ventas totales
        ventas.forEach((venta) {
          var data = venta.data() as Map<String, dynamic>;
          String metodoPago = data['metodoPago'] ?? '';

          if (!totalVentasPorMetodoPago.containsKey(metodoPago)) {
            totalVentasPorMetodoPago[metodoPago] = {'total': 0.0, 'cantidad': 0};
          }

          totalVentasPorMetodoPago[metodoPago]['total'] += data['total'] ?? 0.0;
          totalVentasPorMetodoPago[metodoPago]['cantidad']++;
          totalVentas++;
        });

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Show total del campo total de todas las ventas
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Padding(
                          padding: const EdgeInsets.only(left: 27.0, bottom: 15, top: 17), 
                          child: Text('Ventas: $totalVentas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 27.0, bottom: 15, top: 17), 
                          child: Text('Total: \$${_calcularTotalVentas(totalVentasPorMetodoPago).toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Show total de ventas por método de pago
              Container(
                height: 300,
                padding: EdgeInsets.all(16),
                child: PieChart(
                  PieChartData(
                    sections: _getPieChartSections(totalVentasPorMetodoPago),
                    sectionsSpace: 0,
                    centerSpaceRadius: 50,
                    
                    //animationDuration: Duration(milliseconds: 500),
                    //chartLegendSpacing: 32,
                    // Define other properties as needed
                  ),
                   
                ),
              ),
              SizedBox(height: 38),

              // Show details for each method of payment
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: totalVentasPorMetodoPago.entries.map((entry) {
                  String metodoPago = entry.key;
                  double totalVentas = entry.value['total'];
                  int cantidadVentas = entry.value['cantidad'];
                  Color color = metodoPago == 'Efectivo'
                      ? Color(0xFFFFA500)
                      : Color(0xFF556B2F);
            
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            color: color,
                          ),
                          SizedBox(width: 8),
                          Text(metodoPago),
                        ],
                      ),
                      SizedBox(height: 2),
                      Padding(
                        padding: const EdgeInsets.only(left: 25.0), 
                        child: Text('Ventas: $cantidadVentas'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 25.0),
                        child: Text('Total: \$${totalVentas.toStringAsFixed(0)}'),
                      ),                  
                    ],
                  );
                  
                }).toList(),
              ),
              SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                   onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ListaVentas(alias:alias)),
                  );
                },
                  style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFFA500),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                  minimumSize: Size(280, 30),
                ),
                child: Text(
                  'Detalles',
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
        );
      },
    );
  }


  double _calcularTotalVentas(Map<String, dynamic> totalVentasPorMetodoPago) {
    double totalVentasTotales = 0.0;
    totalVentasPorMetodoPago.forEach((key, value) {
      totalVentasTotales += value['total'];
    });
    return totalVentasTotales;

    
  }

  List<PieChartSectionData> _getPieChartSections(Map<String, dynamic> totalVentasPorMetodoPago) {
    List<PieChartSectionData> pieChartSections = [];

    totalVentasPorMetodoPago.forEach((metodoPago, value) {
      double totalVentas = value['total'] ?? 0.0;
      if (totalVentas > 0) {
        pieChartSections.add(
          PieChartSectionData(
            value: totalVentas,
            title: metodoPago,
            color: metodoPagoChartColors[metodoPago] ?? Colors.blue, // Define your color map or default color here
            radius: 100,
            titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        );
      }
    });

    return pieChartSections;
  }
}

const Map<String, Color> metodoPagoChartColors = {
  'Efectivo': Color(0xFFFFA500),
  'Transferencia': Color(0xFF556B2F),
  // Add more colors for other payment methods
};
