import 'package:actpod_web/components/avatar.dart';
import 'package:actpod_web/components/podcoin.dart';
import 'package:actpod_web/dto/package_dto.dart';
import 'package:flutter/material.dart';

class PackageCard extends StatelessWidget {
  final PackageInfoItem package;
  final bool compact;

  const PackageCard({
    super.key,
    required this.package,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final coverSize = compact ? 92.0 : 126.0;

    return Container(
      constraints: BoxConstraints(
        minHeight: compact ? 132 : 156,
      ),
      padding: EdgeInsets.all(compact ? 10 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEDEDED)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Image.network(
              package.packageImageUrl,
              width: coverSize,
              height: coverSize,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: compact ? 10 : 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const _PackageBadge(),
                      const SizedBox(width: 6),
                      Expanded(
                        child: SelectionArea(
                          child: Text(
                            package.packageName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: compact ? 16 : 20,
                              height: 1.15,
                              fontWeight: FontWeight.w900,
                            ),
                          )
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right,
                        color: Color(0xFF8E8E8E),
                        size: 22,
                      ),
                    ],
                  ),
                  SizedBox(height: compact ? 4 : 6),
                  Row(
                    children: [
                      Avatar(null, package.avatarUrl, compact ? 14 : 18),
                      const SizedBox(width: 5),
                      Expanded(
                        child: SelectionArea(
                          child: Text(
                            package.nickname,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: compact ? 11 : 13,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: compact ? 6 : 8),
                  // Wrap(
                  //   crossAxisAlignment: WrapCrossAlignment.center,
                  //   spacing: compact ? 6 : 10,
                  //   runSpacing: 4,
                  //   children: [
                  //     _MetaPill(text: "共 ${package.episodeCount} 集"),
                  //     _MetaPill(text: "總長約 ${package.totalMinutes} 分鐘"),
                  //     _PriceLabel(podcoins: package.podcoins),
                  //   ],
                  // ),
                  SizedBox(height: compact ? 6 : 10),
                  SelectionArea(
                    child: Text(
                      package.packageDescription,
                      maxLines: compact ? 2 : 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: compact ? 11 : 13,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ),
                  SizedBox(height: compact ? 6 : 10),
                  _TagPill(text: package.spaceName)
                  // Wrap(
                  //   spacing: 6,
                  //   runSpacing: 6,
                  //   children: package.tags.map((tag) {
                  //     return _TagPill(text: tag);
                  //   }).toList(),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PackageBadge extends StatelessWidget {
  const _PackageBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFFBC1F),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const SelectableText(
        "套裝",
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          height: 1,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final String text;

  const _MetaPill({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: SelectableText(
        text,
        style: const TextStyle(
          color: Color(0xFF3F3F3F),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _PriceLabel extends StatelessWidget {
  final int podcoins;

  const _PriceLabel({
    required this.podcoins,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SelectableText(
          podcoins.toString(),
          style: const TextStyle(
            color: Color(0xFFFF9900),
            fontSize: 16,
            height: 1,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 3),
        PodCoin(size: 14),
        const SizedBox(width: 2),
        const SelectableText(
          "Podcoins",
          style: TextStyle(
            color: Colors.black54,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _TagPill extends StatelessWidget {
  final String text;

  const _TagPill({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: SelectableText(
        text,
        style: const TextStyle(
          color: Color(0xFF555555),
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
