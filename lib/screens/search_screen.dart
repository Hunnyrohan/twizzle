import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7ECF0),

      body: SingleChildScrollView(
        child: Column(
          children: [

            // =====================
            // Top Search Bar Section
            // =====================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage("https://placehold.co/32x32"),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Search Twitter",
                    style: TextStyle(
                      color: Color(0xFF687684),
                      fontSize: 17,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.settings, color: Color(0xFF4C9EEB)),
                ],
              ),
            ),

            // =====================
            // "Trends for you" title
            // =====================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: Colors.white,
              child: const Text(
                "Trends for you",
                style: TextStyle(
                  color: Color(0xFF141619),
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // =====================
            // Figma box converted
            // =====================
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    "No new trends for you",
                    style: TextStyle(
                      color: Color(0xFF141619),
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "It seems like there’s not a lot to show you right now, "
                    "but you can see trends for other areas",
                    style: TextStyle(
                      color: Color(0xFF687684),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4C9EEB),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      "Change location",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 40),

            // ===============
            // Floating button
            // ===============
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 24),
                child: FloatingActionButton(
                  backgroundColor: const Color(0xFF4C9EEB),
                  onPressed: () {},
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
