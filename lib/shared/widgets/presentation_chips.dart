import 'package:flutter/material.dart';

import '../../domain/enums/enums.dart';
import '../utils/anime_labels.dart';

class AppInfoChip extends StatelessWidget {
  const AppInfoChip({required this.label, this.icon, super.key});

  final String label;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: icon,
      label: Text(label),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }
}

class LibraryStatusChip extends StatelessWidget {
  const LibraryStatusChip({
    required this.status,
    this.isFavorite = false,
    super.key,
  });

  final LibraryStatus status;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    return AppInfoChip(
      label: libraryStatusLabel(status),
      icon: isFavorite ? const Icon(Icons.favorite, size: 16) : null,
    );
  }
}

class FavoriteInfoChip extends StatelessWidget {
  const FavoriteInfoChip({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppInfoChip(
      label: 'Избранное',
      icon: Icon(Icons.favorite, size: 16),
    );
  }
}
