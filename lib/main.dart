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
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyLarge: TextStyle(fontSize: 18, color: Colors.white),
        ),
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
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _estadoGps == 'Ubicación Real'
                    ? Icons.check_circle_outline
                    : Icons.warning_amber_outlined,
                color: _estadoGps == 'Ubicación Real' ? Colors.green : Colors.red,
                size: 100,
              ),
              SizedBox(height: 20),
              Text(
                _estadoGps,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              SizedBox(height: 20),
              Text(
                'Presiona el botón para verificar...',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          verificarUbicacion();
        },
        label: Text('Reintentar'),
        icon: Icon(Icons.refresh),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
