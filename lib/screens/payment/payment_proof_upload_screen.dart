import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/// شاشة رفع إثبات الدفع
/// تسمح للسائق برفع صورة إثبات الدفع عبر زين كاش
class PaymentProofUploadScreen extends StatefulWidget {
  final double amount;
  final String description;
  final String? referenceId;
  final String paymentMethod;
  
  const PaymentProofUploadScreen({
    Key? key,
    required this.amount,
    required this.description,
    this.referenceId,
    required this.paymentMethod,
  }) : super(key: key);

  @override
  State<PaymentProofUploadScreen> createState() => _PaymentProofUploadScreenState();
}

class _PaymentProofUploadScreenState extends State<PaymentProofUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _transactionIdController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  File? _selectedImage;
  bool _isUploading = false;
  String? _errorMessage;
  
  @override
  void dispose() {
    _transactionIdController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'رفع إثبات الدفع',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF10B981),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isUploading
          ? _buildLoadingView()
          : _buildUploadView(),
      bottomNavigationBar: _buildBottomActions(),
    );
  }
  
  /// واجهة التحميل
  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
          ),
          SizedBox(height: 20),
          Text(
            'جاري رفع إثبات الدفع...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
  
  /// واجهة الرفع الرئيسية
  Widget _buildUploadView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // معلومات الدفع
          _buildPaymentSummary(),
          const SizedBox(height: 30),
          
          // رفع الصورة
          _buildImageUploadSection(),
          const SizedBox(height: 30),
          
          // رقم العملية
          _buildTransactionIdSection(),
          const SizedBox(height: 20),
          
          // ملاحظات إضافية
          _buildNotesSection(),
          const SizedBox(height: 30),
          
          // تعليمات مهمة
          _buildImportantNotes(),
          
          // رسالة خطأ
          if (_errorMessage != null) ...[
            const SizedBox(height: 20),
            _buildErrorMessage(),
          ],
        ],
      ),
    );
  }
  
  /// ملخص معلومات الدفع
  Widget _buildPaymentSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.receipt, color: Color(0xFF10B981)),
              SizedBox(width: 10),
              Text(
                'ملخص الدفع',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF065F46),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          
          _buildSummaryRow('الوصف:', widget.description),
          _buildSummaryRow('المبلغ:', '${widget.amount.toStringAsFixed(0)} د.ع'),
          _buildSummaryRow('طريقة الدفع:', 'زين كاش'),
          if (widget.referenceId != null)
            _buildSummaryRow('رقم المرجع:', widget.referenceId!),
        ],
      ),
    );
  }
  
  /// صف في ملخص الدفع
  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF065F46),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF047857),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// قسم رفع الصورة
  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'صورة إثبات الدفع *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'يرجى رفع صورة واضحة لإثبات الدفع من تطبيق زين كاش',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 15),
        
        // منطقة رفع الصورة
        GestureDetector(
          onTap: _showImageSourceDialog,
          child: Container(
            width: double.infinity,
            height: _selectedImage != null ? 300 : 200,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: _selectedImage != null 
                    ? const Color(0xFF10B981) 
                    : Colors.grey[300]!,
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: _selectedImage != null
                ? _buildSelectedImage()
                : _buildUploadPlaceholder(),
          ),
        ),
      ],
    );
  }
  
  /// عرض الصورة المختارة
  Widget _buildSelectedImage() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Image.file(
            _selectedImage!,
            width: double.infinity,
            height: 300,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedImage = null;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          left: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'تم الرفع ✓',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  /// مكان رفع الصورة
  Widget _buildUploadPlaceholder() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.cloud_upload_outlined,
          size: 60,
          color: Colors.grey,
        ),
        SizedBox(height: 15),
        Text(
          'اضغط لرفع صورة إثبات الدفع',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'JPG, PNG (حد أقصى 5 ميجا)',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
  
  /// قسم رقم العملية
  Widget _buildTransactionIdSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'رقم العملية *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _transactionIdController,
          decoration: InputDecoration(
            hintText: 'أدخل رقم العملية من زين كاش',
            prefixIcon: const Icon(Icons.confirmation_number, color: Color(0xFF10B981)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF10B981)),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          keyboardType: TextInputType.text,
        ),
      ],
    );
  }
  
  /// قسم الملاحظات
  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ملاحظات إضافية',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'أي ملاحظات إضافية حول عملية الدفع (اختياري)',
            prefixIcon: const Icon(Icons.note, color: Color(0xFF10B981)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF10B981)),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }
  
  /// تعليمات مهمة
  Widget _buildImportantNotes() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFBBF24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber, color: Color(0xFFD97706)),
              SizedBox(width: 10),
              Text(
                'تعليمات مهمة:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD97706),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            '• تأكد من وضوح الصورة وظهور جميع التفاصيل\n'
            '• يجب أن تظهر الصورة رقم العملية والمبلغ بوضوح\n'
            '• سيتم مراجعة الإثبات من قبل الإدارة خلال 24 ساعة\n'
            '• في حالة رفض الإثبات، ستحتاج لرفع صورة جديدة',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF92400E),
            ),
          ),
        ],
      ),
    );
  }
  
  /// رسالة الخطأ
  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEF4444)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFDC2626)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFFDC2626),
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
          // زر الإرسال
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _canSubmit() ? _submitProof : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 2,
              ),
              child: const Text(
                'إرسال الإثبات للمراجعة',
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
              onPressed: () => Navigator.pop(context),
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
  
  /// التحقق من إمكانية الإرسال
  bool _canSubmit() {
    return _selectedImage != null && 
           _transactionIdController.text.trim().isNotEmpty &&
           !_isUploading;
  }
  
  /// عرض حوار اختيار مصدر الصورة
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'اختر مصدر الصورة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // الكاميرا
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF10B981)),
              title: const Text('التقاط صورة'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            
            // المعرض
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF10B981)),
              title: const Text('اختيار من المعرض'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  /// اختيار الصورة
  Future<void> _pickImage(ImageSource source) async {
    try {
      // طلب الصلاحيات
      if (source == ImageSource.camera) {
        final cameraStatus = await Permission.camera.request();
        if (!cameraStatus.isGranted) {
          _showPermissionDeniedDialog('الكاميرا');
          return;
        }
      }
      
      // اختيار الصورة
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        // التحقق من حجم الملف
        final file = File(image.path);
        final fileSize = await file.length();
        
        if (fileSize > 5 * 1024 * 1024) { // 5 ميجا
          setState(() {
            _errorMessage = 'حجم الصورة كبير جداً. يرجى اختيار صورة أصغر من 5 ميجا.';
          });
          return;
        }
        
        setState(() {
          _selectedImage = file;
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ أثناء اختيار الصورة: $e';
      });
    }
  }
  
  /// عرض حوار رفض الصلاحية
  void _showPermissionDeniedDialog(String permission) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('صلاحية مطلوبة'),
        content: Text('يحتاج التطبيق إلى صلاحية $permission لرفع الصورة.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('فتح الإعدادات'),
          ),
        ],
      ),
    );
  }
  
  /// إرسال الإثبات
  Future<void> _submitProof() async {
    if (!_canSubmit()) return;
    
    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });
    
    try {
      // محاكاة رفع الصورة والبيانات
      await Future.delayed(const Duration(seconds: 3));
      
      // في التطبيق الحقيقي، سيتم رفع الصورة إلى Supabase Storage
      // وحفظ بيانات الإثبات في قاعدة البيانات
      
      // إنشاء معرف فريد للإثبات
      final proofId = 'proof_${DateTime.now().millisecondsSinceEpoch}';
      
      // إرجاع النتيجة
      Navigator.pop(context, {
        'success': true,
        'transaction_id': proofId,
        'message': 'تم إرسال إثبات الدفع بنجاح. سيتم مراجعته خلال 24 ساعة.',
      });
      
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ أثناء رفع الإثبات: $e';
        _isUploading = false;
      });
    }
  }
}

