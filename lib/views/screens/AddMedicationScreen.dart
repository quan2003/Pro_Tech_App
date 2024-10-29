import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import 'DrugDetailScreen.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  _AddMedicationScreenState createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  List<dynamic> _drugs = [];
  bool _isLoading = false;
  Timer? _debounce;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // Hàm gọi API để lấy dữ liệu thuốc từ OpenFDA
  Future<void> fetchDrugData(String query) async {
    if (query.isEmpty) {
      setState(() {
        _drugs = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    const String apiKey = 'BpYNJ7WCkX21JzJDWJFTG37egHyahIfqWOdNMs4v';
    final String url =
        'https://api.fda.gov/drug/label.json?api_key=$apiKey&search=(openfda.brand_name:$query*+openfda.manufacturer_name:$query*)&limit=20';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _drugs = data['results'].where((drug) {
            final hasBrandName = drug['openfda']['brand_name'] != null &&
                drug['openfda']['brand_name'].isNotEmpty;
            final hasManufacturer =
                drug['openfda']['manufacturer_name'] != null &&
                    drug['openfda']['manufacturer_name'].isNotEmpty;
            return hasBrandName || hasManufacturer;
          }).toList();

          // Sắp xếp kết quả theo thứ tự ưu tiên: tên thuốc bắt đầu bằng query, sau đó đến nhà sản xuất
          _drugs.sort((a, b) {
            final aName = a['openfda']['brand_name']?.first ?? '';
            final bName = b['openfda']['brand_name']?.first ?? '';
            // final aManufacturer = a['openfda']['manufacturer_name']?.first ?? '';
            // final bManufacturer = b['openfda']['manufacturer_name']?.first ?? '';

            if (aName.toLowerCase().startsWith(query.toLowerCase()) &&
                !bName.toLowerCase().startsWith(query.toLowerCase())) {
              return -1;
            } else if (!aName.toLowerCase().startsWith(query.toLowerCase()) &&
                bName.toLowerCase().startsWith(query.toLowerCase())) {
              return 1;
            } else {
              return aName.compareTo(bName);
            }
          });

          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load drug data');
      }
    } catch (error) {
      print('Error: $error');
      setState(() {
        _isLoading = false;
        _drugs = [];
      });
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchDrugData(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: KeyboardVisibilityBuilder(
          builder: (context, isKeyboardVisible) {
            return Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            const SizedBox(height: 50),
                            Center(
                              child: Column(
                                children: [
                                  Image.asset('assets/images/pill_icon.png',
                                      height: 100),
                                  const SizedBox(height: 20),
                                  const Text(
                                    'Thêm thuốc',
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24.0),
                              child: TextField(
                                controller: _searchController,
                                onChanged: _onSearchChanged,
                                decoration: InputDecoration(
                                  hintText: 'Nhập tên thuốc hoặc nhà sản xuất',
                                  prefixIcon: const Icon(Icons.search,
                                      color: Colors.grey),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                      _isLoading
                          ? const SliverFillRemaining(
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : _drugs.isNotEmpty
                              ? SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final drug = _drugs[index];
                                      final brandName =
                                          drug['openfda']['brand_name']?.first;
                                      final manufacturerName = drug['openfda']
                                              ['manufacturer_name']
                                          ?.first;
                                      return ListTile(
                                        title: Text(
                                          brandName ??
                                              manufacturerName ??
                                              'Không có thông tin',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: brandName != null &&
                                                manufacturerName != null
                                            ? Text(manufacturerName)
                                            : null,
                                        trailing:
                                            const Icon(Icons.chevron_right),
                                        onTap: () {
                                          // Xử lý khi nhấn vào thuốc
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DrugDetailScreen(
                                                drugName:
                                                    brandName ?? 'Unknown',
                                                manufacturerName:
                                                    manufacturerName ??
                                                        'Unknown',
                                                dosage: '',
                                                form: '',
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    childCount: _drugs.length,
                                  ),
                                )
                              : SliverFillRemaining(
                                  child: Center(
                                    child: Text(
                                      _searchController.text.isEmpty
                                          ? 'Nhập tên thuốc hoặc nhà sản xuất để tìm kiếm'
                                          : 'Không có kết quả tìm kiếm',
                                    ),
                                  ),
                                ),
                    ],
                  ),
                ),
                if (!isKeyboardVisible)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Hơn 4 triệu loại thuốc được cung cấp bởi',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Image.asset('assets/images/whodrugs_logo.png',
                            height: 50),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
