import 'package:web/web.dart' as web;

void submitNewebPayForm({
  required String gatewayUrl,
  required String merchantID,
  required String tradeInfo,
  required String tradeSha,
  required String version,
}) {
  final form = web.HTMLFormElement()
    ..method = 'POST'
    ..action = gatewayUrl;

  void addInput(String name, String value) {
    final input = web.HTMLInputElement()
      ..type = 'hidden'
      ..name = name
      ..value = value;
    form.appendChild(input);
  }

  addInput('MerchantID', merchantID);
  addInput('TradeInfo', tradeInfo);
  addInput('TradeSha', tradeSha);
  addInput('Version', version);

  final body = web.document.body;
  if (body == null) {
    throw StateError('Cannot submit NewebPay form without a document body.');
  }

  body.appendChild(form);
  form.submit();
}
