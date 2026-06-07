import 'package:actpod_web/features/explore_page/providers.dart';
import 'package:flutter/material.dart';

class RecommendationSwitch extends StatelessWidget {
  final ExploreRecommendationMode selectedMode;
  final ValueChanged<ExploreRecommendationMode> onChanged;
  final double height;

  const RecommendationSwitch({
    super.key,
    required this.selectedMode,
    required this.onChanged,
    this.height = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SwitchItem(
              text: "推薦單集",
              selected: selectedMode == ExploreRecommendationMode.episode,
              onTap: () => onChanged(ExploreRecommendationMode.episode),
            ),
          ),
          Expanded(
            child: _SwitchItem(
              text: "精選套裝",
              selected: selectedMode == ExploreRecommendationMode.package,
              onTap: () => onChanged(ExploreRecommendationMode.package),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchItem extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _SwitchItem({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFFFBC1F) : Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Center(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black54,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
