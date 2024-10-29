import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'FrequencySelectorWidget.dart';

// ignore: must_be_immutable
class DrugDetailScreen extends StatefulWidget {
  final String drugName;
  final String manufacturerName;
  String form;

  DrugDetailScreen({
    super.key,
    required this.drugName,
    required this.manufacturerName,
    required this.form,
    required String dosage,
  });

  @override
  // ignore: library_private_types_in_public_api
  _DrugDetailScreenState createState() => _DrugDetailScreenState();
}

class _DrugDetailScreenState extends State<DrugDetailScreen> {
  String dosage = '';
  bool isUnitSelected = false;
  String _selectedUnit = 'mg';
  int _quantity = 30;
  String _treatmentCondition = '';
  String _frequency = '';
  Map<String, dynamic> _frequencyDetails = {};
  List<Map<String, dynamic>> schedules = [
    {'time': '08:00', 'dosage': '1 viên'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Thêm thuốc',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionHeader('Chi tiết'),
              _buildDetailCard(
                  Icons.local_hospital, 'Tên', widget.drugName, null),
              _buildDetailCard(Icons.business, 'Nhà sản xuất',
                  widget.manufacturerName, null),
              _buildDetailCard(
                Icons.opacity,
                'Hàm lượng',
                dosage.isNotEmpty ? '$dosage $_selectedUnit' : '-',
                null,
                onTap: () => _showDosageForm(context),
              ),
              _buildDetailCard(
                Icons.bubble_chart,
                'Dạng',
                widget.form,
                const Icon(Icons.chevron_right_sharp),
                onTap: () => _showMedicationFormSelector(context),
              ),
              _buildDetailCard(
                Icons.local_hospital,
                'Điều trị',
                _treatmentCondition.isNotEmpty ? _treatmentCondition : 'Chọn',
                const Icon(Icons.chevron_right_sharp),
                onTap: () => _showTreatmentConditionSelector(context),
              ),
              _buildDetailCard(
                Icons.inventory,
                'Trong hộp',
                '$_quantity viên',
                const Icon(Icons.chevron_right_sharp),
                onTap: () => _showQuantitySelector(context),
              ),
              const SizedBox(height: 20),
              _buildSectionHeader('Nhắc nhở'),
              _buildDetailCard(
                Icons.repeat,
                'Tần suất',
                _getFrequencyDisplayText(),
                const Icon(Icons.chevron_right_sharp),
                onTap: () => _showFrequencySelector(context),
              ),
              _buildDetailCard(
                Icons.access_time,
                'Đặt lịch',
                '${schedules.length} lịch',
                const Icon(Icons.chevron_right_sharp),
                onTap: () => _showScheduleManager(context),
              ),
              const SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                  onPressed: (dosage.isNotEmpty && isUnitSelected)
                      ? () async {
                          await _saveMedicationToFirestore();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getButtonColor(),
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 80),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Lưu',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveMedicationToFirestore() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      CollectionReference userMedications = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('medications');

      await userMedications.add({
        'drugName': widget.drugName,
        'manufacturerName': widget.manufacturerName,
        'form': widget.form,
        'dosage': dosage,
        'unit': _selectedUnit, // Explicitly saving the unit
        'quantity': _quantity,
        'treatmentCondition': _treatmentCondition,
        'frequency': _frequency,
        'frequencyDetails': _frequencyDetails,
        'schedules': schedules,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thông tin đã được lưu thành công')),
      );

      Navigator.of(context).pop();
    } catch (e) {
      print('Error saving medication: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Có lỗi xảy ra khi lưu thông tin')),
      );
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }

  Widget _buildDetailCard(
      IconData icon, String label, String value, Widget? trailing,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.pinkAccent),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                '$label: $value',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  // Function to show dosage input form
  void _showDosageForm(BuildContext context) {
    TextEditingController dosageController =
        TextEditingController(text: dosage);

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Wrap(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Thêm hàm lượng',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: dosageController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Hàm lượng',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                          ),
                          onChanged: (value) {
                            setModalState(() {
                              dosage = value;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        const Text('Đơn vị', style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          children:
                              _buildUnitButtons(_selectedUnit, (String unit) {
                            setModalState(() {
                              _selectedUnit = unit;
                              isUnitSelected = true;
                            });
                          }),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: (dosage.isNotEmpty && isUnitSelected)
                                ? () {
                                    setState(() {
                                      dosage = dosage;
                                      // Update the main screen's state
                                    });
                                    Navigator.pop(context);
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _getButtonColor(),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16.0, horizontal: 80),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text('Lưu',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Function to show quantity selector
  void _showQuantitySelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.4,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Trong hộp',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text('Bạn hiện còn bao nhiêu viên thuốc?',
                  style: TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              Expanded(
                child: CupertinoPickerWidget(
                  initialValue: _quantity,
                  onValueChanged: (newValue) {
                    setState(() {
                      _quantity = newValue;
                    });
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Tiếp theo',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to show medication form selector
  void _showMedicationFormSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: MedicationFormSelector(
            onSelect: (selectedForm) {
              setState(() {
                widget.form = selectedForm;
              });
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  // Function to show treatment condition selector
  void _showTreatmentConditionSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: TreatmentConditionSelector(
            onSelect: (selectedCondition) {
              setState(() {
                _treatmentCondition = selectedCondition;
              });
            },
          ),
        );
      },
    );
  }

  // Function to show frequency selector
  void _showFrequencySelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return FrequencySelectorWidget(
          initialFrequency: _frequency,
          initialFrequencyDetails: _frequencyDetails,
          onSelect: (selectedFrequency, additionalData) {
            setState(() {
              _frequency = selectedFrequency;
              _frequencyDetails = additionalData;
            });
          },
        );
      },
    );
  }

  // Function to show schedule manager
  void _showScheduleManager(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return ScheduleManagerWidget(
          initialSchedules: schedules,
          onSave: (updatedSchedules) {
            setState(() {
              schedules = updatedSchedules;
            });
          },
        );
      },
    );
  }

  // Function to display frequency text
  String _getFrequencyDisplayText() {
    switch (_frequency) {
      case 'Cách ngày':
        int days = _frequencyDetails['Cách ngày'] ?? 2;
        return 'Mỗi $days ngày';
      case 'Mỗi ngày':
        return 'Mỗi ngày';
      case 'Ngày cụ thể trong tuần':
        List<String> days = List<String>.from(
            _frequencyDetails['Ngày cụ thể trong tuần'] ?? []);
        return days.isEmpty ? 'Chọn ngày' : days.join(', ');
      case 'Chỉ khi cần':
        return 'Chỉ khi cần';
      default:
        return 'Chọn tần suất';
    }
  }

  // Function to get button color based on input validation
  Color _getButtonColor() {
    if (dosage.isEmpty) {
      return Colors.grey; // Color when dosage is not entered
    } else if (dosage.isNotEmpty && !isUnitSelected) {
      return Colors.black; // Color when dosage is entered but unit not selected
    } else {
      return Colors.black; // Keep color black after selecting unit
    }
  }

  // Function to build unit buttons
  List<Widget> _buildUnitButtons(
      String selectedUnit, Function(String) onSelected) {
    final units = ['mL', 'IU', '%', 'mcg', 'mg', 'g'];
    return units.map((unit) {
      return ChoiceChip(
        label: Text(unit),
        selected: selectedUnit == unit,
        onSelected: (bool selected) {
          onSelected(unit);
        },
        selectedColor: Colors.purple[100],
        labelStyle: TextStyle(
          color: selectedUnit == unit ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.grey[300],
      );
    }).toList();
  }
}

// CupertinoPickerWidget for selecting quantity
class CupertinoPickerWidget extends StatelessWidget {
  final int initialValue;
  final ValueChanged<int> onValueChanged;

  const CupertinoPickerWidget({
    super.key,
    required this.initialValue,
    required this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPicker(
      itemExtent: 40,
      scrollController:
          FixedExtentScrollController(initialItem: initialValue - 1),
      onSelectedItemChanged: (int index) {
        onValueChanged(index + 1);
      },
      children: List<Widget>.generate(100, (int index) {
        return Center(
          child: Text(
            '${index + 1}',
            style: const TextStyle(fontSize: 20),
          ),
        );
      }),
    );
  }
}

// MedicationFormSelector for selecting medication forms
class MedicationFormSelector extends StatelessWidget {
  final Function(String) onSelect;

  const MedicationFormSelector({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Thay đổi dạng thuốc',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              children: [
                const SizedBox(height: 20),
                const Text('Dạng thuốc phổ biến',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _buildMedicationFormItem(
                    'Viên', 'assets/icons/pill.png', onSelect),
                _buildMedicationFormItem(
                    'Viên nhộng', 'assets/icons/capsule.png', onSelect),
                _buildMedicationFormItem(
                    'Mũi', 'assets/icons/injection.png', onSelect),
                const SizedBox(height: 20),
                const Text('Khác',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _buildMedicationFormItem(
                    'Ống', 'assets/icons/liquid.png', onSelect),
                _buildMedicationFormItem(
                    'Giọt', 'assets/icons/drop.png', onSelect),
                _buildMedicationFormItem(
                    'Xịt', 'assets/icons/cream.png', onSelect),
                _buildMedicationFormItem(
                    'Miếng', 'assets/icons/personal.png', onSelect),
                _buildMedicationFormItem(
                    'Lọ', 'assets/icons/jar.png', onSelect),
                _buildMedicationFormItem(
                    'Khác', 'assets/icons/other.png', onSelect),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Tiếp theo',
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  // Function to build medication form items
  Widget _buildMedicationFormItem(
      String name, String iconPath, Function(String) onSelect) {
    return GestureDetector(
      onTap: () => onSelect(name),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Image.asset(iconPath, width: 24, height: 24),
            ),
            const SizedBox(width: 16),
            Text(name, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

// TreatmentConditionSelector for selecting treatment conditions
class TreatmentConditionSelector extends StatefulWidget {
  final Function(String) onSelect;

  const TreatmentConditionSelector({super.key, required this.onSelect});

  @override
  _TreatmentConditionSelectorState createState() =>
      _TreatmentConditionSelectorState();
}

class _TreatmentConditionSelectorState
    extends State<TreatmentConditionSelector> {
  String? selectedCondition;
  TextEditingController customConditionController = TextEditingController();

  final List<Map<String, dynamic>> conditions = [
    {
      'name': 'Cao huyết áp',
      'icon': 'assets/icons/blood_pressure.png',
      'color': Colors.red
    },
    {
      'name': 'Tiểu đường',
      'icon': 'assets/icons/diabetes.png',
      'color': Colors.blue
    },
    {
      'name': 'Mỡ máu cao',
      'icon': 'assets/icons/cholesterol.png',
      'color': Colors.yellow
    },
    {
      'name': 'Đau thắt ngực',
      'icon': 'assets/icons/heart_pain.png',
      'color': Colors.red
    },
    {'name': 'Khác', 'icon': 'assets/icons/other.png', 'color': Colors.grey},
  ];

  @override
  Widget build(BuildContext context) {
    // Get the height of the keyboard if it is displayed
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Điều trị cho',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: conditions.length,
                itemBuilder: (context, index) {
                  final condition = conditions[index];
                  return _buildConditionItem(
                    condition['name'],
                    condition['icon'],
                    condition['color'],
                    () {
                      setState(() {
                        selectedCondition = condition['name'];
                      });
                      if (condition['name'] != 'Khác') {
                        widget.onSelect(condition['name']);
                        Navigator.pop(context);
                      }
                    },
                  );
                },
              ),
            ),
            if (selectedCondition == 'Khác')
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: customConditionController,
                  decoration: InputDecoration(
                    hintText: 'Điều kiện sức khỏe. Ví dụ: Ho',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (selectedCondition == 'Khác') {
                    if (customConditionController.text.isNotEmpty) {
                      widget
                          .onSelect('Khác: ${customConditionController.text}');
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Vui lòng nhập điều kiện sức khỏe')),
                      );
                    }
                  } else if (selectedCondition != null) {
                    widget.onSelect(selectedCondition!);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Lưu',
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to build condition items
  Widget _buildConditionItem(
      String name, String iconPath, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Image.asset(iconPath, width: 24, height: 24),
            ),
            const SizedBox(width: 16),
            Text(name, style: const TextStyle(fontSize: 16)),
            const Spacer(),
            if (selectedCondition == name)
              const Icon(Icons.check, color: Colors.pink),
          ],
        ),
      ),
    );
  }
}

// ScheduleManagerWidget for managing schedules
class ScheduleManagerWidget extends StatefulWidget {
  final List<Map<String, dynamic>> initialSchedules;
  final Function(List<Map<String, dynamic>>) onSave;

  const ScheduleManagerWidget({
    super.key,
    required this.initialSchedules,
    required this.onSave,
  });

  @override
  _ScheduleManagerWidgetState createState() => _ScheduleManagerWidgetState();
}

class _ScheduleManagerWidgetState extends State<ScheduleManagerWidget> {
  late List<Map<String, dynamic>> schedules;

  @override
  void initState() {
    super.initState();
    schedules = List.from(widget.initialSchedules);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Đặt lịch',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: schedules.length,
              itemBuilder: (context, index) {
                return _buildScheduleItem(schedules[index], index);
              },
            ),
          ),
          _buildAddScheduleButton(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onSave(schedules);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Lưu',
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  // Function to build individual schedule items
  Widget _buildScheduleItem(Map<String, dynamic> schedule, int index) {
    return GestureDetector(
      onTap: () => _showEditScheduleDialog(index),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(
              schedule['time'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 16),
            Text(
              'Uống ${schedule['dosage']}',
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteSchedule(index),
            ),
          ],
        ),
      ),
    );
  }

  // Function to build the button for adding a new schedule
  Widget _buildAddScheduleButton() {
    return GestureDetector(
      onTap: _showAddScheduleDialog,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Colors.blue),
            SizedBox(width: 8),
            Text('Thêm lịch cử thuốc',
                style: TextStyle(color: Colors.blue, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  // Function to show dialog for editing a schedule
  void _showEditScheduleDialog(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return ScheduleEditDialog(
          initialTime: schedules[index]['time'],
          initialDosage: schedules[index]['dosage'],
          onSave: (time, dosage) {
            setState(() {
              schedules[index] = {'time': time, 'dosage': dosage};
            });
          },
        );
      },
    );
  }

  // Function to show dialog for adding a new schedule
  void _showAddScheduleDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return ScheduleEditDialog(
          onSave: (time, dosage) {
            setState(() {
              schedules.add({'time': time, 'dosage': dosage});
            });
          },
        );
      },
    );
  }

  // Function to delete a schedule
  void _deleteSchedule(int index) {
    setState(() {
      schedules.removeAt(index);
    });
  }
}

// ScheduleEditDialog for editing or adding schedules
class ScheduleEditDialog extends StatefulWidget {
  final String? initialTime;
  final String? initialDosage;
  final Function(String, String) onSave;

  const ScheduleEditDialog({
    super.key,
    this.initialTime,
    this.initialDosage,
    required this.onSave,
  });

  @override
  _ScheduleEditDialogState createState() => _ScheduleEditDialogState();
}

class _ScheduleEditDialogState extends State<ScheduleEditDialog> {
  late String _time;
  late String _dosage;

  @override
  void initState() {
    super.initState();
    _time = widget.initialTime ?? '08:00';
    _dosage = widget.initialDosage ?? '1';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 16,
        left: 16,
        right: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.initialTime != null ? 'Sửa lịch' : 'Thêm lịch',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Thời gian', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: TextEditingController(text: _time),
                      decoration: InputDecoration(
                        hintText: 'Ví dụ: 08:00',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onChanged: (value) {
                        _time = value;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Hàm lượng', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: TextEditingController(text: _dosage),
                      decoration: InputDecoration(
                        hintText: 'Ví dụ: 1 viên',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onChanged: (value) {
                        _dosage = value;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onSave(_time, _dosage);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Lưu',
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
