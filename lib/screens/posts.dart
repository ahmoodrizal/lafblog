import 'package:flutter/material.dart';
import 'package:lafblog/models/api_response.dart';
import 'package:lafblog/models/post.dart';
import 'package:lafblog/screens/comment.dart';
import 'package:lafblog/screens/login.dart';
import 'package:lafblog/screens/post_form.dart';
import 'package:lafblog/services/config.dart';
import 'package:lafblog/services/post_services.dart';
import 'package:lafblog/services/user_service.dart';
import 'package:lafblog/theme.dart';

class Posts extends StatefulWidget {
  const Posts({Key? key}) : super(key: key);

  @override
  State<Posts> createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  List<dynamic> _postList = [];
  int userId = 0;
  bool _loading = true;

  // fetch all post
  Future<void> fetchPosts() async {
    userId = await getUserId();
    // print(userId);
    ApiResponse response = await getPosts();

    if (response.error == null) {
      setState(() {
        _postList = response.data as List<dynamic>;
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

  void _handleLikeOrUnlikePost(int postId) async {
    ApiResponse response = await likeOrUnlike(postId);
    if (response.error == null) {
      fetchPosts();
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

  void _handleDeletePost(int postId) async {
    ApiResponse response = await deletePost(postId);
    if (response.error == null) {
      fetchPosts();
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
    fetchPosts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Center(
            child: CircularProgressIndicator(
              color: primaryColor,
            ),
          )
        : RefreshIndicator(
            backgroundColor: whiteColor,
            color: primaryColor,
            onRefresh: () => fetchPosts(),
            child: ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: _postList.length,
              itemBuilder: (context, index) {
                Post post = _postList[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    image: post.user!.profile != null
                                        ? DecorationImage(
                                            image: NetworkImage('${post.user!.profile}'),
                                          )
                                        : null,
                                    borderRadius: BorderRadius.circular(20),
                                    color: greyColor,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  '${post.user!.name}',
                                  style: darkTextStyle.copyWith(
                                    fontWeight: medium,
                                    fontSize: 18,
                                  ),
                                )
                              ],
                            ),
                          ),
                          post.user!.id == userId
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
                                      Navigator.of(context).push(MaterialPageRoute(
                                        builder: (context) => PostForm(
                                          title: 'Edit Post',
                                          post: post,
                                        ),
                                      ));
                                    } else {
                                      // process delete
                                      _handleDeletePost(post.id ?? 0);
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
                        height: 12,
                      ),
                      Text('${post.content}'),
                      post.image != null
                          ? Container(
                              width: double.infinity,
                              height: 250,
                              margin: const EdgeInsets.only(top: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                image: DecorationImage(
                                  image: NetworkImage('${post.image}'),
                                  fit: BoxFit.cover,
                                  alignment: Alignment.topCenter,
                                ),
                              ),
                            )
                          : SizedBox(
                              height: post.image != null ? 0 : 10,
                            ),
                      Row(
                        children: [
                          Expanded(
                            child: Material(
                              color: Colors.white,
                              child: InkWell(
                                onTap: () {
                                  _handleLikeOrUnlikePost(post.id ?? 0);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        post.selfLiked == true ? Icons.favorite : Icons.favorite_outline,
                                        color: post.selfLiked == true ? Colors.red : primaryColor,
                                        size: 16,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        (post.likesCount ?? 0).toString(),
                                        style: darkTextStyle,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 25,
                            width: 1,
                            color: Colors.black54,
                          ),
                          Expanded(
                            child: Material(
                              color: Colors.white,
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => CommentScreen(
                                      postId: post.id,
                                    ),
                                  ));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.sms_outlined,
                                        color: primaryColor,
                                        size: 16,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        (post.commentsCount ?? 0).toString(),
                                        style: darkTextStyle,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        height: 0.5,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                );
              },
            ),
          );
  }
}
