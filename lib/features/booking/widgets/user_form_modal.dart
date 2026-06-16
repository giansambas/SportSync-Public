import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sportsync/features/booking/providers/booking_providers.dart';

const _primary = Color(0xFF005F02);
const _slate400 = Color(0xFF94A3B8);

const _emailjsServiceId = 'service_s7c5i2j';
const _emailjsTemplateId = 'template_0g8xhgv';
const _emailjsPublicKey = 'qKw3YTXia-UqdC7Po';

void showUserFormModal(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => _UserFormDialog(ref: ref),
  );
}

class _UserFormDialog extends ConsumerStatefulWidget {
  const _UserFormDialog({required this.ref});
  final WidgetRef ref;

  @override
  ConsumerState<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends ConsumerState<_UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: ref.read(userNameProvider));
    _emailCtrl = TextEditingController(text: ref.read(userEmailProvider));
    _phoneCtrl = TextEditingController(text: ref.read(userPhoneProvider));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Details',
                style: TextStyle(color: _primary, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
              ),
              const SizedBox(height: 4),
              const Text(
                'Please provide your information for the receipt.',
                style: TextStyle(color: _slate400, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              _field(_nameCtrl, 'Full Name', 'John Doe', TextInputType.name),
              const SizedBox(height: 12),
              _field(_emailCtrl, 'Email Address', 'john@example.com', TextInputType.emailAddress),
              const SizedBox(height: 12),
              _field(_phoneCtrl, 'Phone Number', '+63 912 345 6789', TextInputType.phone),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _submitting ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('CANCEL', style: TextStyle(color: _slate400, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
                      ),
                      child: _submitting
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('COMPLETE'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, String hint, TextInputType type) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: _slate400, fontWeight: FontWeight.w700),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _primary, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();

    ref.read(userNameProvider.notifier).state = name;
    ref.read(userEmailProvider.notifier).state = email;
    ref.read(userPhoneProvider.notifier).state = phone;

    // Persist user data
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sportsync_user', jsonEncode({'name': name, 'email': email, 'phone': phone}));

    // Commit slots to booked
    final court = ref.read(selectedCourtProvider)!;
    final selectedSlots = ref.read(selectedSlotsProvider);
    final selectedDate = ref.read(selectedDateProvider);
    final refCode = ref.read(bookingRefCodeProvider);
    final paymentMethod = ref.read(paymentMethodProvider);
    final total = ref.read(totalPriceProvider);
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);

    final newBooked = selectedSlots.map<BookedSlot>((s) => (
      facilityId: court.id,
      date: dateStr,
      court: s.court,
      time: s.time,
    )).toList();

    ref.read(bookedSlotsProvider.notifier).state = [
      ...ref.read(bookedSlotsProvider),
      ...newBooked,
    ];

    // Send email via EmailJS REST API
    try {
      final slotsText = selectedSlots.map((s) => '${s.court}: ${s.time}').join(' | ');
      await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'service_id': _emailjsServiceId,
          'template_id': _emailjsTemplateId,
          'user_id': _emailjsPublicKey,
          'template_params': {
            'type': 'NEW COURT BOOKING',
            'heading_label': 'REFERENCE CODE',
            'heading_value': refCode,
            'detail_1_label': 'Court',
            'detail_1_value': court.name,
            'detail_2_label': 'Date',
            'detail_2_value': DateFormat('EEEE, MMMM d, yyyy').format(selectedDate),
            'detail_3_label': 'Time Slots',
            'detail_3_value': slotsText,
            'detail_4_label': 'Total',
            'detail_4_value': '₱$total.00',
            'detail_5_label': 'Payment',
            'detail_5_value': paymentMethod == BookingPaymentMethod.gcash ? 'GCash' : 'Pay at Court',
            'person_section_title': 'BOOKED BY',
            'user_name': name,
            'user_email': email,
            'user_phone': phone,
            'name': name,
            'email': email,
          },
        }),
      );
    } catch (_) {
      // Email failure is non-fatal — booking still completes
    }

    // Persist to Firestore (no-op when signed-out).
    try {
      await commitBooking(ref);
    } catch (_) {
      // Persistence failure is non-fatal — the user still sees Success.
    }

    if (mounted) {
      Navigator.pop(context);
      ref.read(bookingStepProvider.notifier).state = BookingStep.success;
    }
  }
}

/// Call once on app start to restore saved user details.
Future<void> loadSavedUser(WidgetRef ref) async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString('sportsync_user');
  if (raw != null) {
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      if (map['name'] != null) ref.read(userNameProvider.notifier).state = map['name'] as String;
      if (map['email'] != null) ref.read(userEmailProvider.notifier).state = map['email'] as String;
      if (map['phone'] != null) ref.read(userPhoneProvider.notifier).state = map['phone'] as String;
    } catch (_) {}
  }
}
