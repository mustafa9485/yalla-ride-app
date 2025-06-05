import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// شاشة عرض باركود زين كاش للدفع
/// تعرض الباركود الثابت لزين كاش مع تعليمات الدفع
class ZainCashQRPaymentScreen extends StatefulWidget {
  final double amount;
  final String paymentDescription;
  final String? referenceId;
  final Function(bool success, String? transactionId) onPaymentComplete;
  
  const ZainCashQRPaymentScreen({
    Key? key,
    required this.amount,
    required this.paymentDescription,
    this.referenceId,
    required this.onPaymentComplete,
  }) : super(key: key);

  @override
  State<ZainCashQRPaymentScreen> createState() => _ZainCashQRPaymentScreenState();
}

class _ZainCashQRPaymentScreenState extends State<ZainCashQRPaymentScreen> {
  bool _isLoading = false;
  
  // معلومات زين كاش الثابتة
  static const String zainCashNumber = "07801234567"; // رقم زين كاش للتطبيق
  static const String merchantName = "يلا رايد";
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'الدفع عبر زين كاش',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF6B46C1), // بنفسجي زين كاش
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildPaymentView(),
      bottomNavigationBar: _buildBottomActions(),
    );
  }
  
  /// بناء واجهة الدفع الرئيسية
  Widget _buildPaymentView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // شعار زين كاش
          _buildZainCashLogo(),
          const SizedBox(height: 30),
          
          // وصف الدفع والمبلغ
          _buildPaymentInfo(),
          const SizedBox(height: 30),
          
          // الباركود
          _buildQRCode(),
          const SizedBox(height: 30),
          
          // معلومات الحساب
          _buildAccountInfo(),
          const SizedBox(height: 30),
          
          // تعليمات الدفع
          _buildPaymentInstructions(),
        ],
      ),
    );
  }
  
  /// شعار زين كاش
  Widget _buildZainCashLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B46C1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(60),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B46C1).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'ZC',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
  
  /// معلومات الدفع والمبلغ
  Widget _buildPaymentInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Text(
            widget.paymentDescription,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              '${widget.amount.toStringAsFixed(0)} د.ع',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          if (widget.referenceId != null) ...[
            const SizedBox(height: 10),
            Text(
              'رقم المرجع: ${widget.referenceId}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  /// عرض الباركود
  Widget _buildQRCode() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'امسح الباركود بتطبيق زين كاش',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          
          // عرض الصورة الثابتة للباركود
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/images/zaincash_qr.jpg',
              width: 200,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // في حالة عدم وجود الصورة، نعرض QR code مولد
                return _buildGeneratedQRCode();
              },
            ),
          ),
          
          const SizedBox(height: 15),
          const Text(
            'أو استخدم معلومات الحساب أدناه',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
  
  /// إنشاء QR code مولد كبديل
  Widget _buildGeneratedQRCode() {
    // إنشاء بيانات QR code تحتوي على معلومات الدفع
    final qrData = {
      'merchant': merchantName,
      'phone': zainCashNumber,
      'amount': widget.amount,
      'description': widget.paymentDescription,
      'reference': widget.referenceId ?? '',
    };
    
    return QrImageView(
      data: qrData.toString(),
      version: QrVersions.auto,
      size: 200.0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    );
  }
  
  /// معلومات الحساب
  Widget _buildAccountInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'معلومات الحساب:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 15),
          
          _buildAccountInfoRow(
            'اسم التاجر:',
            merchantName,
            Icons.store,
          ),
          const SizedBox(height: 10),
          
          _buildAccountInfoRow(
            'رقم زين كاش:',
            zainCashNumber,
            Icons.phone,
            copyable: true,
          ),
          const SizedBox(height: 10),
          
          _buildAccountInfoRow(
            'المبلغ:',
            '${widget.amount.toStringAsFixed(0)} د.ع',
            Icons.attach_money,
            copyable: true,
          ),
        ],
      ),
    );
  }
  
  /// صف معلومات الحساب
  Widget _buildAccountInfoRow(String label, String value, IconData icon, {bool copyable = false}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF6B46C1)),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ),
        if (copyable)
          IconButton(
            icon: const Icon(Icons.copy, size: 18, color: Color(0xFF6B46C1)),
            onPressed: () => _copyToClipboard(value),
            tooltip: 'نسخ',
          ),
      ],
    );
  }
  
  /// تعليمات الدفع
  Widget _buildPaymentInstructions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFFBBF24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFFD97706)),
              SizedBox(width: 10),
              Text(
                'تعليمات الدفع:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD97706),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          
          _buildInstructionStep(1, 'افتح تطبيق زين كاش على هاتفك'),
          _buildInstructionStep(2, 'اختر "مسح الباركود" أو "تحويل أموال"'),
          _buildInstructionStep(3, 'امسح الباركود أعلاه أو أدخل رقم الهاتف'),
          _buildInstructionStep(4, 'أدخل المبلغ المطلوب وأكمل العملية'),
          _buildInstructionStep(5, 'احفظ رقم العملية وارفع صورة الإثبات', isLast: true),
        ],
      ),
    );
  }
  
  /// خطوة في التعليمات
  Widget _buildInstructionStep(int number, String text, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFFD97706),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF92400E),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// أزرار الإجراءات السفلية
  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // زر تأكيد الدفع
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _showPaymentConfirmationDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 2,
              ),
              child: const Text(
                'تم الدفع - رفع الإثبات',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          
          // زر الإلغاء
          SizedBox(
            width: double.infinity,
            height: 50,
            child: TextButton(
              onPressed: () {
                widget.onPaymentComplete(false, null);
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'إلغاء',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// نسخ النص إلى الحافظة
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم نسخ: $text'),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  /// عرض حوار تأكيد الدفع
  void _showPaymentConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'تأكيد الدفع',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'هل قمت بإكمال عملية الدفع عبر زين كاش؟\n\nسيتم توجيهك لرفع صورة إثبات الدفع.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لا'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _proceedToProofUpload();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
            ),
            child: const Text('نعم، تم الدفع'),
          ),
        ],
      ),
    );
  }
  
  /// الانتقال لرفع إثبات الدفع
  void _proceedToProofUpload() {
    // سيتم تطوير هذه الوظيفة في المرحلة التالية
    Navigator.pushNamed(
      context,
      '/payment_proof_upload',
      arguments: {
        'amount': widget.amount,
        'description': widget.paymentDescription,
        'reference_id': widget.referenceId,
        'payment_method': 'zaincash',
      },
    ).then((result) {
      if (result != null && result is Map) {
        widget.onPaymentComplete(
          result['success'] ?? false,
          result['transaction_id'],
        );
        Navigator.pop(context);
      }
    });
  }
}

