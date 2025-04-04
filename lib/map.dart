import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inicio/database_helper.dart';
import 'marker_form_screen.dart';

class MapScreen extends StatefulWidget {
  final String email;

  const MapScreen({Key? key, required this.email}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final LatLng _initialPosition = LatLng(20.4217, -99.2118);
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _loadUserMarkers();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onLongPress(LatLng position) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MarkerFormScreen(
          position: position,
          email: widget.email,
        ),
      ),
    ).then((newMarker) {
      if (newMarker != null) {
        _loadUserMarkers(); // Recargar marcadores
      }
    });
  }

  Future<void> _loadUserMarkers() async {
    final markersFromDB = await DatabaseHelper.instance.getMarkersByEmail(widget.email);

    setState(() {
      _markers = markersFromDB.map((data) {
        final markerId = MarkerId(data['id'].toString());
        return Marker(
          markerId: markerId,
          position: LatLng(data['latitude'], data['longitude']),
          infoWindow: InfoWindow(
            title: data['title'],
            snippet: data['description'],
          ),
          onTap: () {
            _showMarkerOptions(
              markerId: data['id'],
              title: data['title'],
              description: data['description'],
              lat: data['latitude'],
              lng: data['longitude'],
            );
          },
        );
      }).toSet();
    });
  }

  void _showMarkerOptions({
    required int markerId,
    required String title,
    required String description,
    required double lat,
    required double lng,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: Icon(Icons.edit),
            title: Text("Editar"),
            onTap: () async {
              Navigator.pop(context);
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MarkerFormScreen(
                    position: LatLng(lat, lng),
                    email: widget.email,
                    isEditing: true,
                    markerId: markerId,
                    initialTitle: title,
                    initialDescription: description,
                  ),
                ),
              );
              if (result != null) _loadUserMarkers();
            },
          ),
          ListTile(
            leading: Icon(Icons.delete),
            title: Text("Eliminar"),
            onTap: () async {
              await DatabaseHelper.instance.deleteMarker(markerId);
              Navigator.pop(context);
              _loadUserMarkers();
            },
          ),
        ],
      ),
    );
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
        markers: _markers,
        onLongPress: _onLongPress,
      ),
    );
  }
}
