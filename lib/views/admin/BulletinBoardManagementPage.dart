import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'AdminPostDetailPage.dart';
import 'package:intl/intl.dart';

import 'CommentManagementPage.dart';

class BulletinBoardManagementPage extends StatefulWidget {
  const BulletinBoardManagementPage({super.key});

  @override
  _BulletinBoardManagementPageState createState() =>
      _BulletinBoardManagementPageState();
}

class _BulletinBoardManagementPageState
    extends State<BulletinBoardManagementPage> {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSidebar(context),
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: _buildPostTable(),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          Image.asset('assets/images/AppLogo.png', height: 30),
          const SizedBox(width: 10),
          const Text('Post & Quiz Management',
              style: TextStyle(color: Colors.black)),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.language, color: Colors.black),
          onPressed: () {},
        ),
        TextButton(
          child:
              const Text('Go To Website', style: TextStyle(color: Colors.blue)),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.chat, color: Colors.black),
          onPressed: () {},
        ),
        PopupMenuButton(
          child: const Row(
            children: [
              Text('Pro - Tech', style: TextStyle(color: Colors.black)),
              Icon(Icons.arrow_drop_down, color: Colors.black),
            ],
          ),
          itemBuilder: (context) => [
            const PopupMenuItem(child: Text('Settings')),
            const PopupMenuItem(child: Text('Help')),
          ],
        ),
        const CircleAvatar(
          backgroundImage: AssetImage('assets/images/default_avatar.png'),
        ),
        PopupMenuButton(
          child: const Row(
            children: [
              Text('Admin', style: TextStyle(color: Colors.black)),
              Icon(Icons.arrow_drop_down, color: Colors.black),
            ],
          ),
          itemBuilder: (context) => [
            const PopupMenuItem(child: Text('Profile')),
            const PopupMenuItem(child: Text('Logout')),
          ],
        ),
      ],
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 200,
      color: const Color(0xFF00A19D),
      child: ListView(
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text('Super Admin'),
            accountEmail: null,
            currentAccountPicture: CircleAvatar(
              backgroundImage: AssetImage('assets/images/default_avatar.png'),
            ),
            decoration: BoxDecoration(color: Color(0xFF00A19D)),
          ),
          _buildSidebarItem('Dashboard', Icons.dashboard, onTap: () {
            Navigator.pop(context);
          }),
          _buildSidebarItem('Post Management', Icons.post_add,
              isSelected: true),
          _buildSidebarItem('Comment Management', Icons.comment, onTap: () {
            // Navigate to CommentManagementPage
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const CommentManagementPage()),
            );
          }),
          _buildSidebarItem('Quiz Management', Icons.question_answer),
          _buildSidebarItem('Settings', Icons.settings),
          _buildSidebarItem('Logout', Icons.exit_to_app),
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
      selectedTileColor: Colors.white.withOpacity(0.1),
      onTap: onTap,
    );
  }

  Widget _buildPostTable() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('posts_quiz').snapshots(),
      builder: (context, snapshot) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Posts and Quizzes',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Post/Quiz'),
                    onPressed: () => _showAddPostDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00A19D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (snapshot.hasError)
              Center(child: Text('Error occurred: ${snapshot.error}'))
            else if (snapshot.connectionState == ConnectionState.waiting)
              const Center(child: CircularProgressIndicator())
            else if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
              const Center(child: Text('No posts available'))
            else
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('STT')),
                        DataColumn(label: Text('Title')),
                        DataColumn(label: Text('Type')),
                        DataColumn(label: Text('Description')),
                        DataColumn(label: Text('Image')),
                        DataColumn(label: Text('Responses')),
                        DataColumn(label: Text('Created At')),
                        DataColumn(label: Text('Updated At')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: _buildDataRows(snapshot.data!.docs),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  List<DataRow> _buildDataRows(List<DocumentSnapshot> docs) {
    return docs.asMap().entries.map((entry) {
      final index = entry.key;
      final doc = entry.value;
      final data = doc.data() as Map<String, dynamic>;

      String responsesText = '';
      if (data['type'] == 'Post') {
        responsesText =
            '${data['views'] ?? 0} views\n${data['likeCount'] ?? 0} likes\n${data['commentCount'] ?? 0} comments';
      } else {
        responsesText = '${data['responses'] ?? 0} trả lời';
      }

      final createdAt = data['createdAt'] as Timestamp?;
      final updatedAt = data['updatedAt'] as Timestamp?;
      final isHidden = data['isHidden'] ?? false;

      return DataRow(
        cells: [
          DataCell(Text('${index + 1}')),
          DataCell(Text(data['title'] ?? '')),
          DataCell(Text(data['type'] ?? 'Post')),
          DataCell(Text(_getDescription(data))),
          DataCell(_buildImageCell(data['imageUrl'])),
          DataCell(Text(responsesText)),
          DataCell(Text(createdAt != null
              ? DateFormat('dd/MM/yyyy HH:mm').format(createdAt.toDate())
              : 'N/A')),
          DataCell(Text(updatedAt != null
              ? DateFormat('dd/MM/yyyy HH:mm').format(updatedAt.toDate())
              : 'N/A')),
          DataCell(
            IconButton(
              icon: Icon(isHidden ? Icons.visibility_off : Icons.visibility),
              onPressed: () => _toggleVisibility(doc.id, isHidden),
            ),
          ),
          DataCell(Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _showEditPostDialog(context, doc),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _showDeleteConfirmation(doc.id),
              ),
              IconButton(
                icon: const Icon(Icons.visibility, color: Colors.green),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminPostDetailPage(postId: doc.id),
                    ),
                  );
                },
              ),
            ],
          )),
        ],
      );
    }).toList();
  }

  void _toggleVisibility(String docId, bool currentStatus) {
    FirebaseFirestore.instance.collection('posts_quiz').doc(docId).update({
      'isHidden': !currentStatus,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                currentStatus ? 'Post is now visible' : 'Post is now hidden')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update visibility: $error')),
      );
    });
  }

  void _showDeleteConfirmation(String docId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text(
              'Are you sure you want to permanently delete this post? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                _deletePost(docId);
              },
            ),
          ],
        );
      },
    );
  }

  void _showCommentsDialog(BuildContext context, String postId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Comments'),
          content: SizedBox(
            width: double.maxFinite,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts_quiz')
                  .doc(postId)
                  .collection('comments')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                return ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> comment =
                        document.data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(comment['text']),
                      subtitle: Text(comment['user']),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteComment(postId, document.id),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteComment(String postId, String commentId) {
    FirebaseFirestore.instance
        .collection('posts_quiz')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .delete()
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment deleted successfully')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete comment: $error')),
      );
    });

    // Update the comment count
    FirebaseFirestore.instance
        .collection('posts_quiz')
        .doc(postId)
        .update({'commentCount': FieldValue.increment(-1)});
  }

  String _getDescription(Map<String, dynamic> data) {
    String description = data['description'] ?? '';
    if (description.isNotEmpty) return description;

    Timestamp? timestamp = data['timestamp'] as Timestamp?;
    if (timestamp == null) return '';

    final now = DateTime.now();
    final postTime = timestamp.toDate();
    final difference = now.difference(postTime);

    if (difference.inMinutes < 1) {
      return 'Pro - Tech: Vừa xong';
    } else {
      return 'Pro - Tech: ${difference.inMinutes} phút trước';
    }
  }

  Widget _buildImageCell(String? imageUrl) {
    return imageUrl != null && imageUrl.isNotEmpty
        ? Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover)
        : const Text('No image');
  }

  void _showAddPostDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController imageUrlController = TextEditingController();
    String postType = 'Post';
    List<TextEditingController> optionControllers =
        List.generate(3, (_) => TextEditingController());
    int correctAnswer = 0;
    String? imagePreviewUrl;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Post/Quiz'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    TextField(
                      controller: titleController,
                      decoration:
                          const InputDecoration(hintText: "Enter title"),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration:
                          const InputDecoration(hintText: "Enter description"),
                    ),
                    DropdownButton<String>(
                      value: postType,
                      onChanged: (String? newValue) {
                        setState(() {
                          postType = newValue!;
                        });
                      },
                      items: <String>['Post', 'Quiz']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    if (postType == 'Quiz')
                      ...List.generate(3, (index) {
                        return Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: optionControllers[index],
                                decoration: InputDecoration(
                                    hintText: "Option ${index + 1}"),
                              ),
                            ),
                            Radio<int>(
                              value: index,
                              groupValue: correctAnswer,
                              onChanged: (int? value) {
                                setState(() {
                                  correctAnswer = value!;
                                });
                              },
                            ),
                          ],
                        );
                      }),
                    TextField(
                      controller: imageUrlController,
                      decoration:
                          const InputDecoration(hintText: "Enter Image URL"),
                      onChanged: (value) {
                        setState(() {
                          imagePreviewUrl = value;
                        });
                      },
                    ),
                    if (imagePreviewUrl != null && imagePreviewUrl!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.network(
                          imagePreviewUrl!,
                          height: 100,
                          errorBuilder: (context, error, stackTrace) {
                            return const Text('Invalid URL');
                          },
                        ),
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
                  onPressed: () async {
                    try {
                      final description =
                          descriptionController.text.trim().isEmpty
                              ? null
                              : descriptionController.text;

                      await FirebaseFirestore.instance
                          .collection('posts_quiz')
                          .add({
                        'title': titleController.text,
                        'description': description,
                        'imageUrl': imageUrlController.text,
                        'type': postType,
                        'responses': 0,
                        'views': 0, // Giá trị mặc định là 0
                        'likes': 0, // Giá trị mặc định là 0
                        'comments': 0, // Giá trị mặc định là 0
                        'timestamp': FieldValue.serverTimestamp(),
                        'createdAt': FieldValue.serverTimestamp(),
                        'updatedAt': FieldValue.serverTimestamp(),
                        'isHidden': false,
                        if (postType == 'Quiz') ...{
                          'options': optionControllers
                              .map((controller) => controller.text)
                              .toList(),
                          'correctAnswer': correctAnswer,
                        },
                      });

                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Post added successfully!')),
                      );
                    } catch (e) {
                      print('Error adding post: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Error adding post. Please try again.')),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditPostDialog(BuildContext context, DocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>?;

    if (data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Document data is null')),
      );
      return;
    }

    final TextEditingController titleController =
        TextEditingController(text: data['title'] ?? '');
    final TextEditingController descriptionController =
        TextEditingController(text: data['description'] ?? '');
    final TextEditingController imageUrlController =
        TextEditingController(text: data['imageUrl'] ?? '');
    final TextEditingController viewsController =
        TextEditingController(text: data['views']?.toString() ?? '0');
    final TextEditingController likesController =
        TextEditingController(text: data['likes']?.toString() ?? '0');
    final TextEditingController commentsController =
        TextEditingController(text: data['comments']?.toString() ?? '0');
    String postType = data['type'] ?? 'Post';
    String? imagePreviewUrl = data['imageUrl'];
    bool isHidden = data['isHidden'] ?? false;

    Timestamp? createdAt = data['createdAt'] as Timestamp?;
    Timestamp? updatedAt = data['updatedAt'] as Timestamp?;

    List<TextEditingController> optionControllers = List.generate(
      3,
      (index) => TextEditingController(
          text: (data['options'] as List<dynamic>?)?[index]?.toString() ?? ''),
    );
    int correctAnswer = data['correctAnswer'] ?? 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Post/Quiz'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: "Title"),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration:
                          const InputDecoration(labelText: "Description"),
                      maxLines: 3,
                    ),
                    DropdownButtonFormField<String>(
                      value: postType,
                      decoration: const InputDecoration(labelText: "Type"),
                      onChanged: (String? newValue) {
                        setState(() {
                          postType = newValue!;
                        });
                      },
                      items: <String>['Post', 'Quiz']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    if (postType == 'Quiz')
                      ...List.generate(3, (index) {
                        return Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: optionControllers[index],
                                decoration: InputDecoration(
                                    labelText: "Option ${index + 1}"),
                              ),
                            ),
                            Radio<int>(
                              value: index,
                              groupValue: correctAnswer,
                              onChanged: (int? value) {
                                setState(() {
                                  correctAnswer = value!;
                                });
                              },
                            ),
                          ],
                        );
                      }),
                    TextField(
                      controller: imageUrlController,
                      decoration: const InputDecoration(labelText: "Image URL"),
                      onChanged: (value) {
                        setState(() {
                          imagePreviewUrl = value;
                        });
                      },
                    ),
                    if (imagePreviewUrl != null && imagePreviewUrl!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Image.network(
                          imagePreviewUrl!,
                          height: 100,
                          errorBuilder: (context, error, stackTrace) {
                            return const Text('Invalid URL');
                          },
                        ),
                      ),
                    TextField(
                      controller: viewsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Views"),
                    ),
                    TextField(
                      controller: likesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Likes"),
                    ),
                    TextField(
                      controller: commentsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Comments"),
                    ),
                    CheckboxListTile(
                      title: const Text("Hidden"),
                      value: isHidden,
                      onChanged: (bool? value) {
                        setState(() {
                          isHidden = value!;
                        });
                      },
                    ),
                    Text('Created At: ${_formatTimestamp(createdAt)}'),
                    Text('Updated At: ${_formatTimestamp(updatedAt)}'),
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
                  child: const Text('Update'),
                  onPressed: () {
                    final description =
                        descriptionController.text.trim().isEmpty
                            ? null
                            : descriptionController.text;

                    Map<String, dynamic> updateData = {
                      'title': titleController.text,
                      'description': description,
                      'imageUrl': imageUrlController.text,
                      'type': postType,
                      'views': int.tryParse(viewsController.text) ?? 0,
                      'likes': int.tryParse(likesController.text) ?? 0,
                      'comments': int.tryParse(commentsController.text) ?? 0,
                      'isHidden': isHidden,
                      'updatedAt': FieldValue.serverTimestamp(),
                    };

                    if (postType == 'Quiz') {
                      updateData['options'] = optionControllers
                          .map((controller) => controller.text)
                          .toList();
                      updateData['correctAnswer'] = correctAnswer;
                    }

                    FirebaseFirestore.instance
                        .collection('posts_quiz')
                        .doc(document.id)
                        .update(updateData)
                        .then((_) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Post updated successfully!')),
                      );
                    }).catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Failed to update post: $error')),
                      );
                    });
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    return DateFormat('dd/MM/yyyy HH:mm').format(timestamp.toDate());
  }

  void _deletePost(String documentId) {
    FirebaseFirestore.instance
        .collection('posts_quiz')
        .doc(documentId)
        .delete()
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post deleted permanently!')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete post: $error')),
      );
    });
  }

  void _incrementResponses(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    if (data['type'] == 'Post') {
      FirebaseFirestore.instance
          .collection('posts_quiz')
          .doc(document.id)
          .update({'responses': FieldValue.increment(1)});
    } else if (data['type'] == 'Quiz') {
      FirebaseFirestore.instance
          .collection('posts_quiz')
          .doc(document.id)
          .update({'responses': FieldValue.increment(1)});
    }
  }
}
