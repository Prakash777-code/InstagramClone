import 'package:flutter/material.dart';

class NotificationBanner extends StatefulWidget {
  final String title;
  final String body;
  const NotificationBanner({
    super.key,
    required this.title,
    required this.body,
  });

  @override
  State<NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<NotificationBanner> {
  final String title = 'New Like';
  final String body = 'Ayaan liked your post.';

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundColor: Colors.pink,
                child: Icon(Icons.favorite, color: Colors.white),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.body,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
