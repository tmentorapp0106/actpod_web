import 'package:flutter/material.dart';

class PodcoinUsageNotice extends StatelessWidget {
  const PodcoinUsageNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16), // 可依需求調整邊距
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'PodCoins 使用須知',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          SizedBox(height: 12),
          Text('1. PodCoins 為 ActPod 內部虛擬貨幣，僅限於本平台使用，無法轉讓或兌換成現金。'),
          SizedBox(height: 8),
          Text('2. 購買後不可退費。請在購買前確認金額與需求，避免重複購買。'),
          SizedBox(height: 8),
          Text('3. PodCoins 可用於：\n   - 打賞喜歡的創作者\n   - 發送語音訊息互動'),
          SizedBox(height: 8),
          Text('4. 若您為免費會員，收到 Podcoins 後無法轉換為現金（創作者需為付費會員才能提領收入）。'),
          SizedBox(height: 8),
          Text('5. 為保障交易安全與用戶權益，ActPod 可能會在異常使用情況下暫停帳戶使用或交易行為。'),
          SizedBox(height: 8),
          Text('6. 若有任何疑問，請寄信至：contact.us@actpodapp.com 與我們聯繫。'),
        ],
      ),
    );
  }
}
