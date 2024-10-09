import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =FlutterLocalNotificationsPlugin();

Future<void> initNotifications()async{
  const AndroidInitializationSettings initializationSettingsAndroid= AndroidInitializationSettings('logo');

  const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<void> mostrarNotificacion( String s)async{
  const AndroidNotificationDetails androidNotificationDetails=
  AndroidNotificationDetails('Entrega', 'hola');

  const DarwinNotificationDetails darwinNotificationDetails=DarwinNotificationDetails();

  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidNotificationDetails,
    iOS: darwinNotificationDetails
  );

  await flutterLocalNotificationsPlugin.show(
      1, 
      'Entrega', 
      '"$s" listo para entregar', 
      notificationDetails);
}
Future<void> mostrarNotificacioncocina( String s)async{
  const AndroidNotificationDetails androidNotificationDetails=
  AndroidNotificationDetails('Pedido', 'H');

  const DarwinNotificationDetails darwinNotificationDetails=DarwinNotificationDetails();

  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidNotificationDetails,
    iOS: darwinNotificationDetails
  );

  await flutterLocalNotificationsPlugin.show(
      1, 
      'Pedido a cocina', 
      '"$s" ah llegado', 
      notificationDetails);
}