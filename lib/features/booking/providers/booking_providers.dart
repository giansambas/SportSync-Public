import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportsync/core/models/court.dart';
import 'package:sportsync/features/bookings/data/bookings_repository.dart';
import 'package:sportsync/features/bookings/models/booking.dart' as model;
import 'package:sportsync/features/bookings/providers/bookings_providers.dart';

enum BookingStep { details, calendar, payment, gcash, success, confirmation }

enum BookingPaymentMethod { gcash, cash }

typedef SelectedSlot = ({String court, String time});
typedef BookedSlot = ({
  String facilityId,
  String date,
  String court,
  String time
});

final selectedCourtProvider = StateProvider<Court?>((ref) => null);

final bookingStepProvider =
    StateProvider<BookingStep>((ref) => BookingStep.details);

final selectedDateProvider =
    StateProvider<DateTime>((ref) => DateTime.now());

final selectedSlotsProvider =
    StateProvider<List<SelectedSlot>>((ref) => []);

final bookedSlotsProvider = StateProvider<List<BookedSlot>>((ref) {
  final today = _dateStr(DateTime.now());
  return [
    (facilityId: 'c1', date: today, court: 'Court 1', time: '9am - 10am'),
    (facilityId: 'c1', date: today, court: 'Court 2', time: '10am - 11am'),
    (facilityId: 'c2', date: today, court: 'Court 3', time: '2pm - 3pm'),
  ];
});

final paymentMethodProvider =
    StateProvider<BookingPaymentMethod?>((ref) => null);

final bookingRefCodeProvider = StateProvider<String>((ref) => '');

final userNameProvider = StateProvider<String>((ref) => '');
final userEmailProvider = StateProvider<String>((ref) => '');
final userPhoneProvider = StateProvider<String>((ref) => '');

final totalPriceProvider = Provider<int>((ref) {
  final court = ref.watch(selectedCourtProvider);
  final slots = ref.watch(selectedSlotsProvider);
  return (court?.price.toInt() ?? 0) * slots.length;
});

/// Generate a stable reference code for the in-flight booking. Idempotent —
/// only generates once per booking session (via `bookingRefCodeProvider`).
String generateRefCode(String courtId) {
  final suffix =
      (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString();
  return 'SS-${courtId.toUpperCase()}-$suffix';
}

/// Persists the in-flight booking. Always writes to the in-memory
/// `localBookingsProvider` so it shows up in My Bookings. Opportunistically
/// also writes to Firestore when a user is signed in. Both paths are
/// best-effort; if either throws, the user still progresses to Success.
Future<void> commitBooking(WidgetRef ref) async {
  final court = ref.read(selectedCourtProvider);
  final slots = ref.read(selectedSlotsProvider);
  final date = ref.read(selectedDateProvider);
  final method = ref.read(paymentMethodProvider);
  final refCode = ref.read(bookingRefCodeProvider);
  final total = ref.read(totalPriceProvider);
  final user = FirebaseAuth.instance.currentUser;

  if (court == null || slots.isEmpty || refCode.isEmpty) {
    return;
  }

  final booking = model.Booking(
    id: refCode, // human-friendly doc id
    userId: user?.uid ?? 'guest',
    courtId: court.id,
    courtName: court.name,
    courtType: court.type.label,
    date: date,
    slots: slots
        .map((s) => model.BookingSlot(court: s.court, time: s.time))
        .toList(),
    totalAmount: total,
    payment: method == BookingPaymentMethod.gcash
        ? model.BookingPayment.gcash
        : model.BookingPayment.cash,
    status: method == BookingPaymentMethod.gcash
        ? model.BookingStatus.pending
        : model.BookingStatus.cash,
    refCode: refCode,
    userName: ref.read(userNameProvider),
    userEmail: ref.read(userEmailProvider),
    userPhone: ref.read(userPhoneProvider),
    createdAt: DateTime.now(),
  );

  // Always write locally so the booking shows up regardless of auth state.
  ref.read(localBookingsProvider.notifier).add(booking);

  // Also persist to Firestore when signed in. Failure is non-fatal.
  if (user != null) {
    try {
      await ref.read(bookingsRepositoryProvider).create(booking);
    } catch (_) {
      // Firestore unavailable / rules reject — local copy still suffices.
    }
  }
}

String _dateStr(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
