import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sportsync/core/models/court.dart';
import 'package:sportsync/core/theme/app_colors.dart';
import 'package:sportsync/core/theme/app_radius.dart';
import 'package:sportsync/core/theme/app_shadows.dart';
import 'package:sportsync/core/theme/app_text_styles.dart';
import 'package:sportsync/features/booking/providers/booking_providers.dart';
import 'package:sportsync/features/courts/widgets/court_card.dart';
import 'package:sportsync/features/home/data/sample_courts.dart';
import 'package:sportsync/features/home/providers/home_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courts = ref.watch(filteredCourtsProvider);

    return CustomScrollView(
      slivers: [
        // Hero + How It Works card composed in a single sliver Stack so the
        // card cleanly sits ON TOP of the hero image (no sliver-clipping
        // edge cases from negative offsets).
        SliverToBoxAdapter(child: _HeroWithCard(ref: ref)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              children: [
                const _ExploreCta(),
                const SizedBox(height: 12),
                _FilterChipsCard(ref: ref),
                const SizedBox(height: 12),
                _SortRow(ref: ref),
              ],
            ),
          ),
        ),
        if (courts.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Text(
                  'NO VENUES MATCH YOUR SEARCH.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.microLabel(color: AppColors.slate400)
                      .copyWith(fontSize: 12, letterSpacing: 1.2),
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final court = courts[index];
                  final open = sampleOpenCourtsToday[court.id] ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: CourtCard(
                      court: court,
                      openToday: open,
                      onDetails: () =>
                          context.push('/home/courts/${court.id}'),
                      onBook: () {
                        ref.read(selectedCourtProvider.notifier).state = court;
                        ref.read(bookingStepProvider.notifier).state =
                            BookingStep.calendar;
                        context.push('/home/courts/${court.id}/book');
                      },
                    ),
                  );
                },
                childCount: courts.length,
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Hero + Card composite ──────────────────────────────────────────────────

/// Stacks the hero (520dp) and the How It Works card (~140dp), with the card
/// pulled UP into the hero by 48dp via a Positioned offset. Using one Stack
/// here (instead of two slivers with Transform.translate on the card)
/// guarantees the card paints AFTER the hero — i.e. on top — with zero
/// risk of sliver-bound clipping on the overlapping pixels.
class _HeroWithCard extends ConsumerWidget {
  const _HeroWithCard({required this.ref});
  final WidgetRef ref;

  static const double _heroHeight = 520;
  static const double _overlap = 48;
  // Approximate card height (icons + labels + padding). Generous so the
  // card never gets clipped at the bottom; the trailing whitespace blends
  // into the canvas below.
  static const double _cardArea = 152;

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    return SizedBox(
      height: _heroHeight + _cardArea - _overlap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Hero pinned to the top.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: _heroHeight,
            child: _HeroSection(ref: ref),
          ),
          // Card overlaps the bottom 48dp of the hero. Listed AFTER the hero
          // in this Stack → painted on top.
          Positioned(
            top: _heroHeight - _overlap,
            left: 16,
            right: 16,
            child: const _HowItWorksCard(),
          ),
        ],
      ),
    );
  }
}

// ─── Hero ───────────────────────────────────────────────────────────────────

class _HeroSection extends ConsumerWidget {
  const _HeroSection({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    return SizedBox(
      height: 520,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Layer 1 (bottom): court photo background.
          Image.asset(
            'assets/images/hero-bg.webp',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const ColoredBox(color: Color(0xFF001F12)),
          ),
          // Layer 2: dark green gradient on TOP of the photo so the brand
          // wash dominates and text stays readable. Matches the design's
          // `from-[#001F12] via-[#003D1A]/90 to-[#005F02]/80`.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xF2001F12), // 95%
                  Color(0xE5003D1A), // 90%
                  Color(0xCC005F02), // 80%
                ],
              ),
            ),
          ),
          // Layer 3: centered content
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 80, 20, 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'PLAN LESS\nPLAY MORE.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.displayBlack(color: AppColors.white)
                        .copyWith(fontSize: 48, height: 0.85),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Book premium Badminton, Pickleball, and Basketball courts in a few clicks.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _GlassSearchBar(ref: ref),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassSearchBar extends ConsumerWidget {
  const _GlassSearchBar({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(Icons.search,
              color: Colors.white.withValues(alpha: 0.6), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: (v) =>
                  widgetRef.read(homeSearchQueryProvider.notifier).state = v,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              decoration: InputDecoration(
                hintText: 'Search locations…',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
                border: InputBorder.none,
                isDense: true,
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.primary,
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              elevation: 6,
            ),
            child: Text('SEARCH',
                style: AppTextStyles.microLabel(color: AppColors.primary)
                    .copyWith(fontSize: 10, letterSpacing: 2)),
          ),
        ],
      ),
    );
  }
}

// ─── How It Works ───────────────────────────────────────────────────────────

