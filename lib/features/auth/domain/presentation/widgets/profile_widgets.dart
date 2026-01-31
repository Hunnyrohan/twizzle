// lib/presentation/widgets/profile_widgets.dart
import 'package:flutter/material.dart';
import 'package:twizzle/widgets/tweet_card.dart';
import 'dart:ui';
import '../../../domain/entities/tweet.dart'; // reuse your Tweet model


/* --------------------  EXPORT ALL  -------------------- */
export 'profile_widgets.dart'
    show ProfileHeaderParallax, ProfileBioCard, ProfileStatChips,
         ProfileCurvedTabs, ProfileTweetGrid;

/* ====================================================== */
/* 1.  PARALLAX HEADER  (cover + avatar overlap)        */
/* ====================================================== */
class ProfileHeaderParallax extends StatelessWidget {
  final VoidCallback onEdit;
  const ProfileHeaderParallax({Key? key, required this.onEdit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // parallax cover
        Image.network('https://source.unsplash.com/600x400/?abstract,gradient',
            fit: BoxFit.cover),
        // glass overlay
        Center(child: _avatarRow(context)),
      ],
    );
  }

  Widget _avatarRow(BuildContext context) {
    return FrostedGlass(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Stack(
              children: [
                const CircleAvatar(radius: 40, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=8')),
                Positioned(bottom: 0, right: 0,
                  child: Container(width: 16, height: 16,
                    decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2)))),
              ],
            ),
            const SizedBox(width: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Rohan', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                const Text('@rohan', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                ElevatedButton(onPressed: onEdit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0, minimumSize: const Size(0, 36),
                  ),
                  child: const Text('Edit Profile')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/* ====================================================== */
/* 2.  GLASS BIO CARD  (social links)                   */
/* ====================================================== */
class ProfileBioCard extends StatelessWidget {
  final VoidCallback onEdit;
  const ProfileBioCard({Key? key, required this.onEdit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FrostedGlass(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Bio', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                IconButton(onPressed: onEdit, icon: const Icon(Icons.edit, color: Colors.white70)),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Flutter dev | Twizzle enthusiast', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            Row(children: [
              Icon(Icons.location_on, size: 16, color: Colors.white70),
              const SizedBox(width: 4),
              Text('India', style: TextStyle(color: Colors.white70)),
              const SizedBox(width: 16),
              Icon(Icons.link, size: 16, color: Colors.white70),
              const SizedBox(width: 4),
              Text('github.com/rohan', style: TextStyle(color: Colors.white70)),
            ]),
          ],
        ),
      ),
    );
  }
}

/* ====================================================== */
/* 3.  ANIMATED STAT CHIPS  (tap to grow)               */
/* ====================================================== */
class ProfileStatChips extends StatelessWidget {
  final AnimationController controller;
  const ProfileStatChips({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _chip('Tweets', 42, Colors.blue),
        _chip('Following', 123, Colors.green),
        _chip('Followers', 1.2, Colors.pink),
      ],
    );
  }

  Widget _chip(String label, num count, Color color) {
    return GestureDetector(
      onTap: () => controller.forward(from: 0),
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, child) => Transform.scale(
          scale: 1 + controller.value * 0.1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: Column(
              children: [
                Text('$count', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
                Text(label, style: TextStyle(color: color.withOpacity(0.8), fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ====================================================== */
/* 4.  CURVED TAB BAR  (animated indicator)             */
/* ====================================================== */
class ProfileCurvedTabs extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const ProfileCurvedTabs({Key? key, required this.currentIndex, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(24)),
      child: Row(
        children: [
          _tab('Tweets', 0),
          _tab('Likes', 1),
          _tab('Media', 2),
        ],
      ),
    );
  }

  Widget _tab(String text, int index) {
    final isActive = index == currentIndex;
    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xff1DA1F2) : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/* ====================================================== */
/* 5.  TWEET GRID  (tablet 2-column)                    */
/* ====================================================== */
class ProfileTweetGrid extends StatelessWidget {
  final List<Tweet> tweets;
  final bool loading;
  final VoidCallback onAction;
  const ProfileTweetGrid({Key? key, required this.tweets, required this.loading, required this.onAction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tablet = MediaQuery.of(context).size.shortestSide >= 600;
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: tablet ? 2 : 1,
        childAspectRatio: tablet ? 1.6 : 1.2,
      ),
      itemCount: tweets.length + (loading ? 1 : 0),
      itemBuilder: (_, i) => i == tweets.length
          ? const Center(child: CircularProgressIndicator())
          : TweetCard(tweet: tweets[i], onAction: onAction),
    );
  }
}

/* ====================================================== */
/* 6.  GLASS HELPER  (reuse if you don't have it)       */
/* ====================================================== */
class FrostedGlass extends StatelessWidget {
  final Widget child;
  const FrostedGlass({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
        ),
        child: child,
      ),
    );
  }
}