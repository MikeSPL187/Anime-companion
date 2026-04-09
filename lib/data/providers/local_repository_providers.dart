import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database_provider.dart';
import '../../domain/repositories/library_presentation_snapshot_repository.dart';
import '../../domain/repositories/library_repository.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/repositories/search_history_repository.dart';
import '../repositories/drift_library_presentation_snapshot_repository.dart';
import '../repositories/drift_library_repository.dart';
import '../repositories/drift_progress_repository.dart';
import '../repositories/drift_search_history_repository.dart';

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  return DriftLibraryRepository(ref.watch(appDatabaseProvider));
});

final libraryPresentationSnapshotRepositoryProvider =
    Provider<LibraryPresentationSnapshotRepository>((ref) {
      return DriftLibraryPresentationSnapshotRepository(
        ref.watch(appDatabaseProvider),
      );
    });

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return DriftProgressRepository(ref.watch(appDatabaseProvider));
});

final searchHistoryRepositoryProvider = Provider<SearchHistoryRepository>((
  ref,
) {
  return DriftSearchHistoryRepository(ref.watch(appDatabaseProvider));
});
