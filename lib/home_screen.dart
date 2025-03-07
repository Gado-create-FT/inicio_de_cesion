import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'navigation_helper.dart';

class HomeScreen extends StatelessWidget {
  final String firstName;
  final String lastName;
  HomeScreen(this.firstName, this.lastName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity, // Asegura que el fondo cubra toda la pantalla
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8B0000), Color(0xFF300000)], // Degradado rojo sangre
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center( // Esto centra toda la columna
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
            ],
          ),
        ),
      ),
    );
  }
}
