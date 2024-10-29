import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Chi tiết bài viết', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.pink),
            onPressed: () {
              // Implement share functionality
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('posts_quiz').doc(widget.postId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Bài viết không tồn tại'));
          }

          var postData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          List<String> likes = [];
          int likeCount = 0;
          
          if (postData['likes'] is List) {
            likes = List<String>.from(postData['likes'] as List? ?? []);
            likeCount = likes.length;
          } else if (postData['likes'] is int) {
            likeCount = postData['likes'] as int;
          }

          bool isLiked = likes.contains(_auth.currentUser?.uid);
          int commentCount = postData['commentCount'] as int? ?? 0;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (postData['imageUrl'] != null)
                        Image.network(
                          postData['imageUrl'] as String,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PRO - TECH',
                              style: TextStyle(
                                  color: Colors.pink, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              postData['title'] as String? ?? 'Không có tiêu đề',
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            _formatTimestamp(postData['timestamp'] as Timestamp?),
                            const SizedBox(height: 16),
                            if (postData['detail'] != null)
                              MarkdownBody(
                                data: postData['detail'] as String? ?? '',
                              ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    isLiked ? Icons.favorite : Icons.favorite_border,
                                    color: isLiked ? Colors.red : Colors.grey,
                                  ),
                                  onPressed: () => _toggleLike(likes),
                                ),
                                const SizedBox(width: 8),
                                Text('$likeCount'),
                                const SizedBox(width: 16),
                                const Icon(Icons.comment, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text('$commentCount'),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text('Nhận xét:',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            _buildCommentsList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'Viết nhận xét...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.pink),
                      onPressed: _addComment,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCommentsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('posts_quiz')
          .doc(widget.postId)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        return Column(
          children: snapshot.data!.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return FutureBuilder<DocumentSnapshot>(
              future: _firestore.collection('users').doc(data['userId']).get(),
              builder: (context, userSnapshot) {
                String userName = 'Người dùng';
                if (userSnapshot.hasData && userSnapshot.data != null && userSnapshot.data!.exists) {
                  userName = (userSnapshot.data!.data() as Map<String, dynamic>?)?['name'] ?? 'Người dùng';
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        child: Text(userName[0].toUpperCase()),
                      ),
                      title: Text(userName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data['comment'] as String? ?? ''),
                          _formatTimestamp(data['timestamp'] as Timestamp?),
                        ],
                      ),
                    ),
                    if (data['replies'] != null && (data['replies'] as List).isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: (data['replies'] as List).map((reply) {
                            return ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.admin_panel_settings),
                              ),
                              title: const Text('Admin'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(reply['text'] ?? ''),
                                  _formatTimestamp(reply['timestamp'] is Timestamp 
                                      ? reply['timestamp'] as Timestamp 
                                      : Timestamp.fromMillisecondsSinceEpoch(reply['timestamp'] as int)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    const Divider(),
                  ],
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _toggleLike(List<String> currentLikes) async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentReference postRef = _firestore.collection('posts_quiz').doc(widget.postId);
      
      if (currentLikes.contains(user.uid)) {
        currentLikes.remove(user.uid);
      } else {
        currentLikes.add(user.uid);
      }

      await postRef.update({
        'likes': currentLikes,
        'likeCount': currentLikes.length,
      });
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.isNotEmpty) {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('posts_quiz')
            .doc(widget.postId)
            .collection('comments')
            .add({
          'userId': user.uid,
          'comment': _commentController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });

        await _firestore.collection('posts_quiz').doc(widget.postId).update({
          'commentCount': FieldValue.increment(1),
        });

        _commentController.clear();
      }
    }
  }

  Widget _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return const SizedBox.shrink();
    final now = DateTime.now();
    final difference = now.difference(timestamp.toDate());
    String timeAgo;
    if (difference.inMinutes < 60) {
      timeAgo = '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      timeAgo = '${difference.inHours} giờ trước';
    } else {
      timeAgo = '${difference.inDays} ngày trước';
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.access_time, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(timeAgo, style: const TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }
}