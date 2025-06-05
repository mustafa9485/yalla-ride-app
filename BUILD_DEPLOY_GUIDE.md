# دليل البناء والنشر الشامل لتطبيق Yalla Ride

## 🎯 نظرة عامة

هذا الدليل الشامل يوضح جميع الطرق المتاحة لبناء ونشر تطبيق Yalla Ride على منصات Android و iOS. تم إعداد التطبيق ليكون جاهزاً للبناء باستخدام عدة طرق مختلفة لضمان المرونة والسهولة.

## 📋 المتطلبات الأساسية

### للبناء المحلي:
- **Flutter SDK 3.24.5+**
- **Android Studio** أو **VS Code**
- **Java JDK 17**
- **Android SDK 35**
- **Android NDK 27.0.12077973**

### للبناء السحابي:
- **حساب GitHub** (مجاني)
- **حساب Firebase** (مجاني)
- **حساب Codemagic** (مجاني للمشاريع الصغيرة)



## 🚀 الطريقة الأولى: GitHub Actions (موصى بها)

### المميزات:
- ✅ **مجاني بالكامل**
- ✅ **بناء تلقائي عند كل push**
- ✅ **دعم Android و iOS**
- ✅ **نشر تلقائي للإصدارات**

### خطوات الإعداد:

#### 1. رفع المشروع إلى GitHub:
```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/username/yalla-ride-app.git
git push -u origin main
```

#### 2. تفعيل GitHub Actions:
- انتقل إلى مستودع GitHub
- اذهب إلى تبويب **Actions**
- ستجد workflows جاهزة:
  - `build-and-release.yml` - بناء Android
  - `build-ios.yml` - بناء iOS
  - `firebase-distribution.yml` - نشر Firebase

#### 3. إعداد الأسرار (Secrets):
في إعدادات المستودع > Secrets and variables > Actions:
```
FIREBASE_APP_ID: 1:123456789:android:abcdef123456
CREDENTIAL_FILE_CONTENT: محتوى ملف service account
```

#### 4. تشغيل البناء:
- ادفع أي تغيير إلى branch main
- أو اذهب إلى Actions واختر "Run workflow"

### النتائج:
- **APK files** في Artifacts
- **إصدارات تلقائية** في Releases
- **توزيع تلقائي** عبر Firebase


## 🔥 الطريقة الثانية: Firebase App Distribution

### المميزات:
- ✅ **توزيع سهل للمختبرين**
- ✅ **إشعارات تلقائية للتحديثات**
- ✅ **تتبع التحليلات**
- ✅ **دعم Android و iOS**

### خطوات الإعداد:

