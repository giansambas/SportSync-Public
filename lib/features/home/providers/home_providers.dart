import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportsync/core/models/court.dart';
import 'package:sportsync/features/home/data/sample_courts.dart';

/// `null` means All sports.
final homeFilterProvider = StateProvider<CourtType?>((ref) => null);

enum CourtSortMode {
  defaultOrder,
  price,
  courts,
  rating,
}

final homeSortProvider = StateProvider<CourtSortMode>(
  (ref) => CourtSortMode.defaultOrder,
);

final homeSearchQueryProvider = StateProvider<String>((ref) => '');

/// Static list for now; swap for Firestore stream later.
final courtsListProvider = Provider<List<Court>>((ref) => sampleCourts);

final filteredCourtsProvider = Provider<List<Court>>((ref) {
  final courts = ref.watch(courtsListProvider);
  final filter = ref.watch(homeFilterProvider);
  final sort = ref.watch(homeSortProvider);
  final query = ref.watch(homeSearchQueryProvider).trim().toLowerCase();

  var list = List<Court>.from(courts);

  if (filter != null) {
    list = list.where((c) => c.type == filter).toList();
  }

  if (query.isNotEmpty) {
    list = list.where((c) {
      final n = c.name.toLowerCase();
      final loc = c.location.toLowerCase();
      return n.contains(query) || loc.contains(query);
    }).toList();
  }

  switch (sort) {
    case CourtSortMode.defaultOrder:
      break;
    case CourtSortMode.price:
      list.sort((a, b) => a.price.compareTo(b.price));
      break;
    case CourtSortMode.courts:
      list.sort((a, b) => b.numberOfCourts.compareTo(a.numberOfCourts));
      break;
    case CourtSortMode.rating:
      list.sort((a, b) => b.rating.compareTo(a.rating));
      break;
  }

  return list;
});
