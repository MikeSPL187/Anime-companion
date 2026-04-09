import '../models/library_presentation_snapshot.dart';

abstract interface class LibraryPresentationSnapshotRepository {
  Stream<Map<String, LibraryPresentationSnapshot>> watchAll();

  Stream<LibraryPresentationSnapshot?> watchByAnimeId(String animeId);

  Future<LibraryPresentationSnapshot?> getByAnimeId(String animeId);

  Future<void> saveSnapshot(LibraryPresentationSnapshot snapshot);

  Future<void> removeSnapshot(String animeId);
}