#### 1. إنشاء مشروع Firebase:
- اذهب إلى [Firebase Console](https://console.firebase.google.com)
- أنشئ مشروع جديد باسم "yalla-ride-app"
- فعّل App Distribution

#### 2. إضافة التطبيقات:
- أضف تطبيق Android بـ package name: `com.yallaride.app`
- أضف تطبيق iOS بـ bundle ID: `com.yallaride.app`
- حمّل ملفات التكوين:
  - `google-services.json` للـ Android
  - `GoogleService-Info.plist` للـ iOS

#### 3. إعداد CLI:
```bash
npm install -g firebase-tools
firebase login
firebase use yalla-ride-app
```

#### 4. رفع APK يدوياً:
```bash
firebase appdistribution:distribute \
  build/app/outputs/flutter-apk/app-release.apk \
  --app 1:123456789:android:abcdef123456 \
  --groups "testers" \
  --release-notes "إصدار جديد للاختبار"
```

#### 5. إضافة المختبرين:
- في Firebase Console > App Distribution
- أضف عناوين البريد الإلكتروني للمختبرين
- أنشئ مجموعات (مثل: testers, beta-users)

### الاستخدام التلقائي:
الـ workflow `firebase-distribution.yml` سيقوم بالرفع التلقائي عند كل push إلى main branch.


## ⚡ الطريقة الثالثة: Codemagic (متقدمة)

### المميزات:
- ✅ **متخصص في Flutter**
- ✅ **دعم كامل لـ iOS signing**
- ✅ **نشر مباشر للمتاجر**
- ✅ **بناء سريع على macOS**

### خطوات الإعداد:

#### 1. إنشاء حساب:
- اذهب إلى [Codemagic.io](https://codemagic.io)
- سجل دخول بحساب GitHub
- اربط مستودع yalla-ride-app

#### 2. إعداد التطبيق:
- اختر Flutter app
- حدد مستودع GitHub
- اختر branch: main

#### 3. تكوين البناء:
ملف `codemagic.yaml` موجود ومُعدّ مسبقاً ويتضمن:
- بناء Android APK & AAB
- بناء iOS IPA
- اختبارات تلقائية
- نشر للمتاجر

#### 4. إعداد التوقيع:

**للـ Android:**
- ارفع keystore file
- أضف معلومات التوقيع في Environment variables

**للـ iOS:**
- اربط Apple Developer account
- أضف certificates و provisioning profiles

#### 5. إعداد النشر:
```yaml
publishing:
  google_play:
    credentials: $GCLOUD_SERVICE_ACCOUNT_CREDENTIALS
    track: internal
  app_store_connect:
    auth: integration
    submit_to_testflight: true
```

### تشغيل البناء:
- ادفع تغيير إلى main branch
- أو اضغط "Start new build" في Codemagic dashboard


## 💻 الطريقة الرابعة: البناء المحلي

### المميزات:
- ✅ **تحكم كامل في البيئة**
- ✅ **اختبار فوري**
- ✅ **تطوير سريع**

### إعداد البيئة:

#### Windows:
```bash
# تثبيت Flutter
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# تثبيت Android Studio
# تحميل من: https://developer.android.com/studio

# تثبيت Java JDK 17
# تحميل من: https://adoptium.net/
```

#### macOS:
```bash
# تثبيت Flutter
brew install flutter

# تثبيت Xcode من App Store

# تثبيت Android Studio
brew install --cask android-studio
```

#### Linux:
```bash
# تثبيت Flutter
sudo snap install flutter --classic

# تثبيت Android Studio
sudo snap install android-studio --classic

# تثبيت Java JDK
sudo apt install openjdk-17-jdk
```

### أوامر البناء:

#### Android:
```bash
# تنظيف المشروع
flutter clean

# تثبيت التبعيات
flutter pub get

# بناء APK للاختبار
flutter build apk --debug

# بناء APK للإنتاج
flutter build apk --release

# بناء AAB للمتجر
flutter build appbundle --release
```

#### iOS (macOS فقط):
```bash
# بناء للمحاكي
flutter build ios --simulator

# بناء للجهاز (بدون توقيع)
flutter build ios --no-codesign

# بناء IPA للنشر
flutter build ipa
```

### مواقع الملفات:
- **Android APK**: `build/app/outputs/flutter-apk/`
- **Android AAB**: `build/app/outputs/bundle/release/`
- **iOS IPA**: `build/ios/ipa/`


## 🏪 نشر التطبيق في المتاجر

### Google Play Store:

#### 1. إنشاء حساب مطور:
- اذهب إلى [Google Play Console](https://play.google.com/console)
- ادفع رسوم التسجيل (25$ مرة واحدة)

#### 2. إنشاء التطبيق:
- اضغط "Create app"
- اختر اسم التطبيق: "يلا رايد"
- حدد الفئة: Maps & Navigation

#### 3. رفع AAB:
```bash
flutter build appbundle --release
```
- ارفع الملف من: `build/app/outputs/bundle/release/app-release.aab`

#### 4. إكمال المعلومات:
- وصف التطبيق
- لقطات الشاشة
- أيقونة التطبيق
- سياسة الخصوصية

### Apple App Store:

#### 1. إنشاء حساب مطور:
- اذهب إلى [Apple Developer](https://developer.apple.com)
- ادفع رسوم العضوية (99$ سنوياً)

#### 2. إنشاء App ID:
- في Developer Portal > Certificates, Identifiers & Profiles
- أنشئ App ID بـ Bundle ID: `com.yallaride.app`

#### 3. إنشاء التطبيق في App Store Connect:
- اذهب إلى [App Store Connect](https://appstoreconnect.apple.com)
- اضغط "+" لإنشاء تطبيق جديد

#### 4. رفع IPA:
```bash
flutter build ipa
```
- استخدم Xcode أو Application Loader لرفع الملف

## 🔧 استكشاف الأخطاء وإصلاحها

### مشاكل شائعة:

#### خطأ في التراخيص:
```bash
flutter doctor --android-licenses
```

#### مشكلة في Gradle:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

#### مشكلة في iOS:
```bash
cd ios
pod install --repo-update
cd ..
flutter clean
flutter pub get
```

### نصائح للأداء:
- استخدم `--release` للإنتاج
- فعّل `--obfuscate` للحماية
- استخدم `--split-debug-info` للتحليل

## 📞 الدعم والمساعدة

### الموارد المفيدة:
- [Flutter Documentation](https://docs.flutter.dev)
- [Firebase Documentation](https://firebase.google.com/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Codemagic Documentation](https://docs.codemagic.io)

### للمساعدة:
- **البريد الإلكتروني**: support@yallaride.com
- **GitHub Issues**: في مستودع المشروع
- **المجتمع**: Flutter Community على Discord

---

## 🎉 خلاصة

تطبيق Yalla Ride جاهز للبناء والنشر باستخدام أي من الطرق المذكورة أعلاه. الطريقة الموصى بها هي **GitHub Actions** للبساطة والمجانية، مع **Firebase App Distribution** للتوزيع على المختبرين.

**نتمنى لك التوفيق في نشر تطبيق يلا رايد! 🚗💨**

