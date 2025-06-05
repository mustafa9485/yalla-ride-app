import 'package:flutter/material.dart';

/// شاشة مراجعة إثباتات الدفع للأدمن
/// تسمح للأدمن بمراجعة والموافقة على إثباتات الدفع المرفوعة من السائقين
class AdminPaymentProofReviewScreen extends StatefulWidget {
  const AdminPaymentProofReviewScreen({Key? key}) : super(key: key);

  @override
  State<AdminPaymentProofReviewScreen> createState() => _AdminPaymentProofReviewScreenState();
}

class _AdminPaymentProofReviewScreenState extends State<AdminPaymentProofReviewScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<PaymentProof> _pendingProofs = [];
  List<PaymentProof> _reviewedProofs = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPaymentProofs();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'مراجعة إثباتات الدفع',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1F2937),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.pending_actions),
                  const SizedBox(width: 8),
                  Text('قيد المراجعة (${_pendingProofs.length})'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history),
                  const SizedBox(width: 8),
                  Text('تمت المراجعة (${_reviewedProofs.length})'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildPendingProofsTab(),
                _buildReviewedProofsTab(),
              ],
            ),
    );
  }
  
  /// تبويب الإثباتات قيد المراجعة
  Widget _buildPendingProofsTab() {
    if (_pendingProofs.isEmpty) {
      return _buildEmptyState(
        icon: Icons.check_circle_outline,
        title: 'لا توجد إثباتات قيد المراجعة',
        subtitle: 'جميع الإثباتات تمت مراجعتها',
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadPaymentProofs,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pendingProofs.length,
        itemBuilder: (context, index) {
          return _buildProofCard(_pendingProofs[index], isPending: true);
        },
      ),
    );
  }
  
  /// تبويب الإثباتات التي تمت مراجعتها
  Widget _buildReviewedProofsTab() {
    if (_reviewedProofs.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history,
        title: 'لا توجد إثباتات مراجعة',
        subtitle: 'لم يتم مراجعة أي إثباتات بعد',
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadPaymentProofs,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _reviewedProofs.length,
        itemBuilder: (context, index) {
          return _buildProofCard(_reviewedProofs[index], isPending: false);
        },
      ),
    );
  }
  
  /// حالة فارغة
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  /// بطاقة إثبات الدفع
  Widget _buildProofCard(PaymentProof proof, {required bool isPending}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showProofDetails(proof),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // رأس البطاقة
              Row(
                children: [
                  // صورة السائق
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: const Color(0xFF10B981),
                    child: Text(
                      proof.driverName.substring(0, 1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // معلومات السائق
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          proof.driverName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'رقم الهاتف: ${proof.driverPhone}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // حالة الإثبات
                  _buildStatusChip(proof.status),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // تفاصيل الدفع
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('نوع الدفع:', proof.paymentType),
                    _buildDetailRow('المبلغ:', '${proof.amount.toStringAsFixed(0)} د.ع'),
                    _buildDetailRow('رقم العملية:', proof.transactionId),
                    _buildDetailRow('تاريخ الإرسال:', _formatDate(proof.submittedAt)),
                  ],
                ),
              ),
              
              // الملاحظات
              if (proof.notes.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFBAE6FD)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ملاحظات السائق:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0369A1),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        proof.notes,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF0369A1),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // أزرار الإجراءات للإثباتات قيد المراجعة
              if (isPending) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _approveProof(proof),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('موافقة'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _rejectProof(proof),
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('رفض'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              
              // معلومات المراجعة للإثباتات المراجعة
              if (!isPending && proof.reviewedAt != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: proof.status == PaymentProofStatus.approved
                        ? const Color(0xFFF0FDF4)
                        : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: proof.status == PaymentProofStatus.approved
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تمت المراجعة بواسطة: ${proof.reviewedBy ?? "غير محدد"}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: proof.status == PaymentProofStatus.approved
                              ? const Color(0xFF065F46)
                              : const Color(0xFF991B1B),
                        ),
                      ),
                      Text(
                        'تاريخ المراجعة: ${_formatDate(proof.reviewedAt!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: proof.status == PaymentProofStatus.approved
                              ? const Color(0xFF065F46)
                              : const Color(0xFF991B1B),
                        ),
                      ),
                      if (proof.reviewNotes.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'ملاحظات المراجعة: ${proof.reviewNotes}',
                          style: TextStyle(
                            fontSize: 12,
                            color: proof.status == PaymentProofStatus.approved
                                ? const Color(0xFF065F46)
                                : const Color(0xFF991B1B),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  /// صف التفاصيل
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// شريحة الحالة
  Widget _buildStatusChip(PaymentProofStatus status) {
    Color backgroundColor;
    Color textColor;
    String text;
    IconData icon;
    
    switch (status) {
      case PaymentProofStatus.pending:
        backgroundColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFD97706);
        text = 'قيد المراجعة';
        icon = Icons.pending;
        break;
      case PaymentProofStatus.approved:
        backgroundColor = const Color(0xFFF0FDF4);
        textColor = const Color(0xFF10B981);
        text = 'مقبول';
        icon = Icons.check_circle;
        break;
      case PaymentProofStatus.rejected:
        backgroundColor = const Color(0xFFFEF2F2);
        textColor = const Color(0xFFEF4444);
        text = 'مرفوض';
        icon = Icons.cancel;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
  
  /// عرض تفاصيل الإثبات
  void _showProofDetails(PaymentProof proof) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // رأس الحوار
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF1F2937),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long, color: Colors.white),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'تفاصيل إثبات الدفع',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              
              // محتوى الحوار
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // صورة الإثبات
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: proof.imageUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  proof.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.error_outline, size: 40, color: Colors.grey),
                                          SizedBox(height: 8),
                                          Text('خطأ في تحميل الصورة'),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              )
                            : const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text('لا توجد صورة'),
                                  ],
                                ),
                              ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // تفاصيل الإثبات
                      _buildDetailSection('معلومات السائق', [
                        ('الاسم', proof.driverName),
                        ('رقم الهاتف', proof.driverPhone),
                        ('معرف السائق', proof.driverId),
                      ]),
                      
                      const SizedBox(height: 16),
                      
                      _buildDetailSection('تفاصيل الدفع', [
                        ('نوع الدفع', proof.paymentType),
                        ('المبلغ', '${proof.amount.toStringAsFixed(0)} د.ع'),
                        ('رقم العملية', proof.transactionId),
                        ('تاريخ الإرسال', _formatDate(proof.submittedAt)),
                      ]),
                      
                      if (proof.notes.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildDetailSection('ملاحظات السائق', [
                          ('الملاحظات', proof.notes),
                        ]),
                      ],
                      
                      if (proof.reviewedAt != null) ...[
                        const SizedBox(height: 16),
                        _buildDetailSection('معلومات المراجعة', [
                          ('الحالة', _getStatusText(proof.status)),
                          ('تمت المراجعة بواسطة', proof.reviewedBy ?? 'غير محدد'),
                          ('تاريخ المراجعة', _formatDate(proof.reviewedAt!)),
                          if (proof.reviewNotes.isNotEmpty)
                            ('ملاحظات المراجعة', proof.reviewNotes),
                        ]),
                      ],
                    ],
                  ),
                ),
              ),
              
              // أزرار الإجراءات
              if (proof.status == PaymentProofStatus.pending) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _approveProof(proof);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('موافقة'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _rejectProof(proof);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF4444),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('رفض'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  /// قسم التفاصيل
  Widget _buildDetailSection(String title, List<(String, String)> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: details.map((detail) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        '${detail.$1}:',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        detail.$2,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
  
  /// تحميل إثباتات الدفع
  Future<void> _loadPaymentProofs() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // محاكاة تحميل البيانات من قاعدة البيانات
      await Future.delayed(const Duration(seconds: 1));
      
      // بيانات وهمية للاختبار
      final allProofs = [
        PaymentProof(
          id: '1',
          driverId: 'driver_1',
          driverName: 'أحمد محمد',
          driverPhone: '07801234567',
          paymentType: 'دفع عمولة',
          amount: 3000,
          transactionId: 'ZC123456789',
          imageUrl: 'https://example.com/proof1.jpg',
          notes: 'تم الدفع بنجاح عبر زين كاش',
          status: PaymentProofStatus.pending,
          submittedAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        PaymentProof(
          id: '2',
          driverId: 'driver_2',
          driverName: 'علي حسن',
          driverPhone: '07809876543',
          paymentType: 'اشتراك Plus',
          amount: 25000,
          transactionId: 'ZC987654321',
          imageUrl: 'https://example.com/proof2.jpg',
          notes: '',
          status: PaymentProofStatus.approved,
          submittedAt: DateTime.now().subtract(const Duration(days: 1)),
          reviewedAt: DateTime.now().subtract(const Duration(hours: 12)),
          reviewedBy: 'أدمن النظام',
          reviewNotes: 'تم قبول الإثبات بنجاح',
        ),
        PaymentProof(
          id: '3',
          driverId: 'driver_3',
          driverName: 'محمد عبدالله',
          driverPhone: '07805555555',
          paymentType: 'دفع عمولة',
          amount: 2000,
          transactionId: 'ZC555666777',
          imageUrl: 'https://example.com/proof3.jpg',
          notes: 'دفع عمولة رحلتين خارجيتين',
          status: PaymentProofStatus.rejected,
          submittedAt: DateTime.now().subtract(const Duration(days: 2)),
          reviewedAt: DateTime.now().subtract(const Duration(days: 1)),
          reviewedBy: 'أدمن النظام',
          reviewNotes: 'الصورة غير واضحة، يرجى رفع صورة أوضح',
        ),
      ];
      
      setState(() {
        _pendingProofs = allProofs.where((p) => p.status == PaymentProofStatus.pending).toList();
        _reviewedProofs = allProofs.where((p) => p.status != PaymentProofStatus.pending).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تحميل البيانات: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  /// الموافقة على الإثبات
  Future<void> _approveProof(PaymentProof proof) async {
    final result = await _showReviewDialog(
      title: 'موافقة على الإثبات',
      message: 'هل أنت متأكد من الموافقة على إثبات الدفع؟',
      isApproval: true,
    );
    
    if (result != null) {
      // محاكاة تحديث قاعدة البيانات
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        proof.status = PaymentProofStatus.approved;
        proof.reviewedAt = DateTime.now();
        proof.reviewedBy = 'أدمن النظام'; // في التطبيق الحقيقي، سيكون اسم الأدمن الحالي
        proof.reviewNotes = result;
        
        _pendingProofs.remove(proof);
        _reviewedProofs.insert(0, proof);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تمت الموافقة على الإثبات بنجاح'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    }
  }
  
  /// رفض الإثبات
  Future<void> _rejectProof(PaymentProof proof) async {
    final result = await _showReviewDialog(
      title: 'رفض الإثبات',
      message: 'هل أنت متأكد من رفض إثبات الدفع؟',
      isApproval: false,
    );
    
    if (result != null) {
      // محاكاة تحديث قاعدة البيانات
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        proof.status = PaymentProofStatus.rejected;
        proof.reviewedAt = DateTime.now();
        proof.reviewedBy = 'أدمن النظام'; // في التطبيق الحقيقي، سيكون اسم الأدمن الحالي
        proof.reviewNotes = result;
        
        _pendingProofs.remove(proof);
        _reviewedProofs.insert(0, proof);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم رفض الإثبات'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    }
  }
  
  /// عرض حوار المراجعة
  Future<String?> _showReviewDialog({
    required String title,
    required String message,
    required bool isApproval,
  }) async {
    final notesController = TextEditingController();
    
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 16),
            const Text(
              'ملاحظات (اختياري):',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: isApproval 
                    ? 'ملاحظات الموافقة...'
                    : 'سبب الرفض...',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, notesController.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: isApproval 
                  ? const Color(0xFF10B981) 
                  : const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: Text(isApproval ? 'موافقة' : 'رفض'),
          ),
        ],
      ),
    );
  }
  
  /// تنسيق التاريخ
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
  
  /// الحصول على نص الحالة
  String _getStatusText(PaymentProofStatus status) {
    switch (status) {
      case PaymentProofStatus.pending:
        return 'قيد المراجعة';
      case PaymentProofStatus.approved:
        return 'مقبول';
      case PaymentProofStatus.rejected:
        return 'مرفوض';
    }
  }
}

/// نموذج إثبات الدفع
class PaymentProof {
  final String id;
  final String driverId;
  final String driverName;
  final String driverPhone;
  final String paymentType;
  final double amount;
  final String transactionId;
  final String imageUrl;
  final String notes;
  PaymentProofStatus status;
  final DateTime submittedAt;
  DateTime? reviewedAt;
  String? reviewedBy;
  String reviewNotes;
  
  PaymentProof({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.driverPhone,
    required this.paymentType,
    required this.amount,
    required this.transactionId,
    required this.imageUrl,
    required this.notes,
    required this.status,
    required this.submittedAt,
    this.reviewedAt,
    this.reviewedBy,
    this.reviewNotes = '',
  });
}

/// حالات إثبات الدفع
enum PaymentProofStatus {
  pending,   // قيد المراجعة
  approved,  // مقبول
  rejected,  // مرفوض
}

