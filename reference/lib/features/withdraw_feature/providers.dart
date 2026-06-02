import 'package:flutter_riverpod/legacy.dart';
import 'package:quick_share_app/dto/withdraw_dto.dart';

final withdrawAgreementProvider = StateProvider<bool>((ref) => false);
final withdrawReadProvider = StateProvider<bool>((ref) => false);

final withdrawsProvider = StateProvider<List<WithdrawDto>>((ref) => []);

final emailTextProvider = StateProvider.autoDispose<String>((ref) => "");
final phoneTextProvider = StateProvider.autoDispose<String>((ref) => "");