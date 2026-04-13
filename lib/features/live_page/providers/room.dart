import 'package:actpod_web/features/live_page/dto/live_room.dart';
import 'package:actpod_web/features/live_page/dto/member.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final roomInfoProvider = StateProvider<LiveRoomDto?>((ref) => null);
final roomMembersProvider = StateProvider<List<LiveRoomMemberDto>>((ref) => []);