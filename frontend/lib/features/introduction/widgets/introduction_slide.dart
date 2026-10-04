import 'package:flutter/material.dart';

class IntroductionSlide extends StatelessWidget {
  final String imageAsset;
  final String title;
  final String description;

  const IntroductionSlide({
    super.key,
    required this.imageAsset,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                imageAsset,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5EF),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.image_outlined,
                      size: 80,
                      color: Color(0xFF0B5D3B),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 32),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w700,
              color: Color(0xFF17201B),
            ),
          ),

          const SizedBox(height: 14),

          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Color(0xFF68736D),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}