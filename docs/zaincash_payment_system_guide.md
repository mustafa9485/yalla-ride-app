# دليل نظام الدفع بالزين كاش - تطبيق يلا رايد

## نظرة عامة

تم تطوير نظام دفع متكامل لتطبيق يلا رايد يدعم الدفع عبر زين كاش مع باركود حقيقي ونظام رفع ومراجعة إثباتات الدفع. يتضمن النظام ثلاث واجهات رئيسية:

1. **واجهة السائق**: عرض الباركود ورفع إثبات الدفع
2. **واجهة الأدمن**: مراجعة والموافقة على إثباتات الدفع
3. **النظام الخلفي**: إدارة العمليات والإشعارات

## الملفات المطورة

### 1. تحديث pubspec.yaml
تم إضافة المكتبات التالية:
- `qr_flutter: ^4.1.0` - لإنشاء QR codes
- `qr_code_scanner: ^1.0.1` - لقراءة QR codes  
- `image_picker: ^1.0.7` - لاختيار الصور
- `permission_handler: ^11.3.1` - لإدارة الصلاحيات

### 2. الشاشات المطورة

#### أ) شاشة عرض باركود زين كاش
**المسار**: `lib/screens/payment/zaincash_qr_payment_screen.dart`

**الميزات**:
- عرض الباركود الحقيقي من الصورة المرفوعة
- عرض معلومات الدفع (المبلغ، الوصف، رقم المرجع)
- تعليمات مفصلة للدفع
- إمكانية نسخ معلومات الحساب
- زر للانتقال لرفع إثبات الدفع

**الاستخدام**:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ZainCashQRPaymentScreen(
      amount: 25000.0,
      paymentDescription: 'دفع عمولة الرحلات',
      referenceId: 'REF123456',
      onPaymentComplete: (success, transactionId) {
        // معالجة نتيجة الدفع
      },
    ),
  ),
);
```

#### ب) شاشة رفع إثبات الدفع
**المسار**: `lib/screens/payment/payment_proof_upload_screen.dart`

**الميزات**:
- رفع صورة إثبات الدفع من الكاميرا أو المعرض
- إدخال رقم العملية من زين كاش
- إضافة ملاحظات اختيارية
- التحقق من صحة البيانات قبل الإرسال
- رفع الصورة إلى Supabase Storage

**الاستخدام**:
```dart
Navigator.pushNamed(
  context,
  '/payment_proof_upload',
  arguments: {
    'amount': 25000.0,
    'description': 'دفع عمولة الرحلات',
    'reference_id': 'REF123456',
    'payment_method': 'zaincash',
  },
);
```

#### ج) شاشة مراجعة إثباتات الدفع (الأدمن)
**المسار**: `lib/screens/admin/admin_payment_proof_review_screen.dart`

**الميزات**:
- عرض قائمة الإثباتات قيد المراجعة
- عرض قائمة الإثباتات المراجعة
- عرض تفاصيل كل إثبات مع الصورة
- الموافقة أو رفض الإثباتات مع إضافة ملاحظات
- إرسال إشعارات للسائقين

## تدفق العمل

### 1. عملية الدفع للسائق

```
1. السائق يحتاج لدفع العمولة
   ↓
2. عرض شاشة باركود زين كاش
   ↓
3. السائق يدفع عبر تطبيق زين كاش
   ↓
4. السائق يضغط "تم الدفع"
   ↓
5. الانتقال لشاشة رفع الإثبات
   ↓
6. رفع صورة الإثبات ورقم العملية
   ↓
7. إرسال الإثبات للمراجعة
   ↓
8. إشعار الأدمن بوجود إثبات جديد
```

### 2. عملية المراجعة للأدمن

```
1. الأدمن يستلم إشعار بإثبات جديد
   ↓
2. فتح شاشة مراجعة الإثباتات
   ↓
3. عرض تفاصيل الإثبات والصورة
   ↓
4. الموافقة أو الرفض مع ملاحظات
   ↓
5. تحديث حالة الإثبات في قاعدة البيانات
   ↓
6. إرسال إشعار للسائق بالنتيجة
   ↓
7. تفعيل/إيقاف حساب السائق حسب النتيجة
```

## قاعدة البيانات

### جدول إثباتات الدفع
```sql
CREATE TABLE payment_proofs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id UUID REFERENCES users(id),
  payment_type TEXT NOT NULL, -- 'commission' أو 'plus_subscription'
  amount DECIMAL(10,2) NOT NULL,
  transaction_id TEXT NOT NULL,
  image_url TEXT NOT NULL,
  notes TEXT DEFAULT '',
  status TEXT DEFAULT 'pending', -- 'pending', 'approved', 'rejected'
  submitted_at TIMESTAMP DEFAULT NOW(),
  reviewed_at TIMESTAMP,
  reviewed_by UUID REFERENCES users(id),
  review_notes TEXT DEFAULT '',
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### فهارس مطلوبة
```sql
CREATE INDEX idx_payment_proofs_driver_id ON payment_proofs(driver_id);
CREATE INDEX idx_payment_proofs_status ON payment_proofs(status);
CREATE INDEX idx_payment_proofs_submitted_at ON payment_proofs(submitted_at);
```

