# Excel Reader

An Android app developed with Flutter for **opening and viewing local `.xlsx` files as-is** (view-only, no editing).

## Features

- 📂 Select and open local `.xlsx` files
- 📊 Render tables using native `Table` widget with borders
- 🔠 First row headers and last row GRAND TOTAL automatically bolded
- 💰 Amount (numeric) columns automatically right-aligned
- 🗂️ Switch between multiple sheets using TabBar
- ↔️ Horizontal + vertical scrolling, supports large tables
- ⚠️ Friendly error messages for corrupted/empty files

## Tech Stack

| Purpose | Solution |
|---------|----------|
| Framework | Flutter (without WebView) |
| File Picker | [file_picker](https://pub.dev/packages/file_picker) |
| Excel Parsing | [excel](https://pub.dev/packages/excel) |
| Table Rendering | Flutter native `Table` widget |

## Requirements

- Flutter 3.44+ (with Dart 3.12+)
- Android SDK (compileSdk 36)
- JDK 17

## Running

```bash
flutter pub get
flutter run            # Debug run
```

## Building Release APK

Before building a signed APK, you need to prepare signing keys (see below).

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

## Signing Configuration

This repository **does not include** signing keys (excluded by `.gitignore`). To build a signed version yourself:

1. Generate keystore:
   ```bash
   keytool -genkey -v -keystore android/app/upload-keystore.jks \
     -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Fill in `android/key.properties`:
   ```properties
   storePassword=<your store password>
   keyPassword=<your key password>
   keyAlias=upload
   storeFile=upload-keystore.jks
   ```

> ⚠️ Please securely back up `upload-keystore.jks` and the password. Once lost, you cannot update the published app with the same signature.

## Project Structure

```
lib/main.dart                       # All UI and parsing logic
android/app/build.gradle.kts        # App-level build configuration (includes release signing)
android/build.gradle.kts            # Project-level build configuration (enforces compileSdk 36)
android/key.properties              # Signing passwords (gitignored, not in repository)
PROGRESS.md                         # Development progress log
```

## License

Personal portfolio project.
