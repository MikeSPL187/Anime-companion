import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_provider.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/aniliberty_catalog_remote_data_source.dart';
import '../repositories/aniliberty_catalog_repository.dart';

final catalogRemoteDataSourceProvider = Provider<CatalogRemoteDataSource>((
  ref,
) {
  return AniLibertyCatalogRemoteDataSource(ref.watch(dioProvider));
});

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return AniLibertyCatalogRepository(
    ref.watch(catalogRemoteDataSourceProvider),
  );
});
