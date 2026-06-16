import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sportsync/features/booking/providers/booking_providers.dart';

const _primary = Color(0xFF005F02);
const _slate100 = Color(0xFFF1F5F9);
const _slate400 = Color(0xFF94A3B8);

class ConfirmationView extends ConsumerWidget {
  const ConfirmationView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final court = ref.watch(selectedCourtProvider)!;
    final method = ref.watch(paymentMethodProvider);
    final refCode = ref.watch(bookingRefCodeProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final selectedSlots = ref.watch(selectedSlotsProvider);
    final total = ref.watch(totalPriceProvider);
    final userName = ref.watch(userNameProvider);
    final userEmail = ref.watch(userEmailProvider);
    final userPhone = ref.watch(userPhoneProvider);
    final isGcash = method == BookingPaymentMethod.gcash;

    return Scaffold(
      backgroundColor: const Color(0xFFFCFCF9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 56, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo + ref code header
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(color: _primary, borderRadius: BorderRadius.circular(7)),
                  child: const Icon(Icons.bolt, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 8),
                const Text(
                  'SPORTSYNC',
                  style: TextStyle(color: _primary, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: -0.3),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Reference Code', style: TextStyle(color: _slate400, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1)),
                    Text(refCode, style: const TextStyle(color: _primary, fontSize: 13, fontWeight: FontWeight.w900)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(color: Color(0xFFE2E8F0)),
            const SizedBox(height: 20),

            // Title
            Text(
              isGcash ? 'Booking Confirmation.' : 'Reservation Confirmation.',
              style: const TextStyle(color: _primary, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5, height: 1.1),
            ),
            const SizedBox(height: 6),
            Text(
              isGcash
                  ? 'A copy of this receipt has been sent to your email.'
                  : 'Your slot is reserved. Please pay at the facility upon arrival.',
              style: const TextStyle(color: _slate400, fontSize: 12, fontWeight: FontWeight.w600, height: 1.4),
            ),
            const SizedBox(height: 24),

            // Info grid
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _slate100),
              ),
              child: Column(
                children: [
                  _InfoRow(label: 'Venue', value: court.name),
                  const Divider(height: 20, color: Color(0xFFE2E8F0)),
                  _InfoRow(
                    label: 'Date & Time',
                    value: '${DateFormat('EEE, MMM d').format(selectedDate)} • ${selectedSlots.length} slot${selectedSlots.length > 1 ? 's' : ''}',
                  ),
                  const Divider(height: 20, color: Color(0xFFE2E8F0)),
                  _InfoRow(label: 'Booked By', value: userName.isEmpty ? 'Guest' : userName),
                  if (userEmail.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(userEmail, style: const TextStyle(color: _slate400, fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  if (userPhone.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(userPhone, style: const TextStyle(color: _slate400, fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  const Divider(height: 20, color: Color(0xFFE2E8F0)),
                  _InfoRow(
                    label: isGcash ? 'Amount Paid' : 'Amount Due',
                    value: '₱$total.00',
                    valueLarge: true,
                  ),
                  const Divider(height: 20, color: Color(0xFFE2E8F0)),
                  _InfoRow(label: 'Payment Method', value: isGcash ? 'GCash' : 'Cash — Pay at Court'),
                  const Divider(height: 20, color: Color(0xFFE2E8F0)),
                  _InfoRow(
                    label: 'Status',
                    value: isGcash ? 'Pending Verification' : 'Reserved',
                    valueColor: isGcash ? const Color(0xFFD97706) : const Color(0xFF2563EB),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Print not available on mobile')),
                    ),
                    icon: const Icon(Icons.print_outlined, size: 16),
                    label: const Text('PRINT'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _slate400,
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(selectedCourtProvider.notifier).state = null;
                      ref.read(bookingStepProvider.notifier).state = BookingStep.details;
                      ref.read(selectedSlotsProvider.notifier).state = [];
                      ref.read(paymentMethodProvider.notifier).state = null;
                      ref.read(bookingRefCodeProvider.notifier).state = '';
                      context.go('/home');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 4,
                      shadowColor: _primary.withValues(alpha: 0.35),
                      textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
                    ),
                    child: const Text('BACK TO HOME'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.valueColor, this.valueLarge = false});
  final String label, value;
  final Color? valueColor;
  final bool valueLarge;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: _slate400, fontSize: 12, fontWeight: FontWeight.w700)),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: valueColor ?? _primary,
              fontSize: valueLarge ? 20 : 13,
              fontWeight: FontWeight.w900,
              letterSpacing: valueLarge ? -0.5 : 0,
            ),
          ),
        ),
      ],
    );
  }
}
