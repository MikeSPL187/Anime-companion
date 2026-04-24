import '../enums/enums.dart';
import '../models/library_entry.dart';
import '../models/library_presentation_snapshot.dart';

abstract interface class LibraryRepository {
  Stream<List<LibraryEntry>> watchAll();

  Stream<List<LibraryEntry>> watchByStatus(LibraryStatus status);

  Future<LibraryEntry?> getByAnimeId(String animeId);

  Future<void> setStatus(
    String animeId,
    LibraryStatus status, {
    LibraryPresentationSnapshot? snapshot,
  });

  Future<void> toggleFavorite(
    String animeId, {
    LibraryPresentationSnapshot? snapshot,
  });

  Future<void> removeFromLibrary(String animeId);

  Future<void> updateNote(String animeId, String? note);
}
