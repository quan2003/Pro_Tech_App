// ignore_for_file: file_names, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentManagementPage extends StatelessWidget {
  const CommentManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comment Management'),
        backgroundColor: const Color(0xFF00A19D),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts_quiz')
            .where('type', isEqualTo: 'Post')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          List<DocumentSnapshot> posts = snapshot.data!.docs;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('STT')),
                DataColumn(label: Text('Title')),
                DataColumn(label: Text('Views')),
                DataColumn(label: Text('Likes')),
                DataColumn(label: Text('Comments')),
                DataColumn(label: Text('Actions')),
              ],
              rows: List<DataRow>.generate(
                posts.length,
                (index) {
                  Map<String, dynamic> postData =
                      posts[index].data() as Map<String, dynamic>;
                  return DataRow(
                    cells: [
                      DataCell(Text('${index + 1}')),
                      DataCell(Text(postData['title'] ?? 'Untitled')),
                      DataCell(Text(postData['views']?.toString() ?? '0')),
                      DataCell(Text(postData['likeCount']?.toString() ?? '0')),
                      DataCell(
                          Text(postData['commentCount']?.toString() ?? '0')),
                      DataCell(
                        ElevatedButton(
                          child: const Text('View Comments'),
                          onPressed: () => _showCommentsDialog(
                              context, posts[index].id, postData['title']),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCommentsDialog(
      BuildContext context, String postId, String postTitle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Comments for: $postTitle'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
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
                  return const Center(child: CircularProgressIndicator());
                }

                List<DocumentSnapshot> comments = snapshot.data?.docs ?? [];

                if (comments.isEmpty) {
                  return const Center(child: Text('No comments yet.'));
                }

                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> commentData =
                        comments[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(commentData['comment']?.toString() ??
                          'No comment text'),
                      subtitle: Text(
                          'User ID: ${commentData['userId']?.toString() ?? 'Unknown'}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.reply),
                            onPressed: () => _replyToComment(
                                context,
                                postId,
                                comments[index].id,
                                commentData['comment']?.toString() ??
                                    'No comment text'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteComment(
                                context, postId, comments[index].id),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _replyToComment(BuildContext context, String postId, String commentId,
      String originalComment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController replyController = TextEditingController();
        return AlertDialog(
          title: const Text('Reply to Comment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Original comment: $originalComment',
                  style: const TextStyle(fontStyle: FontStyle.italic)),
              const SizedBox(height: 10),
              TextField(
                controller: replyController,
                decoration: const InputDecoration(hintText: "Enter your reply"),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Reply'),
              onPressed: () {
                if (replyController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reply cannot be empty')),
                  );
                  return;
                }
                _addReplyToFirestore(
                    context, postId, commentId, replyController.text);
              },
            ),
          ],
        );
      },
    );
  }

  void _addReplyToFirestore(
      BuildContext context, String postId, String commentId, String replyText) {
    FirebaseFirestore.instance.runTransaction((transaction) async {
      try {
        // Thực hiện tất cả các thao tác đọc trước
        DocumentReference commentRef = FirebaseFirestore.instance
            .collection('posts_quiz')
            .doc(postId)
            .collection('comments')
            .doc(commentId);

        DocumentReference postRef =
            FirebaseFirestore.instance.collection('posts_quiz').doc(postId);

        DocumentSnapshot commentSnapshot = await transaction.get(commentRef);
        DocumentSnapshot postSnapshot = await transaction.get(postRef);

        // Sau khi đã đọc xong, thực hiện các thao tác ghi
        if (commentSnapshot.exists) {
          Map<String, dynamic> commentData =
              commentSnapshot.data() as Map<String, dynamic>;
          List<dynamic> currentReplies = commentData['replies'] ?? [];

          // ignore: unused_local_variable
          DateTime now = DateTime.now();
          currentReplies.add({
            'text': replyText,
            'user': 'Admin', // Bạn có thể muốn lấy user thực tế
            'timestamp': Timestamp.now(),
          });

          transaction.update(commentRef, {'replies': currentReplies});

          if (postSnapshot.exists) {
            transaction
                .update(postRef, {'commentCount': FieldValue.increment(1)});
          }
        }
      } catch (e) {
        // ignore: avoid_print
        print('Error in transaction: $e');
        rethrow;
      }
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reply added successfully')));
      Navigator.of(context).pop();
    }).catchError((error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to add reply: $error')));
    });
  }

  void _deleteComment(BuildContext context, String postId, String commentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Comment'),
          content: const Text(
              'Are you sure you want to delete this comment? This action cannot be undone.'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                FirebaseFirestore.instance.runTransaction((transaction) async {
                  // Thực hiện tất cả các thao tác đọc trước
                  DocumentReference commentRef = FirebaseFirestore.instance
                      .collection('posts_quiz')
                      .doc(postId)
                      .collection('comments')
                      .doc(commentId);
                  DocumentReference postRef = FirebaseFirestore.instance
                      .collection('posts_quiz')
                      .doc(postId);

                  DocumentSnapshot commentSnapshot =
                      await transaction.get(commentRef);
                  DocumentSnapshot postSnapshot =
                      await transaction.get(postRef);

                  // Sau khi đã đọc xong, thực hiện các thao tác ghi
                  if (commentSnapshot.exists) {
                    transaction.delete(commentRef);

                    if (postSnapshot.exists) {
                      int currentCommentCount =
                          postSnapshot.get('commentCount') ?? 0;
                      if (currentCommentCount > 0) {
                        transaction.update(postRef,
                            {'commentCount': FieldValue.increment(-1)});
                      }
                    }
                  }
                }).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Comment deleted successfully')));
                  Navigator.of(context).pop(); // Close the confirmation dialog
                  Navigator.of(context).pop(); // Close the comments dialog
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Failed to delete comment: $error')));
                  Navigator.of(context).pop(); // Close the confirmation dialog
                });
              },
            ),
          ],
        );
      },
    );
  }
}
