// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class AdminPostDetailPage extends StatefulWidget {
  final String postId;

  const AdminPostDetailPage({super.key, required this.postId});

  @override
  // ignore: library_private_types_in_public_api
  _AdminPostDetailPageState createState() => _AdminPostDetailPageState();
}

class _AdminPostDetailPageState extends State<AdminPostDetailPage> {
  final TextEditingController _markdownController = TextEditingController();
  bool _isPreview = false;
  // ignore: unused_field
  String? _currentDetailId;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadLatestDetail();
  }

  @override
  void dispose() {
    _markdownController.dispose();
    super.dispose();
  }

  void _togglePreview() {
    setState(() {
      _isPreview = !_isPreview;
    });
  }

  Future<void> _loadLatestDetail() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('posts_quiz')
          .doc(widget.postId)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null && data.containsKey('detail')) {
          var detail = data['detail'];
          // ignore: avoid_print
          print('Loaded detail type: ${detail.runtimeType}');
          // ignore: avoid_print
          print('Loaded detail value: $detail');

          setState(() {
            _markdownController.text = detail.toString();
            _currentDetailId = snapshot.id;
            _errorMessage = '';
          });
        } else {
          setState(() {
            _errorMessage = 'No detail field found in document';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Document does not exist';
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error loading latest detail: $e');
      setState(() {
        _errorMessage = 'Error loading latest detail: $e';
      });
    }
  }

  // ignore: unused_element
  String _convertDetailToString(dynamic detail) {
    if (detail is String) {
      return detail;
    } else if (detail is int) {
      return detail.toString();
    } else if (detail is Iterable) {
      return detail.join('\n');
    } else {
      return 'Unsupported detail format';
    }
  }

  Future<void> _savePostDetail() async {
    if (_markdownController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter some content';
      });
      return;
    }

    try {
      final data = {
        'detail': _markdownController.text,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('posts_quiz')
          .doc(widget.postId)
          .set(data, SetOptions(merge: true));

      setState(() {
        _errorMessage = '';
      });
      _showSuccessSnackBar('PostDetail saved successfully');
      await _loadLatestDetail();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error saving PostDetail: $e';
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin: Edit Post Detail'),
        actions: [
          IconButton(
            icon: Icon(_isPreview ? Icons.edit : Icons.preview),
            onPressed: _togglePreview,
            tooltip: _isPreview ? 'Edit' : 'Preview',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _savePostDetail,
            tooltip: 'Save',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_errorMessage,
                    style: const TextStyle(color: Colors.red)),
              ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 600) {
                    return _buildWideLayout();
                  } else {
                    return _buildNarrowLayout();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildEditor(),
        ),
        Expanded(
          flex: 1,
          child: _buildDetailHistory(),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return Column(
      children: [
        Expanded(
          child: _buildEditor(),
        ),
        SizedBox(
          height: 200,
          child: _buildDetailHistory(),
        ),
      ],
    );
  }

  Widget _buildEditor() {
    return _isPreview
        ? Markdown(data: _markdownController.text)
        : TextField(
            controller: _markdownController,
            maxLines: null,
            expands: true,
            decoration: const InputDecoration(
              hintText: 'Enter your markdown here...',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(16),
            ),
          );
  }

  Widget _buildDetailHistory() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts_quiz')
          .doc(widget.postId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          // ignore: avoid_print
          print('Error in StreamBuilder: ${snapshot.error}');
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          // ignore: avoid_print
          print('No data available for this post');
          return Center(
            child: ElevatedButton(
              onPressed: _addNewDetail,
              child: const Text('Add New Post Detail'),
            ),
          );
        }

        var postData = snapshot.data!.data() as Map<String, dynamic>?;
        if (postData == null) {
          print('Post data is null');
          return const Text('No data available');
        }

        var detail = postData['detail'];
        print('Detail type in history: ${detail.runtimeType}');
        print('Detail value in history: $detail');

        if (detail == null) {
          return Center(
            child: ElevatedButton(
              onPressed: _addNewDetail,
              child: const Text('Add Post Detail'),
            ),
          );
        }

        String displayDetail = detail.toString();

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Version',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(displayDetail),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _editDetail(displayDetail),
                  child: const Text('Edit This Version'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addNewDetail() {
    setState(() {
      _markdownController.clear();
      _currentDetailId = null;
      _isPreview = false;
    });
  }

  void _editDetail(String detail) {
    setState(() {
      _markdownController.text = detail;
      _currentDetailId = widget.postId;
      _isPreview = false;
    });
  }
}
