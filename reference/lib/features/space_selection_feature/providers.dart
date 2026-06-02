import 'dart:io';

import 'package:flutter_riverpod/legacy.dart';
import 'package:quick_share_app/dto/space_dto.dart';


final boardImageProvider = StateProvider.autoDispose<File?>((ref) => null);
final applyLoadingProvider = StateProvider.autoDispose<bool>((ref) => false);

final spacesProvider = StateProvider<List<SpaceInfoDto>>((ref) => []);

final spaceSelectionPageStateProvider = StateProvider<String>((ref) => "selecting"); // "selecting", "space"
final spaceSelectionPageSelectedSpaceInfoProvider = StateProvider<SpaceInfoDto?>((ref) => null);