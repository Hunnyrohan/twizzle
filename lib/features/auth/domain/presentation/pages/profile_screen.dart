// lib/presentation/screens/profile_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import 'package:twizzle/widgets/tweet_card.dart';
import '../../../domain/entities/tweet.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  /* ---- profile data ---- */
  String _avatar = 'https://i.pravatar.cc/150?img=8';
  final String _handle = '@johndoe';
  final String _joined = 'Joined April 2024';
  final String _website = 'johndoe.com';
  final int _following = 150;
  final int _followers = 10;

  String _name = 'John Doe';
  String _bio = 'capridem';

  final List<Tweet> _tweets = [];

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:5000/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  /* ---------------- IMAGE PICK + UPLOAD ---------------- */

  Future<void> _changePhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Camera'),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Gallery'),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      ),
    );

    if (source == null) return;

    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: source);
    if (file == null) return;

    try {
      final formData = FormData.fromMap({
        'profileImage': await MultipartFile.fromFile(
          file.path,
          filename: p.basename(file.path),
        ),
      });

      final res = await _dio.post('/upload/profile-image', data: formData);

      final imagePath = res.data['data']['path'] as String;
      final imageUrl = 'http://10.0.2.2:5000/$imagePath';

      setState(() => _avatar = imageUrl);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo uploaded successfully ✓')),
      );
    } catch (e) {
      setState(() => _avatar = file.path);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTweets();
  }

  Future<void> _loadTweets() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _tweets.addAll(_dummyTweets()));
  }

  List<Tweet> _dummyTweets() => [
    Tweet(
      id: 'p1',
      name: _name,
      handle: _handle,
      time: '2h',
      text:
          'What are you reading today? Do you prefer physical books or e-books?',
      avatar: _avatar,
      likes: 4,
      retweets: 7,
      replies: 8,
    ),
    Tweet(
      id: 'p2',
      name: _name,
      handle: _handle,
      time: 'Apr 10',
      text: 'Enjoying a sunny day out with a good cup of coffee',
      avatar: _avatar,
      likes: 20,
      retweets: 0,
      replies: 0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final tablet = MediaQuery.of(context).size.shortestSide >= 600;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: NestedScrollView(
          headerSliverBuilder: (_, __) => [
            SliverAppBar(
              expandedHeight: 320,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('Profile'),
                background: _header(),
              ),
              bottom: _tabBar(),
            ),
          ],
          body: TabBarView(
            children: [
              _tweetGrid(tablet),
              const Center(child: Text('Replies')),
              const Center(child: Text('Media')),
              const Center(child: Text('Likes')),
            ],
          ),
        ),
      ),
    );
  }

  /* ---------------- HEADER ---------------- */

  Widget _header() {
    return Stack(
      children: [
        Container(
          height: 320,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff1DA1F2), Color(0xff0D8BD9)],
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundImage: _avatar.startsWith('http')
                        ? NetworkImage(_avatar)
                        : FileImage(File(_avatar)) as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _changePhoto,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.fromBorderSide(
                            BorderSide(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(_handle, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 6),
              Text(
                _bio,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                '$_joined · $_website',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _stat(_following.toString(), 'Following'),
                  const SizedBox(width: 20),
                  _stat(_followers.toString(), 'Followers'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stat(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  PreferredSizeWidget _tabBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(30),
          ),
          child: TabBar(
            indicator: BoxDecoration(
              color: const Color(0xff1DA1F2),
              borderRadius: BorderRadius.circular(30),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey.shade700,
            tabs: const [
              Tab(text: 'Posts'),
              Tab(text: 'Replies'),
              Tab(text: 'Media'),
              Tab(text: 'Likes'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tweetGrid(bool tablet) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: tablet ? 2 : 1,
        childAspectRatio: tablet ? 1.6 : 1.2,
      ),
      itemCount: _tweets.length,
      itemBuilder: (_, i) =>
          TweetCard(tweet: _tweets[i], onAction: () => setState(() {})),
    );
  }
}
