import 'package:flutter/material.dart';

import 'BulletinBoardManagementPage.dart';
import 'DeviceManagementPage.dart';
import 'UserManagementPage.dart'; // Thêm import trang DeviceManagementPage

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AdminHomePage(),
    );
  }
}

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Row(
        children: [
          _buildSidebar(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Dashboard',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _buildDashboardGrid(),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildMonthlyRegisteredUsersChart()),
                      const SizedBox(width: 20),
                      Expanded(child: _buildMonthlyEarningWidget()),
                    ],
                  ),
                ],
              ),
            ),
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
          const Text('Pro - Tech'),
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
        const CircleAvatar(
            backgroundImage: AssetImage('assets/images/default_avatar.png')),
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
          _buildSidebarItem('Dashboard', Icons.dashboard, isSelected: true),
          _buildSidebarItem('User Management', Icons.people, onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const UserManagementPage()));
          }),
          _buildSidebarItem('Health Management', Icons.favorite, onTap: () {
            // Navigator.push(context, MaterialPageRoute(builder: (context) => HealthManagementPage()));
          }),
          _buildSidebarItem('Device Management', Icons.devices, onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const DeviceManagementPage())); // Thêm điều hướng đến trang DeviceManagementPage
          }),
          _buildSidebarItem('Bulletin Board Management', Icons.forum,
              onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const BulletinBoardManagementPage()));
          }),
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

  Widget _buildSidebarItem(String title, IconData icon,
      {bool isSelected = false, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      selected: isSelected,
      selectedTileColor: Colors.tealAccent.withOpacity(0.1),
      onTap: onTap,
    );
  }

  Widget _buildDashboardGrid() {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _buildDashboardCard('Department', '8', Icons.settings, Colors.blue),
        _buildDashboardCard('Doctor', '14', Icons.person, Colors.green),
        _buildDashboardCard('Patient', '1', Icons.people, Colors.blue),
        _buildDashboardCard(
            'Patient Appointment', '3', Icons.event, Colors.orange),
        _buildDashboardCard(
            'Patient Case Studies', '0', Icons.folder, Colors.orange),
        _buildDashboardCard('Invoice', '0', Icons.receipt, Colors.blue),
        _buildDashboardCard(
            'Prescription', '0', Icons.description, Colors.green),
        _buildDashboardCard('Payment', '0', Icons.payment, Colors.blue),
      ],
    );
  }

  Widget _buildDashboardCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis, // Handle long text
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyRegisteredUsersChart() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Monthly Registered Users',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: Placeholder(), // Thay thế bằng biểu đồ của bạn
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyEarningWidget() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Monthly Earning',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  onPressed: () {},
                  child: const Text('Weekly'),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  child: const Text('Monthly'),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('This Week', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 10),
            const Row(
              children: [
                Text('\$29.5',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(width: 10),
                Text('-31.08% From Previous week',
                    style: TextStyle(color: Colors.red)),
              ],
            ),
            const SizedBox(height: 20),
            const CircleAvatar(
                backgroundImage:
                    AssetImage('assets/images/default_avatar.png')),
          ],
        ),
      ),
    );
  }
}
