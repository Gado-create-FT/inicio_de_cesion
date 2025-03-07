import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import 'wave_animation.dart';
import 'navigation_helper.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool _showAnimation = false;
  bool _isPressed = false;

  void login() async {
    setState(() {
      _isLoading = true;
    });

    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    if (username.isNotEmpty && password.isNotEmpty) {
      var user = await DatabaseHelper().loginUser(username, password);
      if (user != null) {
        setState(() {
          _showAnimation = true;
        });

        Future.delayed(Duration(seconds: 2), () {
          setState(() {
            _showAnimation = false;
            _isLoading = false;
          });
          navigateWithFade(context, HomeScreen(user['first_name'], user['last_name']));
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Usuario o contraseña incorrectos.")));
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Completa todos los campos.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock, size: 100, color: Colors.redAccent),
                SizedBox(height: 20),
                Text("Iniciar Sesión", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 20),
                TextField(controller: usernameController, decoration: InputDecoration(labelText: "Nombre de Usuario")),
                SizedBox(height: 10),
                TextField(controller: passwordController, decoration: InputDecoration(labelText: "Contraseña"), obscureText: true),
                SizedBox(height: 20),
                
                // Botón con loader y efecto de presión
                _isLoading
                    ? CircularProgressIndicator(color: Colors.redAccent)
                    : GestureDetector(
                        onTapDown: (_) => setState(() => _isPressed = true),
                        onTapUp: (_) {
                          setState(() => _isPressed = false);
                          login();
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 100),
                          transform: _isPressed ? (Matrix4.identity()..scale(0.95)) : Matrix4.identity(),
                          child: ElevatedButton(
                            onPressed: null,
                            child: Text("Iniciar Sesión"),
                          ),
                        ),
                      ),

                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    navigateWithFade(context, RegisterScreen());
                  },
                  child: Text("¿No tienes cuenta? Regístrate"),
                ),
              ],
            ),
          ),
        ),
        if (_showAnimation) WaveAnimation(),
      ],
    );
  }
}
