import 'package:actpod_web/dto/user_info_dto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userInfoProvider = StateProvider<UserInfoDto?>((ref) => null);
final userPodCoinsProvider = StateProvider<int>((ref) => 0);