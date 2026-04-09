import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AnimePosterImage extends StatelessWidget {
  const AnimePosterImage({
    this.imageUrl,
    this.semanticLabel,
    this.showErrorState = false,
    super.key,
  });

  final String? imageUrl;
  final String? semanticLabel;
  final bool showErrorState;

  @override
  Widget build(BuildContext context) {
    final resolvedImageUrl = imageUrl;

    return Semantics(
      label: semanticLabel,
      image: true,
      child: AspectRatio(
        aspectRatio: 2 / 3,
        child:
            showErrorState ||
                resolvedImageUrl == null ||
                resolvedImageUrl.isEmpty
            ? const _PosterError()
            : ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: resolvedImageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const _PosterSkeleton(),
                  errorWidget: (context, url, error) => const _PosterError(),
                ),
              ),
      ),
    );
  }
}

class _PosterSkeleton extends StatelessWidget {
  const _PosterSkeleton();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _PosterError extends StatelessWidget {
  const _PosterError();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.movie_creation_outlined,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}
