import 'package:flutter_riverpod/legacy.dart';
import 'package:quick_share_app/dto/short_dto.dart';

final shortsProvider = StateProvider.autoDispose<List<ShowShortDto>?>((ref) => null);