import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:intl/intl.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:get/get.dart';

import '../utils/NotificationService.dart';
import 'AddMedicationScreen.dart';
import 'BulletinBoardScreen.dart';
import 'HealthScreen.dart';
import 'HomeScreen.dart';
import 'ChatScreen.dart';
import 'ProfileScreen.dart';
import '../Routes/AppRoutes.dart';

class MedicineScreen extends StatefulWidget {
  const MedicineScreen({super.key});

  @override
  _MedicineScreenState createState() => _MedicineScreenState();
}

class _MedicineScreenState extends State<MedicineScreen> {
  int _selectedIndex = 2;
  DateTime selectedDate = DateTime.now();
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _notificationService.initNotification();
    _scheduleNotifications();
  }

  Future<String> _fetchUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        return userDoc['name'] ?? 'Khách';
      }
    }
    return 'Khách';
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HealthScreen()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BulletinBoardScreen()),
        );
        break;
    }
  }

  Future<void> _scheduleNotifications() async {
    final medications = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('medications')
        .get();

    for (var med in medications.docs) {
      final data = med.data();
      final schedules = data['schedules'] as List<dynamic>?;
      if (schedules != null) {
        for (var schedule in schedules) {
          final time = schedule['time'] as String;
          final timeParts = time.split(':');
          final now = DateTime.now();
          final scheduledDate = DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(timeParts[0]),
            int.parse(timeParts[1]),
          );

          if (scheduledDate.isAfter(now)) {
            await _notificationService.showNotification(
              med.id.hashCode,
              'Nhắc nhở uống thuốc',
              'Đã đến giờ uống ${data['drugName']}',
              scheduledDate,
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thuốc của tôi"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: () {
              User? user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                Get.to(() => ChatScreen(userId: user.uid));
              } else {
                Get.snackbar('Lỗi', 'Vui lòng đăng nhập trước khi trò chuyện.');
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_sharp),
            onPressed: () {
              // Implement add medication functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Implement notification functionality
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            DateSlider(
              onDateSelected: (date) {
                setState(() {
                  selectedDate = date;
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: Text(
                  'Hôm nay, ${DateFormat('d MMMM yyyy').format(selectedDate)}',
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
            Expanded(
              child: MedicationList(selectedDate: selectedDate),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EditMedicationsScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Chỉnh sửa hộp thuốc'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.reactCircle,
        backgroundColor: Colors.white,
        activeColor: Colors.pinkAccent,
        color: Colors.grey,
        items: const [
          TabItem(icon: Icons.home, title: 'Trang chủ'),
          TabItem(icon: Icons.favorite, title: 'Sức khoẻ'),
          TabItem(icon: Icons.medication, title: 'Thuốc'),
          TabItem(icon: Icons.forum, title: 'Bảng tin'),
        ],
        initialActiveIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          FutureBuilder<String>(
            future: _fetchUserName(),
            builder: (context, snapshot) {
              String userName = snapshot.data ?? 'Khách';
              User? user = FirebaseAuth.instance.currentUser;
              return UserAccountsDrawerHeader(
                accountName: Text(userName),
                accountEmail: Text(user?.email ?? 'Không có email'),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : const AssetImage('assets/images/default_avatar.png')
                          as ImageProvider,
                ),
                decoration: const BoxDecoration(
                  color: Colors.teal,
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Hồ sơ"),
            onTap: () {
              User? user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                Get.to(() => ProfileScreen(userId: user.uid));
              } else {
                Get.snackbar('Lỗi', 'Vui lòng đăng nhập để xem hồ sơ.');
              }
            },
          ),
          // Add other ListTiles as in HealthScreen
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Get.offNamed(AppRoutes.SIGNINSCREEN);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return FutureBuilder<String>(
      future: _fetchUserName(),
      builder: (context, snapshot) {
        String userName = snapshot.data ?? 'Khách';
        String formattedDate =
            DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());
        String formattedTime = DateFormat('HH:mm').format(DateTime.now());

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Xin chào, $userName!",
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '$formattedDate, $formattedTime',
                style: const TextStyle(color: Colors.grey),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}

class EditMedicationsScreen extends StatelessWidget {
  const EditMedicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa hộp thuốc'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('medications')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Đã xảy ra lỗi'));
          }

          List<QueryDocumentSnapshot> medications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: medications.length,
            itemBuilder: (context, index) {
              final medication = medications[index];
              final data = medication.data() as Map<String, dynamic>;
              final name = data['drugName'] ?? 'Không có tên';
              final dosage = data['dosage'] ?? 'Không có liều lượng';
              final unit = data['unit'] ?? '';

              return ListTile(
                title: Text(name),
                subtitle: Text('$dosage $unit'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditMedicationScreen(medicationId: medication.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AddMedicationScreen()),
          );
        },
      ),
    );
  }
}

class EditMedicationScreen extends StatefulWidget {
  final String medicationId;

  const EditMedicationScreen({super.key, required this.medicationId});

  @override
  _EditMedicationScreenState createState() => _EditMedicationScreenState();
}

class _EditMedicationScreenState extends State<EditMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TextEditingController _unitController;
  List<Map<String, dynamic>> schedules = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _dosageController = TextEditingController();
    _unitController = TextEditingController();
    _loadMedicationData();
  }

  void _loadMedicationData() async {
    DocumentSnapshot medicationDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('medications')
        .doc(widget.medicationId)
        .get();

    if (medicationDoc.exists) {
      var data = medicationDoc.data() as Map<String, dynamic>;
      setState(() {
        _nameController.text = data['drugName'] ?? '';
        _dosageController.text = data['dosage'] ?? '';
        _unitController.text = data['unit'] ?? '';
        schedules = List<Map<String, dynamic>>.from(data['schedules'] ?? []);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa thuốc'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Tên thuốc'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tên thuốc';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _dosageController,
              decoration: const InputDecoration(labelText: 'Liều lượng'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập liều lượng';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _unitController,
              decoration: const InputDecoration(labelText: 'Đơn vị'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập đơn vị';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            const Text('Lịch uống thuốc:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...schedules.asMap().entries.map((entry) {
              int idx = entry.key;
              var schedule = entry.value;
              return ListTile(
                title: Text(
                    '${schedule['time']} - ${schedule['dosage']} ${schedule['unit']}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      schedules.removeAt(idx);
                    });
                  },
                ),
              );
            }),
            ElevatedButton(
              child: const Text('Thêm lịch uống thuốc'),
              onPressed: () {
                // Implement add schedule functionality
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Lưu thay đổi'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _saveMedication();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _saveMedication() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('medications')
        .doc(widget.medicationId)
        .update({
      'drugName': _nameController.text,
      'dosage': _dosageController.text,
      'unit': _unitController.text,
      'schedules': schedules,
    });

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _unitController.dispose();
    super.dispose();
  }
}

class DateSlider extends StatefulWidget {
  final Function(DateTime) onDateSelected;

  const DateSlider({super.key, required this.onDateSelected});

  @override
  _DateSliderState createState() => _DateSliderState();
}

class _DateSliderState extends State<DateSlider> {
  late PageController _pageController;
  late DateTime _selectedDate;
  final int _daysBeforeAfter = 15;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _pageController =
        PageController(initialPage: _daysBeforeAfter, viewportFraction: 0.2);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedDate =
                DateTime.now().add(Duration(days: index - _daysBeforeAfter));
            widget.onDateSelected(_selectedDate);
          });
        },
        itemBuilder: (context, index) {
          final date =
              DateTime.now().add(Duration(days: index - _daysBeforeAfter));
          final isSelected = date.day == _selectedDate.day &&
              date.month == _selectedDate.month &&
              date.year == _selectedDate.year;

          return GestureDetector(
            onTap: () {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(date),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class MedicationList extends StatelessWidget {
  final DateTime selectedDate;

  const MedicationList({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('medications')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Đã xảy ra lỗi'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        List<QueryDocumentSnapshot> medications = snapshot.data!.docs;

        if (medications.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  image: AssetImage('assets/images/empty_box.png'),
                  width: 120,
                  height: 120,
                ),
                SizedBox(height: 16),
                Text(
                  'Không có thuốc nào được lên lịch',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        Map<String, List<QueryDocumentSnapshot>> groupedMedications = {
          'Sáng': [],
          'Chiều': [],
          'Tối': [],
        };

        for (var med in medications) {
          String period = _getPeriod(
              med['schedules'] != null && med['schedules'].isNotEmpty
                  ? med['schedules'][0]['time']
                  : '12:00');
          groupedMedications[period]!.add(med);
        }

        return ListView.builder(
          itemCount: groupedMedications.length,
          itemBuilder: (context, index) {
            String period = groupedMedications.keys.elementAt(index);
            List<QueryDocumentSnapshot> meds = groupedMedications[period]!;

            if (meds.isEmpty) return const SizedBox.shrink();

            return Card(
              margin: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: _getPeriodIcon(period),
                    title: Text(
                      period.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle:
                        Text('Nhắc nhở tiếp theo: ${_getNextReminder(meds)}'),
                    trailing: ElevatedButton(
                      onPressed: () => _takeMedications(meds),
                      child: const Text('Uống tất cả'),
                    ),
                  ),
                  const Divider(),
                  ...meds.map((med) => MedicationItem(medication: med)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _getNextReminder(List<QueryDocumentSnapshot> medications) {
    DateTime now = DateTime.now();
    DateTime? nextReminder;
    for (var med in medications) {
      final schedules = med['schedules'] as List<dynamic>?;
      if (schedules != null) {
        for (var schedule in schedules) {
          final time = schedule['time'] as String;
          final timeParts = time.split(':');
          final scheduledDate = DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(timeParts[0]),
            int.parse(timeParts[1]),
          );
          if (scheduledDate.isAfter(now) &&
              (nextReminder == null || scheduledDate.isBefore(nextReminder))) {
            nextReminder = scheduledDate;
          }
        }
      }
    }
    return nextReminder != null
        ? DateFormat('HH:mm').format(nextReminder)
        : 'Không có';
  }

  String _getPeriod(String time) {
    int hour = int.parse(time.split(':')[0]);
    if (hour < 12) return 'Sáng';
    if (hour < 18) return 'Chiều';
    return 'Tối';
  }

  Icon _getPeriodIcon(String period) {
    switch (period) {
      case 'Sáng':
        return const Icon(Icons.wb_sunny, color: Colors.orange);
      case 'Chiều':
        return const Icon(Icons.wb_twighlight, color: Colors.amber);
      case 'Tối':
        return const Icon(Icons.nightlight_round, color: Colors.indigo);
      default:
        return const Icon(Icons.access_time);
    }
  }

  void _takeMedications(List<QueryDocumentSnapshot> medications) {
    for (var med in medications) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('medications')
          .doc(med.id)
          .update({'taken': true});
    }
  }
}

class MedicationItem extends StatelessWidget {
  final QueryDocumentSnapshot medication;

  const MedicationItem({super.key, required this.medication});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> data = medication.data() as Map<String, dynamic>;
    final String name = data['drugName'] ?? 'Không có tên';
    final String dosage = data['dosage'] ?? 'Không có liều lượng';
    final String unit = data['unit'] ?? '';
    final List<dynamic> schedules = data['schedules'] ?? [];
    final bool taken = data['taken'] ?? false;
    final int quantity = data['quantity'] ?? 0;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Icon(
          Icons.medication,
          color: taken ? Colors.green : Colors.grey,
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$dosage $unit'), // Hiển thị liều lượng và đơn vị
            Text(schedules
                .map((s) => s['time'])
                .join(', ')), // Hiển thị thời gian uống thuốc
            Text('Còn lại: $quantity'), // Hiển thị số thuốc còn lại
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            taken ? Icons.check_circle : Icons.circle_outlined,
            color: taken ? Colors.green : Colors.grey,
          ),
          onPressed: () => _toggleMedicationTaken(context),
        ),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(name),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Liều lượng: $dosage $unit'),
                  Text(
                      'Thời gian: ${schedules.map((s) => s['time']).join(', ')}'),
                  Text('Đã uống: ${taken ? 'Có' : 'Chưa'}'),
                  Text('Còn lại: $quantity'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Đóng'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _toggleMedicationTaken(BuildContext context) async {
    final bool currentTaken = medication['taken'] ?? false;
    final int currentQuantity = medication['quantity'] ?? 0;
    final List<dynamic> schedules = medication['schedules'] ?? [];

    if (schedules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Không có lịch uống thuốc nào được thiết lập')),
      );
      return;
    }

    // Lấy liều lượng từ lịch uống thuốc đầu tiên
    final int dosageToTake =
        int.tryParse(schedules[0]['dosage'].toString()) ?? 0;

    if (!currentTaken && currentQuantity < dosageToTake) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không đủ thuốc để uống')),
      );
      return;
    }

    final int newQuantity = currentTaken
        ? currentQuantity + dosageToTake
        : currentQuantity - dosageToTake;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('medications')
        .doc(medication.id)
        .update({
      'taken': !currentTaken,
      'quantity': newQuantity,
    });
  }
}
