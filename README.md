# Excel Reader

一个用 Flutter 开发的安卓 App，用于**打开并原样查看本地 `.xlsx` 文件**（纯查看，无编辑）。

## 功能特性

- 📂 选择并打开本地 `.xlsx` 文件
- 📊 用原生 `Table` 渲染表格，带边框
- 🔠 首行表头、末行 GRAND TOTAL 自动加粗
- 💰 金额（数字）列自动右对齐
- 🗂️ 多工作表用 TabBar 切换
- ↔️ 横向 + 纵向滚动，支持大表格
- ⚠️ 坏文件 / 空文件友好提示

## 技术栈

| 用途 | 方案 |
|------|------|
| 框架 | Flutter（不使用 WebView） |
| 文件选择 | [file_picker](https://pub.dev/packages/file_picker) |
| Excel 解析 | [excel](https://pub.dev/packages/excel) |
| 表格渲染 | Flutter 原生 `Table` widget |

## 环境要求

- Flutter 3.44+（含 Dart 3.12+）
- Android SDK（compileSdk 36）
- JDK 17

## 运行

```bash
flutter pub get
flutter run            # 调试运行
```

## 构建 Release APK

构建签名版 APK 前，需要先准备签名密钥（见下方）。

```bash
flutter build apk --release
```

产物：`build/app/outputs/flutter-apk/app-release.apk`

## 签名配置

本仓库**不包含**签名密钥（已被 `.gitignore` 排除）。如需自行构建签名版，请：

1. 生成 keystore：
   ```bash
   keytool -genkey -v -keystore android/app/upload-keystore.jks \
     -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. 在 `android/key.properties` 中填写：
   ```properties
   storePassword=<你的 store 密码>
   keyPassword=<你的 key 密码>
   keyAlias=upload
   storeFile=upload-keystore.jks
   ```

> ⚠️ 务必安全备份 `upload-keystore.jks` 与密码。一旦丢失，将无法用同一签名更新已发布的应用。

## 项目结构

```
lib/main.dart                       # 全部 UI 与解析逻辑
android/app/build.gradle.kts        # 应用级构建配置（含 release 签名）
android/build.gradle.kts            # 项目级构建配置（强制插件 compileSdk 36）
android/key.properties              # 签名密码（已 gitignore，不入库）
PROGRESS.md                         # 开发进度记录
```

## 许可

个人作品集项目。
