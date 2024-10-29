import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Row(
        children: [
          _buildSidebar(context),
          Expanded(
            child: _buildUserTable(),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          Image.asset('assets/images/AppLogo.png', height: 30),
          const SizedBox(width: 10),
          const Text('User Management'),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.language), onPressed: () {}),
        TextButton(child: const Text('Go To Website'), onPressed: () {}),
        IconButton(icon: const Icon(Icons.chat), onPressed: () {}),
        PopupMenuButton(
          child: const Row(
            children: [
              Text('Pro - Tech'),
              Icon(Icons.arrow_drop_down),
            ],
          ),
          itemBuilder: (context) => [
            const PopupMenuItem(child: Text('Settings')),
            const PopupMenuItem(child: Text('Help')),
          ],
        ),
        const CircleAvatar(backgroundImage: AssetImage('assets/images/default_avatar.png')),
        PopupMenuButton(
          child: const Row(
            children: [
              Text('Mr Patient'),
              Icon(Icons.arrow_drop_down),
            ],
          ),
          itemBuilder: (context) => [
            const PopupMenuItem(child: Text('Profile')),
            const PopupMenuItem(child: Text('Logout')),
          ],
        ),
        PopupMenuButton(
          child: const Row(
            children: [
              Text('EN'),
              Icon(Icons.arrow_drop_down),
            ],
          ),
          itemBuilder: (context) => [
            const PopupMenuItem(child: Text('English')),
            const PopupMenuItem(child: Text('Español')),
          ],
        ),
      ],
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 200,
      color: Colors.teal,
      child: ListView(
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text('Super Admin'),
            accountEmail: null,
            currentAccountPicture: CircleAvatar(
              backgroundImage: AssetImage('assets/images/default_avatar.png'),
            ),
            decoration: BoxDecoration(color: Colors.teal),
          ),
          _buildSidebarItem('Dashboard', Icons.dashboard, onTap: () {
            Navigator.pop(context);
          }),
          _buildSidebarItem('User Management', Icons.people, isSelected: true),
          _buildSidebarItem('Health Management', Icons.favorite),
          _buildSidebarItem('Device Management', Icons.devices),
          _buildSidebarItem('Doctor', Icons.person),
          _buildSidebarItem('Patient', Icons.people),
          _buildSidebarItem('Doctor Schedule', Icons.calendar_today),
          _buildSidebarItem('Patient Appointment', Icons.event),
          _buildSidebarItem('Patient Case Studies', Icons.folder),
          _buildSidebarItem('Prescription', Icons.description),
          _buildSidebarItem('Login Page', Icons.login),
          _buildSidebarItem('Log Out', Icons.exit_to_app),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(String title, IconData icon, {bool isSelected = false, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      selected: isSelected,
      selectedTileColor: Colors.tealAccent.withOpacity(0.1),
      onTap: onTap,
    );
  }

  Widget _buildUserTable() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Đã xảy ra lỗi'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add User'),
                onPressed: () {
                  _showAddUserDialog(context);
                },
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('STT')),
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Gender')),
                    DataColumn(label: Text('Year Of Birth')),
                    DataColumn(label: Text('Phone')),
                    DataColumn(label: Text('Weight')),
                    DataColumn(label: Text('Unit')),
                    DataColumn(label: Text('Height')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: List<DataRow>.generate(
                    snapshot.data!.docs.length,
                    (index) {
                      DocumentSnapshot document = snapshot.data!.docs[index];
                      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                      return DataRow(
                        cells: [
                          DataCell(Text('${index + 1}')),
                          DataCell(Text(data['name'] ?? '')),
                          DataCell(Text(data['gender'] ?? '')),
                          DataCell(Text(data['yearOfBirth']?.toString() ?? '')),
                          DataCell(Text(data['phone']?.toString() ?? '')),
                          DataCell(Text(data['weight']?.toString() ?? '')),
                          DataCell(Text(data['unit'] ?? '')),
                          DataCell(Text(data['height']?.toString() ?? '')),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  // Implement edit functionality
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  // Implement delete functionality
                                },
                              ),
                            ],
                          )),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New User'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(hintText: "Enter name"),
                ),
                TextField(
                  decoration: InputDecoration(hintText: "Enter email"),
                ),
                TextField(
                  decoration: InputDecoration(hintText: "Enter role"),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                // Implement add user logic here
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  
}
