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
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  void showAlert(String mensaje, {Color color = Colors.redAccent}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
      ),
    );
  }

  void register() async {
    String firstName = firstNameController.text.trim();
    String lastName = lastNameController.text.trim();
    String username = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      showAlert("Completa todos los campos.");
      return;
    }

    if (password != confirmPassword) {
      showAlert("Las contraseñas no coinciden.");
      return;
    }

    // Aquí puedes validar formato de correo o fuerza de la contraseña si deseas.

    await DatabaseHelper().registerUser(firstName, lastName, username, password);
    showAlert("Registro exitoso. Inicia sesión.", color: Colors.green);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView( // Evita overflow con teclado
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 60),
            Icon(Icons.person_add, size: 100, color: Colors.redAccent),
            SizedBox(height: 20),
            Text("Registro", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 20),
            TextField(controller: firstNameController, decoration: InputDecoration(labelText: "Nombre")),
            SizedBox(height: 10),
            TextField(controller: lastNameController, decoration: InputDecoration(labelText: "Apellido")),
            SizedBox(height: 10),
            TextField(controller: emailController, decoration: InputDecoration(labelText: "Correo Electrónico")),
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
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