## التكامل مع النظام الحالي

### 1. تحديث خدمة الدفع
يجب تحديث `lib/services/payment_service.dart` لتتضمن:
- استدعاء الشاشات الجديدة
- التكامل مع Supabase Storage لرفع الصور
- إرسال الإشعارات عند تغيير حالة الإثبات

### 2. تحديث خدمة العمولة
يجب تحديث `lib/services/commission_service.dart` لتتضمن:
- التحقق من حالة إثباتات الدفع
- منع استقبال الطلبات عند عدم دفع العمولة
- حساب المبالغ المستحقة بدقة

### 3. إضافة التوجيه
يجب إضافة المسارات التالية في `main.dart`:
```dart
'/zaincash_payment': (context) => ZainCashQRPaymentScreen(...),
'/payment_proof_upload': (context) => PaymentProofUploadScreen(...),
'/admin_payment_review': (context) => AdminPaymentProofReviewScreen(),
```

## الإعدادات المطلوبة

### 1. Supabase Storage
إنشاء bucket للصور:
```sql
INSERT INTO storage.buckets (id, name, public) 
VALUES ('payment-proofs', 'payment-proofs', false);
```

### 2. سياسات الأمان (RLS)
```sql
-- السماح للسائقين برفع إثباتاتهم فقط
CREATE POLICY "Drivers can upload their own proofs" ON payment_proofs
FOR INSERT WITH CHECK (auth.uid() = driver_id);

-- السماح للأدمن بمراجعة جميع الإثباتات
CREATE POLICY "Admins can review all proofs" ON payment_proofs
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM users 
    WHERE id = auth.uid() AND role = 'admin'
  )
);
```

### 3. معلومات زين كاش
تحديث المتغيرات في `lib/config/app_config.dart`:
```dart
static const String zainCashMerchantNumber = "07801234567";
static const String zainCashMerchantName = "يلا رايد";
```

## الاختبار

### 1. اختبار واجهة السائق
- [ ] عرض الباركود بوضوح
- [ ] نسخ معلومات الحساب
- [ ] رفع صورة من الكاميرا
- [ ] رفع صورة من المعرض
- [ ] التحقق من صحة البيانات
- [ ] إرسال الإثبات بنجاح

### 2. اختبار واجهة الأدمن
- [ ] عرض قائمة الإثباتات قيد المراجعة
- [ ] عرض تفاصيل الإثبات والصورة
- [ ] الموافقة على الإثبات
- [ ] رفض الإثبات مع ملاحظات
- [ ] تحديث الحالة في قاعدة البيانات

### 3. اختبار التكامل
- [ ] إرسال الإشعارات
- [ ] تحديث حالة السائق
- [ ] منع استقبال الطلبات عند عدم الدفع
- [ ] إعادة تفعيل الحساب بعد الموافقة

## الأمان والخصوصية

### 1. حماية الصور
- تشفير الصور المرفوعة
- تقييد الوصول للأدمن فقط
- حذف الصور بعد فترة محددة

### 2. التحقق من صحة البيانات
- التحقق من صيغة رقم العملية
- التحقق من حجم الصورة
- التحقق من صلاحيات المستخدم

### 3. مراجعة الأمان
- مراجعة دورية لسياسات RLS
- مراقبة محاولات الوصول غير المصرح
- تسجيل جميع العمليات الحساسة

## الصيانة والتطوير المستقبلي

### 1. تحسينات مقترحة
- إضافة OCR لاستخراج رقم العملية تلقائياً
- إضافة إشعارات push للأدمن
- إضافة تقارير مفصلة للدفعات
- إضافة نظام تقييم جودة الإثباتات

### 2. مراقبة الأداء
- مراقبة سرعة رفع الصور
- مراقبة معدل الموافقة/الرفض
- مراقبة زمن المراجعة

### 3. النسخ الاحتياطي
- نسخ احتياطي يومي لقاعدة البيانات
- نسخ احتياطي للصور المرفوعة
- خطة استرداد في حالة الطوارئ

---

**تم التطوير بواسطة**: فريق تطوير يلا رايد  
**تاريخ الإنشاء**: 5 يونيو 2025  
**الإصدار**: 1.0.0

