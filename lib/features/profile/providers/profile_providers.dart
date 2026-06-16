import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportsync/features/profile/data/user_profile_repository.dart';

/// Streams the FirebaseAuth user state. Yields `null` when signed-out (the
/// app falls back to a "Guest" identity in those branches).
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Stable accessor for the current UID. Returns null when signed-out.
final currentUidProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).asData?.value?.uid;
});

/// User profile from Firestore (`users/{uid}`). Auto-creates an empty doc
/// the first time it's read.
final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return const Stream.empty();
  return ref.watch(userProfileRepositoryProvider).stream(uid);
});
