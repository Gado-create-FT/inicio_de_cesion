import 'package:flutter/material.dart';
import 'database_helper.dart';

class EditUserScreen extends StatefulWidget {
  final String email; // Se usará para identificar al usuario

  EditUserScreen(this.email);

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final dbHelper = DatabaseHelper();
    final user = await dbHelper.getUserByEmail(widget.email);
    if (user != null) {
      setState(() {
        _firstNameController.text = user['first_name'];
        _lastNameController.text = user['last_name'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Editar Usuario"),
        backgroundColor: Color(0xFF8B0000),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: "Nombre"),
                validator: (value) => value!.isEmpty ? "Ingrese su nombre" : null,
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: "Apellido"),
                validator: (value) => value!.isEmpty ? "Ingrese su apellido" : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: "Nueva Contraseña"),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateUser,
                child: Text("Actualizar"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateUser() async {
    if (_formKey.currentState!.validate()) {
      final dbHelper = DatabaseHelper();
      await dbHelper.updateUser(widget.email, _firstNameController.text, _lastNameController.text, _passwordController.text);
      Navigator.pop(context);
    }
  }
}
