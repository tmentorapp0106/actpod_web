import 'dart:io';

import 'package:flutter_riverpod/legacy.dart';
import 'package:quick_share_app/dto/user_info_dto.dart';

final userInfoProvider = StateProvider.autoDispose<UserInfoDto?>((ref) => null);
final unionCodeProvider = StateProvider.autoDispose<String?>((ref) => null);