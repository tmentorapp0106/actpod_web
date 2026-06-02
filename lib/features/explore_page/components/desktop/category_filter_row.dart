import 'package:actpod_web/features/explore_page/screens/desktop.dart';
import 'package:flutter/material.dart';

class CategoryFilterRow extends StatelessWidget {
  const CategoryFilterRow();

  @override
  Widget build(BuildContext context) {
    final items = [
      CategoryItem(
        title: "生活日常",
        icon: Icons.connect_without_contact_rounded,
      ),
      CategoryItem(
        title: "日文",
        icon: Icons.translate_rounded,
      ),
      CategoryItem(
        title: "廣播劇",
        icon: Icons.tv_rounded,
      ),
      CategoryItem(
        title: "BL",
        icon: Icons.transgender_rounded,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "空間列表",
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 18,),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final item = items[index];

              return _CategoryCard(
                title: item.title,
                icon: item.icon,
                selected: index == 0,
                onTap: () {
                  // TODO: filter by category
                },
              );
            },
          ),
        )
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const double size = 80;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? const Color(0xFFFFBC1F).withOpacity(0.45)
                  : const Color(0xFFF1F1F1),
              width: selected ? 1.4 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.055),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 30,
                color: selected ? const Color(0xFFFFBC1F) : Colors.black87,
              ),
              const SizedBox(height: 2),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
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