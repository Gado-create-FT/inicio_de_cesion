import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'navigation_helper.dart';
import 'edit_user_screen.dart'; // Nueva pantalla para editar usuario
import 'map.dart'; // Importa el archivo map.dart que contiene el widget del mapa

class HomeScreen extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String email; // Se agrega email para referencia en edición

  HomeScreen(this.firstName, this.lastName, this.email);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8B0000), Color(0xFF300000)], // Degradado rojo sangre
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centrar los elementos
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.black.withOpacity(0.2),
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            SizedBox(height: 20),
            Text(
              "Bienvenido, $firstName $lastName!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                navigateWithFade(context, LoginScreen());
              },
              child: Text("Cerrar Sesión"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                navigateWithFade(context, EditUserScreen(email)); // Navega a la pantalla de edición
              },
              child: Text("Editar Usuario/Contraseña"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navegar a la pantalla con el mapa cuando se presiona el botón
                navigateWithFade(context, MapScreen());
              },
              child: Text("Ver Mapa"), // El texto del botón
            ),
          ],
        ),
      ),
    );
  }
}
