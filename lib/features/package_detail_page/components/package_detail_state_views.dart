import 'package:actpod_web/features/package_detail_page/components/package_detail_style.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PackageDetailLoading extends StatelessWidget {
  const PackageDetailLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF8F8F8),
      body: Center(
        child: CircularProgressIndicator(
          color: packageAccent,
          strokeWidth: 2,
        ),
      ),
    );
  }
}

class PackageDetailError extends StatelessWidget {
  final String? message;

  const PackageDetailError({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: packageAccent,
                size: 42,
              ),
              const SizedBox(height: 12),
              Text(
                message?.isNotEmpty == true ? message! : "找不到套裝資訊",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => context.go("/explore"),
                child: const Text("回探索頁"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
