import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lafblog/models/api_response.dart';
import 'package:lafblog/models/post.dart';
import 'package:lafblog/screens/login.dart';
import 'package:lafblog/services/config.dart';
import 'package:lafblog/services/post_services.dart';
import 'package:lafblog/services/user_service.dart';
import 'package:lafblog/theme.dart';

class PostForm extends StatefulWidget {
  final Post? post;
  final String? title;

  const PostForm({
    Key? key,
    this.post,
    this.title,
  }) : super(key: key);

  @override
  State<PostForm> createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  TextEditingController contentField = TextEditingController();
  bool _loading = false;
  File? _imageFile;
  final _picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await _picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _createPost() async {
    String? image = _imageFile == null ? null : getStringImage(_imageFile);
    ApiResponse response = await createPost(contentField.text, image);

    if (response.error == null) {
      Navigator.of(context).pop();
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
      setState(() {
        _loading = !_loading;
      });
    }
  }

  // Edit Post
  void _editPost(int postId) async {
    ApiResponse response = await editPost(postId, contentField.text);

    if (response.error == null) {
      Navigator.of(context).pop();
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
      setState(() {
        _loading = !_loading;
      });
    }
  }

  @override
  void initState() {
    if (widget.post != null) {
      contentField.text = widget.post!.content ?? '';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        centerTitle: true,
        title: Text(
          '${widget.title}',
          style: whiteTextStyle,
        ),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            )
          : ListView(
              padding: EdgeInsets.all(defaultmargin),
              children: [
                widget.post != null
                    ? const SizedBox()
                    : Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: _imageFile == null
                              ? null
                              : DecorationImage(
                                  image: FileImage(
                                    _imageFile ?? File(''),
                                  ),
                                  fit: BoxFit.cover,
                                ),
                        ),
                        child: Center(
                            child: _imageFile == null
                                ? IconButton(
                                    onPressed: () {
                                      getImage();
                                    },
                                    icon: Icon(
                                      Icons.image,
                                      color: greyColor,
                                      size: 50,
                                    ),
                                  )
                                : const SizedBox()),
                      ),
                const SizedBox(
                  height: 30,
                ),
                Form(
                  key: _formkey,
                  child: TextFormField(
                    controller: contentField,
                    cursorColor: primaryColor,
                    style: darkTextStyle,
                    validator: (value) => value!.isEmpty ? 'write something' : null,
                    keyboardType: TextInputType.multiline,
                    maxLines: 5,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 1,
                          color: primaryColor,
                        ),
                      ),
                      hintText: 'Write Something',
                      hintStyle: darkTextStyle.copyWith(color: greyColor),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 1,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateColor.resolveWith((states) => primaryColor),
                    padding: MaterialStateProperty.resolveWith(
                      (states) => const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 30,
                      ),
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  onPressed: () {
                    if (_formkey.currentState!.validate()) {
                      setState(() {
                        _loading = !_loading;
                      });
                      if (widget.post == null) {
                        _createPost();
                      } else {
                        _editPost(widget.post!.id ?? 0);
                      }
                    }
                  },
                  child: Text(
                    'Create Post',
                    style: whiteTextStyle.copyWith(
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
