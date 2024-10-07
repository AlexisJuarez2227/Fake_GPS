import 'dart:async';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

void main() {
  runApp(UbicacionVerificadaApp());
}

class UbicacionVerificadaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Verificación de Ubicación',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UbicacionScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class UbicacionScreen extends StatefulWidget {
  @override
  _UbicacionScreenState createState() => _UbicacionScreenState();
}

class _UbicacionScreenState extends State<UbicacionScreen> {
  final Location location = Location();
  String _estadoGps = 'Verificando...';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Inicia el Timer para verificar cada 10 segundos
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      verificarUbicacion();
    });
    verificarUbicacion(); // Verificación inicial al iniciar la app
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancelar el timer al salir del widget
    super.dispose();
  }

  Future<void> verificarUbicacion() async {
    bool servicioHabilitado;
    PermissionStatus permisoConcedido;

    // Verificar si el servicio de ubicación está habilitado
    servicioHabilitado = await location.serviceEnabled();
    if (!servicioHabilitado) {
      servicioHabilitado = await location.requestService();
      if (!servicioHabilitado) {
        setState(() {
          _estadoGps = 'GPS desactivado';
        });
        return;
      }
    }

    // Verificar permisos
    permisoConcedido = await location.hasPermission();
    if (permisoConcedido == PermissionStatus.denied) {
      permisoConcedido = await location.requestPermission();
      if (permisoConcedido != PermissionStatus.granted) {
        setState(() {
          _estadoGps = 'Permiso de ubicación denegado';
        });
        return;
      }
    }

    // Obtener ubicación y verificar si es falsa
    LocationData ubicacion = await location.getLocation();
    if (ubicacion.isMock != null && ubicacion.isMock!) {
      setState(() {
        _estadoGps = 'Ubicación Falsa';
      });
    } else {
      setState(() {
        _estadoGps = 'Ubicación Real';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verificación de Ubicación'),
      ),
      body: Center(
        child: Text(
          _estadoGps,
          style: TextStyle(fontSize: 24, color: Colors.black),
        ),
      ),
    );
  }
}
