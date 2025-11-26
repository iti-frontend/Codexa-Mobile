import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String image;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Updated CircleAvatar to handle both network and asset images
            _buildProfileImage(image),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.iconTheme.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.iconTheme.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      // It's a network image
      return CircleAvatar(
        radius: 30,
        backgroundColor: Colors.grey[300], // Background color while loading
        child: ClipOval(
          child: Image.network(
            imageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return _buildDefaultIcon();
            },
          ),
        ),
      );
    } else {
      // It's an asset image
      return CircleAvatar(
        radius: 30,
        backgroundImage: AssetImage(imageUrl),
        onBackgroundImageError: (exception, stackTrace) {
          print('Failed to load asset image: $exception');
        },
        child: _buildDefaultIcon(),
      );
    }
  }
  Widget _buildLoadingIndicator() {
    return const CircularProgressIndicator(
      strokeWidth: 2,
      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
    );
  }

  Widget _buildDefaultIcon() {
    return const Icon(
      Icons.person,
      color: Colors.white,
      size: 30,
    );
  }
}