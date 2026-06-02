import 'package:flutter/material.dart';

class SpaceCategoryList extends StatelessWidget {
  const SpaceCategoryList();

  @override
  Widget build(BuildContext context) {
    final items = [
      _CategoryItem(title: "生活日常", icon: Icons.wifi_tethering_rounded),
      _CategoryItem(title: "日文", icon: Icons.translate_rounded),
      _CategoryItem(title: "廣播劇", icon: Icons.tv_rounded),
      _CategoryItem(title: "BL", icon: Icons.transgender_rounded),
      _CategoryItem(title: "廣播劇", icon: Icons.tv_rounded),
      _CategoryItem(title: "BL", icon: Icons.transgender_rounded),
      _CategoryItem(title: "廣播劇", icon: Icons.tv_rounded),
      _CategoryItem(title: "BL", icon: Icons.transgender_rounded),
      _CategoryItem(title: "廣播劇", icon: Icons.tv_rounded),
      _CategoryItem(title: "BL", icon: Icons.transgender_rounded),
    ];

    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];

          return _SpaceCategoryCard(
            title: item.title,
            icon: item.icon,
            selected: index == 0,
            onTap: () {},
          );
        },
      ),
    );
  }
}

class _CategoryItem {
  final String title;
  final IconData icon;

  _CategoryItem({
    required this.title,
    required this.icon,
  });
}

class _SpaceCategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SpaceCategoryCard({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const double size = 70;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? const Color(0xFFFFBC1F)
                  : const Color(0xFFEDEDED),
              width: selected ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.045),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 26,
                color: selected ? const Color(0xFFFFBC1F) : Colors.black87,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}