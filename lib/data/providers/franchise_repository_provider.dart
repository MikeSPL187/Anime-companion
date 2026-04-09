import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_provider.dart';
import '../../domain/repositories/franchise_repository.dart';
import '../datasources/aniliberty_franchise_remote_data_source.dart';
import '../repositories/aniliberty_franchise_repository.dart';

final franchiseRemoteDataSourceProvider = Provider<FranchiseRemoteDataSource>((
  ref,
) {
  return AniLibertyFranchiseRemoteDataSource(ref.watch(dioProvider));
});

final franchiseRepositoryProvider = Provider<FranchiseRepository>((ref) {
  return AniLibertyFranchiseRepository(
    ref.watch(franchiseRemoteDataSourceProvider),
  );
});
