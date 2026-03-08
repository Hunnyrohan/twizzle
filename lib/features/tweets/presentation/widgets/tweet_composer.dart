import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:twizzle/features/auth/domain/presentation/providers/user_provider.dart';
import 'package:twizzle/features/tweets/presentation/providers/tweet_provider.dart';
import 'package:twizzle/widgets/custom_image.dart';
import 'package:twizzle/core/utils/media_utils.dart';
import 'package:geolocator/geolocator.dart';

class TweetComposer extends StatefulWidget {
  const TweetComposer({Key? key}) : super(key: key);

  @override
  State<TweetComposer> createState() => _TweetComposerState();
}

class _TweetComposerState extends State<TweetComposer> {
  final TextEditingController _controller = TextEditingController();
  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isPosting = false;
  String? _currentLocation;
  bool _isFetchingLocation = false;

  Future<void> _pickImages() async {
    if (_selectedImages.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only attach up to 4 images')),
      );
      return;
    }

    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null && images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images.take(4 - _selectedImages.length));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _toggleLocation() async {
    if (_currentLocation != null) {
      setState(() => _currentLocation = null);
      return;
    }

    setState(() => _isFetchingLocation = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        final position = await Geolocator.getCurrentPosition();
        // For simplicity, just using coordinates. 
        // In a real app, you'd use geocoding to get "Kathmandu, Nepal"
        setState(() {
          _currentLocation = "${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}";
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching location: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: theme.colorScheme.onSurface)),
                ),
                ElevatedButton(
                  onPressed: (_controller.text.isNotEmpty || _selectedImages.isNotEmpty) && !_isPosting
                      ? () => _handlePost()
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff1DA1F2),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xff1DA1F2).withOpacity(0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: _isPosting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Tweet', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipOval(
                  child: user?.image != null
                      ? CustomImage(
                          imageUrl: MediaUtils.resolveImageUrl(user!.image!),
                          width: 40,
                          height: 40,
                        )
                      : const CircleAvatar(radius: 20, child: Icon(Icons.person)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      TextField(
                        controller: _controller,
                        maxLines: null,
                        autofocus: true,
                        onChanged: (val) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: "What's happening?",
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(fontSize: 18),
                      ),
                      
                      if (_currentLocation != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: Color(0xff1DA1F2)),
                            const SizedBox(width: 4),
                            Text(
                              _currentLocation!,
                              style: const TextStyle(color: Color(0xff1DA1F2), fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => setState(() => _currentLocation = null),
                              child: const Icon(Icons.cancel, size: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],

                      if (_selectedImages.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 120,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _selectedImages.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      File(_selectedImages[index].path),
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Toolbar
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.image_outlined, color: Color(0xff1DA1F2)),
                  tooltip: 'Add media',
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.gif_box_outlined, color: Color(0xff1DA1F2)),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.poll_outlined, color: Color(0xff1DA1F2)),
                ),
                IconButton(
                  onPressed: _isFetchingLocation ? null : _toggleLocation,
                  icon: _isFetchingLocation 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Icon(
                          _currentLocation != null ? Icons.location_on : Icons.location_on_outlined, 
                          color: const Color(0xff1DA1F2)
                        ),
                ),
                const Spacer(),
                if (_controller.text.isNotEmpty)
                  Text(
                    '${280 - _controller.text.length}',
                    style: TextStyle(
                      color: _controller.text.length > 250 ? Colors.red : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _handlePost() async {
    setState(() => _isPosting = true);
    
    final mediaPaths = _selectedImages.map((file) => file.path).toList();
    final success = await context.read<TweetProvider>().postTweet(
      _controller.text,
      mediaPaths: mediaPaths,
      location: _currentLocation,
    );

    if (mounted) {
      setState(() => _isPosting = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tweet posted successfully!')),
        );
      }
    }
  }
}
