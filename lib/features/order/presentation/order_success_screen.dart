import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderId;
  final int orderNumber;
  final String paymentMethod;

  const OrderSuccessScreen({
    super.key,
    required this.orderId,
    required this.orderNumber,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAtRegister = paymentMethod == 'atRegister';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Order Confirmed', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 成功アイコン (スタバ風グリーン)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0xFFD4E9E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF006241),
                  size: 60, // 少しサイズダウンして余裕を持たせる
                ),
              ),
              const SizedBox(height: 24),
              
              Text(
                'ご注文ありがとうございます！',
                style: GoogleFonts.notoSansJp(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // 注文番号
              Text(
                '注文番号',
                style: GoogleFonts.notoSansJp(fontSize: 14, color: Colors.grey),
              ),
              Text(
                '#${orderNumber.toString().padLeft(3, '0')}',
                style: GoogleFonts.outfit(fontSize: 40, fontWeight: FontWeight.bold, color: const Color(0xFF006241)),
              ),
              
              const SizedBox(height: 32),
              
              // レジ精算時の案内 (QRコード代わりのIDコード)
              if (isAtRegister) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      const Text('レジにて下のコードを提示してください', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      // 簡易バーコード風表示
                      Text(
                        orderId.substring(0, 8).toUpperCase(),
                        style: GoogleFonts.outfit(fontSize: 20, letterSpacing: 6, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Icon(Icons.qr_code_2, size: 80), // サイズを少し調整
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text('※お支払いが完了してから調理を開始します', style: TextStyle(fontSize: 11, color: Colors.redAccent, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              ] else ...[
                const Text('事前決済が完了しました。', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('お呼び出しまでそのままお待ちください。', textAlign: TextAlign.center),
              ],
              
              const SizedBox(height: 48),
              
              // 戻るボタン
              ElevatedButton(
                onPressed: () {
                  // カートを空にしてトップページへ
                  context.go('/');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006241),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
                child: Text('ホームに戻る', style: GoogleFonts.notoSansJp(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
