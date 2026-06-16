import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sportsync/core/theme/app_colors.dart';
import 'package:sportsync/core/theme/app_radius.dart';
import 'package:sportsync/core/theme/app_shadows.dart';
import 'package:sportsync/core/theme/app_text_styles.dart';
import 'package:sportsync/features/booking/providers/booking_providers.dart';
import 'package:sportsync/features/booking/widgets/user_form_modal.dart';

/// Step 4 (alt) — GCash QR. Reached when payment method = GCash.
class GCashView extends ConsumerWidget {
  const GCashView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final court = ref.watch(selectedCourtProvider)!;
    final total = ref.watch(totalPriceProvider);
    final refCode = ref.watch(bookingRefCodeProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 32),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      ref.read(bookingStepProvider.notifier).state =
                          BookingStep.payment;
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          const Icon(Icons.chevron_left,
                              color: AppColors.slate400, size: 14),
                          const SizedBox(width: 4),
                          Text('CHANGE METHOD',
                              style: AppTextStyles.microLabel(
                                color: AppColors.slate400,
                              ).copyWith(fontSize: 10, letterSpacing: 1.6)),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    court.name.split(' ').take(2).join(' ').toUpperCase(),
                    style: AppTextStyles.microLabel(color: AppColors.primary)
                        .copyWith(fontSize: 10, letterSpacing: 1.6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppRadius.xl3),
                border: Border.all(color: AppColors.slate100),
                boxShadow: AppShadows.cardSubtle,
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.gcashBlue,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.smartphone,
                            color: AppColors.white, size: 12),
                        const SizedBox(width: 6),
                        Text(
                          'GCASH',
                          style:
                              AppTextStyles.microLabel(color: AppColors.white)
                                  .copyWith(fontSize: 11, letterSpacing: 1.6),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('SCAN TO PAY', style: AppTextStyles.headingBlack()),
                  const SizedBox(height: 4),
                  Text('₱$total.00', style: AppTextStyles.priceMega()),
                  const SizedBox(height: 16),
                  // QR
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.slate200,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.xl2),
                    ),
                    child: QrImageView(
                      data: 'sportsync://pay?ref=$refCode&amount=$total',
                      version: QrVersions.auto,
                      size: 180,
                      backgroundColor: AppColors.white,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: AppColors.primary,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('REFERENCE', style: AppTextStyles.eyebrow()),
                            Text(refCode,
                                style: AppTextStyles.eyebrow(
                                  color: AppColors.primary,
                                )),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('ACCOUNT', style: AppTextStyles.eyebrow()),
                            Text('SPORTSYNC DAVAO',
                                style: AppTextStyles.eyebrow(
                                  color: AppColors.primary,
                                )),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => showUserFormModal(context, ref),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.xl2),
                        ),
                      ),
                      child: Text("I'VE PAID — CONTINUE",
                          style: AppTextStyles.ctaLabel()),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      ref.read(bookingStepProvider.notifier).state =
                          BookingStep.payment;
                    },
                    child: Text('CHOOSE ANOTHER METHOD',
                        style: AppTextStyles.microLabel(
                          color: AppColors.slate400,
                        ).copyWith(fontSize: 10, letterSpacing: 1.6)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
