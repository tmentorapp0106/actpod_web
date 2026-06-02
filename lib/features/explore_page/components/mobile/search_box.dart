import 'package:flutter/material.dart';

class SearchBox extends StatelessWidget {
  const SearchBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: Row(
        children: const [
          Icon(
            Icons.search_rounded,
            color: Colors.grey,
            size: 22,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "搜尋節目、單集、創作者",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}