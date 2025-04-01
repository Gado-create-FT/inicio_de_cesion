import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'marker_form_screen.dart'; // Asegúrate de importar correctamente el formulario

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final LatLng _initialPosition = LatLng(20.4217, -99.2118); // Coordenadas de Ixmiquilpan
  Set<Marker> _markers = {}; // Conjunto de marcadores

  // Función que se llama cuando el mapa ha sido creado
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller; // Inicializar el controlador del mapa
  }

  // Función que se llama cuando el usuario mantiene presionado un punto en el mapa
  void _onLongPress(LatLng position) {
    // Navegar a la pantalla para agregar detalles del marcador
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MarkerFormScreen(position: position),
      ),
    ).then((newMarker) {
      if (newMarker != null) {
        setState(() {
          _markers.add(newMarker); // Agregar el nuevo marcador al conjunto
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa'),
        backgroundColor: Colors.red[700],
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _initialPosition,
          zoom: 10.0,
        ),
        markers: _markers, // Asociar los marcadores al mapa
        onLongPress: _onLongPress, // Detecta el presionado largo del mapa
      ),
    );
  }
}
