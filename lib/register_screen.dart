import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  void register() async {
    String firstName = firstNameController.text.trim();
    String lastName = lastNameController.text.trim();
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (firstName.isNotEmpty && lastName.isNotEmpty && username.isNotEmpty && password.isNotEmpty) {
      if (password == confirmPassword) {
        await DatabaseHelper().registerUser(firstName, lastName, username, password);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Registro exitoso. Inicia sesión.")));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Las contraseñas no coinciden.")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Completa todos los campos.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_add, size: 100, color: Colors.redAccent),
            SizedBox(height: 20),
            Text("Registro", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 20),
            TextField(controller: firstNameController, decoration: InputDecoration(labelText: "Nombre")),
            SizedBox(height: 10),
            TextField(controller: lastNameController, decoration: InputDecoration(labelText: "Apellido")),
            SizedBox(height: 10),
            TextField(controller: usernameController, decoration: InputDecoration(labelText: "Nombre de Usuario")),
            SizedBox(height: 10),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: "Contraseña"), obscureText: true),
            SizedBox(height: 10),
            TextField(controller: confirmPasswordController, decoration: InputDecoration(labelText: "Confirmar Contraseña"), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(onPressed: register, child: Text("Registrar")),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("¿Ya tienes cuenta? Inicia Sesión"),
            ),
          ],
        ),
      ),
    );
  }
}