class _HowItWorksCard extends StatelessWidget {
  const _HowItWorksCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl3),
        border: Border.all(color: AppColors.slate100),
        // Heavier shadow so the card visibly "lifts" off the dark hero.
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000), // ~20% black
            blurRadius: 30,
            offset: Offset(0, 12),
          ),
          BoxShadow(
            color: Color(0x14000000), // ~8% black, tighter
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _DottedConnectorPainter()),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(child: _StepItem(icon: Icons.sports_tennis, title: 'PICK A SPORT')),
              Expanded(child: _StepItem(icon: Icons.location_on, title: 'CHOOSE A COURT')),
              Expanded(child: _StepItem(icon: Icons.event_available, title: 'BOOK YOUR SLOT')),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primaryExtralight,
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.4,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _DottedConnectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Same wave as design: M 150 50 Q 350 10, 500 50 Q 650 90, 850 50
    // (but normalized to our card width/height)
    final yMid = size.height * 0.32;
    final dashWidth = 2.0;
    final dashGap = 6.0;
    final path = Path();
    path.moveTo(size.width * 0.18, yMid);
    path.quadraticBezierTo(
        size.width * 0.36, yMid - 18, size.width * 0.50, yMid);
    path.quadraticBezierTo(
        size.width * 0.64, yMid + 18, size.width * 0.82, yMid);

    // Dash the path
    final metrics = path.computeMetrics().toList();
    for (final m in metrics) {
      var distance = 0.0;
      while (distance < m.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          m.extractPath(distance, next.clamp(0, m.length)),
          paint,
        );
        distance = next + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Explore CTA strip ───────────────────────────────────────────────────────

class _ExploreCta extends StatelessWidget {
  const _ExploreCta();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryExtralight,
        borderRadius: BorderRadius.circular(AppRadius.xl3),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EXPLORE\nCOURTS',
                  style: AppTextStyles.headingBlack().copyWith(height: 1.0),
                ),
                const SizedBox(height: 8),
                Text(
                  'Premium courts, every skill level.',
                  style: TextStyle(
                    color: AppColors.primary.withValues(alpha: 0.6),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: AppShadows.cardSubtle,
            ),
            child: const Icon(Icons.arrow_downward,
                color: AppColors.primary, size: 22),
          ),
        ],
      ),
    );
  }
}

// ─── Filter chip card ────────────────────────────────────────────────────────

class _FilterChipsCard extends ConsumerWidget {
  const _FilterChipsCard({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    final current = widgetRef.watch(homeFilterProvider);
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        boxShadow: AppShadows.cardSubtle,
      ),
      child: Row(
        children: [
          _FilterChip(label: 'All', value: null, current: current, ref: widgetRef),
          _FilterChip(label: 'Badminton', value: CourtType.badminton, current: current, ref: widgetRef),
          _FilterChip(label: 'Pickleball', value: CourtType.pickleball, current: current, ref: widgetRef),
          _FilterChip(label: 'Basketball', value: CourtType.basketball, current: current, ref: widgetRef),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.value,
    required this.current,
    required this.ref,
  });
  final String label;
  final CourtType? value;
  final CourtType? current;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final selected = current == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(homeFilterProvider.notifier).state = value,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: selected ? AppShadows.cta : null,
          ),
          child: Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? AppColors.white : AppColors.slate400,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Sort row ────────────────────────────────────────────────────────────────

class _SortRow extends ConsumerWidget {
  const _SortRow({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    final mode = widgetRef.watch(homeSortProvider);
    // Drop the DEFAULT option; design only shows Price / Courts / Rating.
    final modes = const [
      CourtSortMode.price,
      CourtSortMode.courts,
      CourtSortMode.rating,
    ];

    return Row(
      children: [
        Text('SORT BY', style: AppTextStyles.microLabel(color: AppColors.slate300)),
        const Spacer(),
        for (final m in modes) ...[
          GestureDetector(
            onTap: () => widgetRef.read(homeSortProvider.notifier).state = m,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: mode == m ? AppColors.primary : AppColors.slate50,
                borderRadius: BorderRadius.circular(AppRadius.md - 2),
                border: Border.all(
                  color: mode == m ? AppColors.primary : AppColors.slate100,
                ),
                boxShadow: mode == m ? AppShadows.cardSubtle : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _label(m),
                    style: TextStyle(
                      color: mode == m ? AppColors.white : AppColors.slate400,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                    ),
                  ),
                  if (mode == m) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_downward,
                        color: AppColors.white, size: 8),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ],
    );
  }

  String _label(CourtSortMode m) {
    switch (m) {
      case CourtSortMode.defaultOrder:
        return 'DEFAULT';
      case CourtSortMode.price:
        return 'PRICE';
      case CourtSortMode.courts:
        return 'COURTS';
      case CourtSortMode.rating:
        return 'RATING';
    }
  }
}
