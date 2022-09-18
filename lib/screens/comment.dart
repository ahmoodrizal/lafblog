import 'package:flutter/material.dart';
import 'package:lafblog/models/api_response.dart';
import 'package:lafblog/models/comment.dart';
import 'package:lafblog/screens/login.dart';
import 'package:lafblog/services/comment_service.dart';
import 'package:lafblog/services/config.dart';
import 'package:lafblog/services/user_service.dart';
import 'package:lafblog/theme.dart';

class CommentScreen extends StatefulWidget {
  final int? postId;
  const CommentScreen({
    Key? key,
    this.postId,
  }) : super(key: key);

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  TextEditingController commentField = TextEditingController();
  List<dynamic> _commentList = [];
  bool _loading = true;
  int userId = 0;
  int _editCommentId = 0;

  // Fetch all Comments
  Future<void> _fetchComment() async {
    userId = await getUserId();
    ApiResponse response = await getComments(widget.postId ?? 0);

    if (response.error == null) {
      setState(() {
        _commentList = response.data as List<dynamic>;
        _loading = _loading ? !_loading : _loading;
      });
    } else if (response.error == unauthorized) {
      logout().then((value) => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => Login(),
          ),
          (route) => false));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${response.error}',
            style: whiteTextStyle,
          ),
        ),
      );
    }
  }

  // create a comment
  void _createComment() async {
    ApiResponse response = await createComment(widget.postId ?? 0, commentField.text);

    if (response.error == null) {
      commentField.clear();
      _fetchComment();
    } else if (response.error == unauthorized) {
      logout().then((value) => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => Login(),
          ),
          (route) => false));
    } else {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${response.error}',
            style: whiteTextStyle,
          ),
        ),
      );
    }
  }

  // edit comment
  void _editComment() async {
    ApiResponse response = await editComment(_editCommentId, commentField.text);

    if (response.error == null) {
      _editCommentId = 0;
      commentField.clear();
      _fetchComment();
    } else if (response.error == unauthorized) {
      logout().then((value) => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => Login(),
          ),
          (route) => false));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${response.error}',
            style: whiteTextStyle,
          ),
        ),
      );
    }
  }

  // delete comment
  void _deleteComment(int commentId) async {
    ApiResponse response = await deleteComment(commentId);

    if (response.error == null) {
      _fetchComment();
    } else if (response.error == unauthorized) {
      logout().then((value) => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => Login(),
          ),
          (route) => false));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${response.error}',
            style: whiteTextStyle,
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    _fetchComment();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        title: Text(
          'Comment',
          style: whiteTextStyle,
        ),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () {
                      return _fetchComment();
                    },
                    child: ListView.builder(
                      itemCount: _commentList.length,
                      itemBuilder: (context, index) {
                        Comment comment = _commentList[index];
                        return Container(
                          padding: const EdgeInsets.all(15),
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.black87, width: 0.5),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          image: comment.user!.profile != null
                                              ? DecorationImage(
                                                  image: NetworkImage('${comment.user!.profile}'),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                          borderRadius: BorderRadius.circular(15),
                                          color: greyColor,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        '${comment.user!.name}',
                                        style: darkTextStyle.copyWith(fontSize: 16),
                                      )
                                    ],
                                  ),
                                  comment.user!.id == userId
                                      ? PopupMenuButton(
                                          itemBuilder: (context) => [
                                            PopupMenuItem(
                                              value: 'edit',
                                              child: Text(
                                                'Edit',
                                                style: darkTextStyle,
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: 'delete',
                                              child: Text(
                                                'Delete',
                                                style: darkTextStyle,
                                              ),
                                            ),
                                          ],
                                          onSelected: (value) {
                                            if (value == 'edit') {
                                              // process edit
                                              setState(() {
                                                _editCommentId = comment.id ?? 0;
                                                commentField.text = comment.comment ?? '';
                                              });
                                            } else {
                                              // process delete
                                              _deleteComment(comment.id ?? 0);
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(right: 10),
                                            child: Icon(
                                              Icons.more_vert,
                                              color: primaryColor,
                                            ),
                                          ),
                                        )
                                      : const SizedBox(),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                '${comment.comment}',
                                style: darkTextStyle,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: primaryColor,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentField,
                          enableSuggestions: false,
                          autocorrect: false,
                          style: darkTextStyle,
                          decoration: InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: primaryColor,
                              ),
                            ),
                            label: Text(
                              'write something',
                              style: darkTextStyle.copyWith(
                                color: greyColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (commentField.text.isNotEmpty) {
                            setState(() {
                              _loading = true;
                            });
                            if (_editCommentId != 0) {
                              _editComment();
                            } else {
                              _createComment();
                            }
                          }
                        },
                        icon: Icon(
                          Icons.send,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
