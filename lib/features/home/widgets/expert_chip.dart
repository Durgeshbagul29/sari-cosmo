import 'package:flutter/material.dart';
import 'package:saris_cosmo_center/core/theme/app_theme.dart';
import 'package:saris_cosmo_center/core/widgets/common_widgets.dart';
import 'package:saris_cosmo_center/core/models/models.dart';
import 'package:saris_cosmo_center/features/appointments/screens/appointments_screen.dart';
import 'package:saris_cosmo_center/features/home/widgets/product_card.dart';

class ExpertChip extends StatelessWidget {
  final Expert expert;
  const ExpertChip({super.key, required this.expert});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => BookingSheet(expert: expert),
        );
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 16),
        child: Column(children: [
          Stack(alignment: Alignment.bottomRight, children: [
            expert.imageUrl.isEmpty
                ? Container(
                    height: 76,
                    width: 76,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 40,
                      color: AppTheme.primary,
                    ),
                  )
                : NetworkImageWidget(
                    url: expert.imageUrl,
                    height: 76,
                    width: 76,
                    borderRadius: BorderRadius.circular(38)),
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  shape: BoxShape.circle),
              child: const Icon(Icons.verified_rounded,
                  color: AppTheme.primary, size: 16),
            ),
          ]),
          const SizedBox(height: 8),
          Text(expert.name.split(' ').take(2).join(' '),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          Text(expert.specialization,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, color: AppTheme.textLight)),
        ]),
      ),
    );
  }
}

class ExpertChipShimmer extends StatelessWidget {
  const ExpertChipShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: const [
          ShimmerWidget(
            width: 76,
            height: 76,
            borderRadius: BorderRadius.all(Radius.circular(38)),
          ),
          SizedBox(height: 12),
          ShimmerWidget(
            width: 70,
            height: 12,
            borderRadius: BorderRadius.all(Radius.circular(3)),
          ),
          SizedBox(height: 6),
          ShimmerWidget(
            width: 50,
            height: 10,
            borderRadius: BorderRadius.all(Radius.circular(3)),
          ),
        ],
      ),
    );
  }
}
