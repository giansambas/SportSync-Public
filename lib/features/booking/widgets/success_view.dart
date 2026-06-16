import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sportsync/features/booking/providers/booking_providers.dart';

const _primary = Color(0xFF005F02);
const _slate50 = Color(0xFFF8FAFC);
const _slate400 = Color(0xFF94A3B8);

class SuccessView extends ConsumerWidget {
  const SuccessView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final court = ref.watch(selectedCourtProvider)!;
    final method = ref.watch(paymentMethodProvider);
    final refCode = ref.watch(bookingRefCodeProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final isGcash = method == BookingPaymentMethod.gcash;

    return Scaffold(
      backgroundColor: const Color(0xFFFCFCF9),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Green top stripe
            Container(height: 6, color: _primary),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 40),
              child: Column(
                children: [
                  // Checkmark circle
                  Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(color: _slate50, shape: BoxShape.circle),
                    child: const Icon(Icons.check_circle_outline, color: _primary, size: 52),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isGcash ? 'SUCCESS!' : 'RESERVED!',
                    style: const TextStyle(
                      color: _primary,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isGcash
                        ? 'Your booking at ${court.name} has been processed successfully.'
                        : 'Your slot at ${court.name} has been reserved. Pay at the front desk on arrival.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: _slate400, fontSize: 13, fontWeight: FontWeight.w600, height: 1.5),
                  ),
                  const SizedBox(height: 32),

                  // Status card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _slate50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        _StatusRow(label: 'Reference', value: refCode, valueColor: _primary),
                        const Divider(height: 20, color: Color(0xFFE2E8F0)),
                        _StatusRow(
                          label: 'Payment',
                          value: isGcash ? 'GCash' : 'Pay at Court',
                          valueColor: _primary,
                        ),
                        const Divider(height: 20, color: Color(0xFFE2E8F0)),
                        _StatusRow(
                          label: 'Status',
                          value: isGcash ? 'Pending Verification' : 'Reserved — Pay on Arrival',
                          valueColor: isGcash ? const Color(0xFFD97706) : const Color(0xFF2563EB),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Add to Calendar
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _openGoogleCalendar(court.name, court.location, selectedDate, refCode),
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: const Text('ADD TO CALENDAR'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _primary,
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // View Confirmation
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => ref.read(bookingStepProvider.notifier).state = BookingStep.confirmation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 4,
                        shadowColor: _primary.withValues(alpha: 0.35),
                        textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
                      ),
                      child: const Text('VIEW CONFIRMATION'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openGoogleCalendar(String courtName, String location, DateTime date, String refCode) async {
    final dateStr = DateFormat('yyyyMMdd').format(date);
    final title = Uri.encodeComponent('Court Booking – $courtName');
    final details = Uri.encodeComponent('Ref: $refCode');
    final loc = Uri.encodeComponent(location);
    final uri = Uri.parse(
      'https://calendar.google.com/calendar/render?action=TEMPLATE'
      '&text=$title&dates=$dateStr/$dateStr&details=$details&location=$loc',
    );
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.value, required this.valueColor});
  final String label, value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: _slate400, fontSize: 12, fontWeight: FontWeight.w700)),
        Text(value, style: TextStyle(color: valueColor, fontSize: 13, fontWeight: FontWeight.w900)),
      ],
    );
  }
}
