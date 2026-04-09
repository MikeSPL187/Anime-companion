import '../enums/enums.dart';
import '../models/library_entry.dart';

abstract interface class LibraryRepository {
  Stream<List<LibraryEntry>> watchAll();

  Stream<List<LibraryEntry>> watchByStatus(LibraryStatus status);

  Future<LibraryEntry?> getByAnimeId(String animeId);

  Future<void> setStatus(String animeId, LibraryStatus status);

  Future<void> toggleFavorite(String animeId);

  Future<void> removeFromLibrary(String animeId);

  Future<void> updateNote(String animeId, String? note);
}
