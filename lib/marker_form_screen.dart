import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inicio/database_helper.dart';  // Asegúrate de importar la base de datos correctamente

class MarkerFormScreen extends StatefulWidget {
  final LatLng position;  // La posición del marcador
  const MarkerFormScreen({Key? key, required this.position}) : super(key: key);

  @override
  _MarkerFormScreenState createState() => _MarkerFormScreenState();
}

class _MarkerFormScreenState extends State<MarkerFormScreen> {
  final _formKey = GlobalKey<FormState>();  // Clave para el formulario
  String _title = ''; // Título del marcador
  String _description = ''; // Descripción del marcador

  // Función para agregar el marcador al mapa y guardarlo en la base de datos
  void _addMarker() async {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save(); // <-- Esta línea es esencial

    final markerId = MarkerId(widget.position.toString());

    final newMarker = Marker(
      markerId: markerId,
      position: widget.position,
      infoWindow: InfoWindow(
        title: _title.isEmpty ? 'Sin título' : _title,
        snippet: _description.isEmpty ? 'Sin descripción' : _description,
      ),
    );

    await DatabaseHelper.instance.insertMarker(_title, _description, widget.position.latitude, widget.position.longitude);

    Navigator.pop(context, newMarker);
  } else {
    print("Formulario no válido");
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Marcador'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,  // Asocia la clave del formulario
          child: Column(
            children: <Widget>[
              // Campo para el título del marcador
              TextFormField(
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un título';  // Validación si el título está vacío
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value!;  // Guardar el título
                },
              ),
              // Campo para la descripción del marcador
              TextFormField(
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una descripción';  // Validación si la descripción está vacía
                  }
                  return null;
                },
                onSaved: (value) {
                  _description = value!;  // Guardar la descripción
                },
              ),
              // Botón para guardar el marcador
              ElevatedButton(
                onPressed: _addMarker,  // Al presionar el botón, guardar el marcador
                child: const Text('Guardar Marcador'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

