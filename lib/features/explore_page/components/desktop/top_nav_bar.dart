import 'package:flutter/material.dart';

class TopNavBar extends StatelessWidget {
  const TopNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFEDEDED)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        children: [
          Row(
            children: [
              Image.asset("assets/images/actpod_logo_web.png",
                  height: 24, fit: BoxFit.fitHeight),
            ],
          ),
          const Spacer(),
          const Text(
            "精選 Podcast",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const Spacer(),
          const SizedBox(
            width: 280,
            height: 40,
          )
          // Container(
          //   width: 280,
          //   height: 40,
          //   decoration: BoxDecoration(
          //     color: const Color(0xFFF8F8F8),
          //     borderRadius: BorderRadius.circular(999),
          //     border: Border.all(color: const Color(0xFFEDEDED)),
          //   ),
          //   padding: const EdgeInsets.symmetric(horizontal: 14),
          //   child: Row(
          //     children: const [
          //       Icon(Icons.search, size: 18, color: Colors.grey),
          //       SizedBox(width: 8),
          //       Expanded(
          //         child: Text(
          //           "搜尋節目、單集、創作者",
          //           style: TextStyle(color: Colors.grey, fontSize: 13),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
