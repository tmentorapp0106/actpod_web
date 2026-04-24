
import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:actpod_web/api_manager/purchase_dto/purchase_web_podcoin.dart';
import 'package:actpod_web/api_manager/purchase_system_api_manager.dart';
import 'package:actpod_web/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import 'js_bridge.dart';

class TapPayCheckoutPage extends StatefulWidget {
  const TapPayCheckoutPage({super.key});

  @override
  State<TapPayCheckoutPage> createState() => _TapPayCheckoutPageState();
}

class _TapPayCheckoutPageState extends State<TapPayCheckoutPage> {
  final bridge = DemoJsBridge();
  String result = '';
  bool _tapPaySetupDone = false;
  bool _cardNumberReady = false;
  bool _expiryReady = false;
  bool _ccvReady = false;

  static const int _appId = 	168457;
  static const String _appKey = 'app_OG15Z3XaUGyUnbnqXDJY6LuofOaS08FnHjtjY64VV29kQcHvhjRsmc3G1HT1'; 

  Future<void> _trySetupTapPayCard() async {
    if (_tapPaySetupDone) return;
    if (!_cardNumberReady || !_expiryReady || !_ccvReady) return;

    bridge.initTapPay(
      appId: _appId,
      appKey: _appKey,
      env: 'sandbox',
    );
    for (int i = 0; i < 100; i++) {
      if(bridge.setupCardData()) {
        if (!mounted) return;
        setState(() {
          _tapPaySetupDone = true;
          result = 'TapPay card fields setup done';
        });

        return;
      }

      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (!mounted) return;
    setState(() {
      result = 'TapPay setup failed: card field containers not found';
    });
  }

  void _readInputs() {
    final data = bridge.getCardData();
    setState(() {
      result =
          'Card Number: ${data['cardNumber']}\n'
          'Expiration Date: ${data['expirationDate']}\n'
          'CCV: ${data['ccv']}';
    });
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildCardNumberInput() {
    return SizedBox(
      width: 360,
      height: 48,
      child: HtmlElementView.fromTagName(
        tagName: 'div',
        onElementCreated: (Object element) {
          final div = element as web.HTMLDivElement;
          div.id = 'card-number-input';
          div.style.width = '360px';
          div.style.height = '48px';
          _cardNumberReady = true;
        },
      ),
    );
  }

  Widget _buildExpiryInput() {
    return SizedBox(
      width: 180,
      height: 48,
      child: HtmlElementView.fromTagName(
        tagName: 'div',
        onElementCreated: (Object element) {
          final div = element as web.HTMLDivElement;
          div.id = 'expiry-input';
          div.style.width = '180px';
          div.style.height = '48px';
          _expiryReady = true;
        },
      ),
    );
  }

  Widget _buildCcvInput() {
    return SizedBox(
      width: 120,
      height: 48,
      child: HtmlElementView.fromTagName(
        tagName: 'div',
        onElementCreated: (Object element) {
          final div = element as web.HTMLDivElement;
          div.id = 'ccv-input';
          div.style.width = '120px';
          div.style.height = '48px';
          _ccvReady = true;
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_trySetupTapPayCard()); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Card Input Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Card Number'),
            const SizedBox(height: 12),
            _buildCardNumberInput(),
            const SizedBox(height: 20),

            _buildLabel('Expiration Date'),
            const SizedBox(height: 12),
            _buildExpiryInput(),
            const SizedBox(height: 20),

            _buildLabel('CCV'),
            const SizedBox(height: 12),
            _buildCcvInput(),
            const SizedBox(height: 20),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton(
                  onPressed: _readInputs,
                  child: const Text('Read inputs with JS'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final result = await bridge.getPrime();
                    if(result["status"] == 0) {
                      PurchaseWebPodcoinRes res = await purchaseApiManager.purchaseWebPodcoin(result["prime"], "wpc_001");
                      if(res.code == "0000") {
                        ToastService.showSuccessToast("Purchase successful!");
                      }
                    }
                  },
                  child: const Text('Get Prime'),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Text(result),
          ],
        ),
      ),
    );
  }
}