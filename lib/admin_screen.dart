import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'login_screen.dart';
import 'navigation_helper.dart';

class AdminScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  AdminScreen(this.firstName, this.lastName);

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<Map<String, dynamic>> users = [];

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  void loadUsers() async {
    final db = await DatabaseHelper().database;
    final data = await db.query('users');
    setState(() {
      users = data;
    });
  }

  void deleteUser(int id) async {
    final db = await DatabaseHelper().database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
    loadUsers(); // Recargar la lista de usuarios
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Panel de Administrador")),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(users[index]['first_name'] + " " + users[index]['last_name']),
            subtitle: Text(users[index]['email']),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => deleteUser(users[index]['id']),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        child: Icon(Icons.logout),
        onPressed: () {
          navigateWithFade(context, LoginScreen());
        },
      ),
    );
  }
}
