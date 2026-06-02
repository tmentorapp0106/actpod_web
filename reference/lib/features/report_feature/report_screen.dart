import 'package:flutter/material.dart';
import 'package:quick_share_app/apiManagers/user_system_api_manager.dart';
import 'package:quick_share_app/design_system/color.dart';
import 'package:quick_share_app/services/toast_service.dart';
import 'package:quick_share_app/services/user_service.dart';

import '../login_feature/login_screen.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({
    super.key,
  });

  @override
  State<ReportScreen> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportScreen> {
  final _formKey = GlobalKey<FormState>();

  final _targetCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _detailsCtrl = TextEditingController();

  String? _reason; // dropdown value
  bool _submitting = false;

  static const List<String> _reasons = [
    '侵權 / 版權問題',
    '仇恨言論 / 騷擾',
    '色情 / 裸露',
    '暴力 / 危險行為',
    '詐騙 / 冒充',
    '垃圾內容 / 洗版',
    '個資外洩',
    '其他',
  ];

  @override
  void initState() {
    super.initState();
    _reason = _reasons.first;
  }

  @override
  void dispose() {
    _targetCtrl.dispose();
    _emailCtrl.dispose();
    _detailsCtrl.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return '請輸入聯絡 Email';
    // 簡單 email 格式檢查（不追求完美，但足夠）
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value)) return 'Email 格式不正確';
    return null;
  }

  String? _validateRequired(String? v, String label) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return '請填寫$label';
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if(!UserService.hasLoggedIn()) {
      showDialog(
          context: context,
          builder: (context) {
            return LoginPageScreen();
          }
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await userApiManager.createReport(
        _targetCtrl.text.trim(),
        _emailCtrl.text.trim(),
        _reason ?? '其他',
        _detailsCtrl.text.trim(),
      );

      if (!mounted) return;
      ToastService.showSuccessToast('已送出檢舉回報，謝謝你協助維護社群');
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        ToastService.showNoticeToast('送出失敗：$e'),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('檢舉回報'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                '請提供以下資訊，我們會盡快處理。',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),

              // 1. 檢舉對象
              TextFormField(
                controller: _targetCtrl,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: '檢舉對象',
                  labelStyle: TextStyle(
                    color: Colors.black
                  ),
                  hintText: '例如：帳號名稱、單集故事名稱…',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20)
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: DesignColor.primary50,
                      width: 2,
                    ),
                  ),
                ),
                validator: (v) => _validateRequired(v, '檢舉對象'),
              ),
              const SizedBox(height: 16),

              // 2. 檢舉人聯絡 email
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: '檢舉人聯絡 Email',
                  labelStyle: TextStyle(
                      color: Colors.black
                  ),
                  hintText: 'name@example.com',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20)
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: DesignColor.primary50,
                      width: 2,
                    ),
                  ),
                ),
                validator: _validateEmail,
              ),
              const SizedBox(height: 16),

              // 3. 檢舉原因
              DropdownButtonFormField<String>(
                value: _reason,
                items: _reasons
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: _submitting ? null : (v) => setState(() => _reason = v),
                decoration: InputDecoration(
                  labelText: '檢舉原因',
                  labelStyle: TextStyle(
                      color: Colors.black
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20)
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: DesignColor.primary50,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 4. 更多描述
              TextFormField(
                controller: _detailsCtrl,
                minLines: 1,
                maxLines: 8,
                decoration: InputDecoration(
                  labelText: '更多描述',
                  labelStyle: TextStyle(
                      color: Colors.black
                  ),
                  hintText: '請描述發生的情況、時間點、相關證據（如有）…',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20)
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: DesignColor.primary50,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _submitting ? null : _submit,
                  icon: _submitting
                      ?  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: DesignColor.primary50,
                      strokeWidth: 2
                    ),
                  )
                      : const Icon(
                      Icons.flag_outlined,
                    color: Colors.red,
                  ),
                  label: Text(
                    _submitting ? '送出中…' : '送出檢舉',
                    style: TextStyle(
                      color: Colors.red
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Text(
                '提醒：請勿提供信用卡號、密碼等敏感資訊。',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}