import 'package:flutter/material.dart';
import 'package:sportsync/core/models/court.dart';
import 'package:sportsync/core/theme/app_colors.dart';

/// Non-web fallback. The `Directions` button overlay (rendered by the parent
/// in court_detail_screen.dart) provides the primary action; this widget
/// just gives the area a sensible visual.
Widget buildCourtMap(Court court) {
  return Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFE8EFE6), Color(0xFFD4E2D1)],
      ),
    ),
    child: const Center(
      child: Icon(Icons.location_on, color: AppColors.primary, size: 32),
    ),
  );
}
