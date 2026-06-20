import 'dart:typed_data';

import 'package:actpod_web/dto/package_dto.dart';
import 'package:actpod_web/features/package_detail_page/components/package_detail_style.dart';
import 'package:actpod_web/utils/link_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class PackageDescriptionSection extends StatelessWidget {
  final PackageInfoWithStoriesItem package;

  const PackageDescriptionSection({
    super.key,
    required this.package,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: "套裝介紹"),
        const SizedBox(height: 10),
        PackageDescriptionContent(
          description: package.packageDescription,
        ),
        // const SizedBox(height: 14),
        // PackageTags(package: package),
      ],
    );
  }
}

class PackageDescriptionContent extends StatelessWidget {
  final String description;

  const PackageDescriptionContent({
    super.key,
    required this.description,
  });

  static final RegExp _urlRegex = RegExp(r'https?:\/\/[^\s<>()]+');

  TextStyle get _descriptionStyle => const TextStyle(
        fontSize: 16,
        height: 1.7,
        fontWeight: FontWeight.w600,
      );

  @override
  Widget build(BuildContext context) {
    final segments = _descriptionSegments(description);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: segments.map((segment) {
        if (segment.isUrl) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: DescriptionImageOrLink(url: segment.value),
          );
        }

        return Text(
          segment.value,
          style: _descriptionStyle,
        );
      }).toList(),
    );
  }

  List<_DescriptionSegment> _descriptionSegments(String value) {
    final segments = <_DescriptionSegment>[];
    var start = 0;

    for (final match in _urlRegex.allMatches(value)) {
      final rawUrl = value.substring(match.start, match.end);
      final url = _trimTrailingUrlPunctuation(rawUrl);
      final trailing = rawUrl.substring(url.length);

      if (match.start > start) {
        segments
            .add(_DescriptionSegment.text(value.substring(start, match.start)));
      }

      segments.add(_DescriptionSegment.url(url));

      if (trailing.isNotEmpty) {
        segments.add(_DescriptionSegment.text(trailing));
      }

      start = match.end;
    }

    if (start < value.length) {
      segments.add(_DescriptionSegment.text(value.substring(start)));
    }

    return segments.where((segment) => segment.value.isNotEmpty).toList();
  }

  String _trimTrailingUrlPunctuation(String value) {
    return value.replaceFirst(RegExp(r'[,.!?;:，。！？；：]+$'), '');
  }
}

class DescriptionImageOrLink extends StatefulWidget {
  final String url;

  const DescriptionImageOrLink({
    super.key,
    required this.url,
  });

  @override
  State<DescriptionImageOrLink> createState() => _DescriptionImageOrLinkState();
}

class _DescriptionImageOrLinkState extends State<DescriptionImageOrLink> {
  late final Future<Uint8List?> _imageBytesFuture;

  @override
  void initState() {
    super.initState();
    _imageBytesFuture = _loadImageBytesIfImage(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldCheckAsImageUrl(widget.url)) {
      return DescriptionUrlLink(url: widget.url);
    }

    return FutureBuilder<Uint8List?>(
      future: _imageBytesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Container(
            width: double.infinity,
            height: 160,
            color: const Color(0xFFF4F4F4),
            alignment: Alignment.center,
            child: const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final imageBytes = snapshot.data;
        if (imageBytes == null) {
          return DescriptionUrlLink(url: widget.url);
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            imageBytes,
            errorBuilder: (context, error, stackTrace) {
              return DescriptionUrlLink(url: widget.url);
            },
          ),
        );
      },
    );
  }

  bool _shouldCheckAsImageUrl(String value) {
    final uri = Uri.tryParse(value);

    if (uri == null || !uri.hasAbsolutePath) {
      return false;
    }

    final path = uri.path.toLowerCase();
    final lastSegment = uri.pathSegments.isEmpty ? "" : uri.pathSegments.last;
    final hasFileExtension = lastSegment.contains(".");

    if (path.contains("/image/")) {
      return true;
    }

    if (!hasFileExtension) {
      return true;
    }

    return RegExp(r'\.(png|jpe?g|gif|webp|bmp|avif)$').hasMatch(path);
  }

  Future<Uint8List?> _loadImageBytesIfImage(String url) async {
    try {
      final response = await Dio().get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = Uint8List.fromList(response.data ?? const []);

      if (_isImageBytes(bytes)) {
        return bytes;
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  bool _isImageBytes(Uint8List bytes) {
    if (bytes.length < 12) {
      return false;
    }

    final isJpeg = bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF;
    final isPng = bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A;
    final isGif = bytes[0] == 0x47 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x38;
    final isWebp =
        _matchesAscii(bytes, 0, "RIFF") && _matchesAscii(bytes, 8, "WEBP");
    final isBmp = bytes[0] == 0x42 && bytes[1] == 0x4D;
    final isAvif = _matchesAscii(bytes, 4, "ftyp") &&
        (_matchesAscii(bytes, 8, "avif") || _matchesAscii(bytes, 8, "avis"));

    return isJpeg || isPng || isGif || isWebp || isBmp || isAvif;
  }

  bool _matchesAscii(Uint8List bytes, int offset, String value) {
    if (bytes.length < offset + value.length) {
      return false;
    }

    for (var i = 0; i < value.length; i++) {
      if (bytes[offset + i] != value.codeUnitAt(i)) {
        return false;
      }
    }

    return true;
  }
}

class DescriptionUrlLink extends StatelessWidget {
  final String url;

  const DescriptionUrlLink({
    super.key,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => LinkUtils.onOpenDescriptionLinkString(url),
      child: Text(
        url,
        style: const TextStyle(
          color: packageAccent,
          fontSize: 16,
          height: 1.5,
          fontWeight: FontWeight.w700,
          decoration: TextDecoration.underline,
          decorationColor: packageAccent,
        ),
      ),
    );
  }
}

class _DescriptionSegment {
  final String value;
  final bool isUrl;

  const _DescriptionSegment._({
    required this.value,
    required this.isUrl,
  });

  factory _DescriptionSegment.text(String value) {
    return _DescriptionSegment._(value: value, isUrl: false);
  }

  factory _DescriptionSegment.url(String value) {
    return _DescriptionSegment._(value: value, isUrl: true);
  }
}
