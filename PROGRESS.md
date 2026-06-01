# 开发进度

> 项目：Excel Reader —— 纯查看本地 .xlsx 的安卓 App
> 最后更新：2026-06-01

## 总体状态

✅ **首个 release 签名版 APK 已成功构建**
产物路径：`build/app/outputs/flutter-apk/app-release.apk`（约 44.3 MB，已用正式 keystore 签名）

## 已完成步骤

| # | 步骤 | 状态 | 说明 |
|---|------|------|------|
| 1 | 环境检查 | ✅ | Flutter 3.44.0 / Android SDK / OpenJDK 17 就绪。Visual Studio 仅用于 Windows 桌面开发，安卓不需要，已忽略 |
| 2 | 创建项目 | ✅ | `flutter create --org com.isaac --project-name excel_reader .` |
| 3 | App 名称 | ✅ | AndroidManifest.xml 的 `android:label` 改为 "Excel Reader" |
| 4 | 添加依赖 | ✅ | file_picker 8.3.7、excel 4.0.6 |
| 5 | 编写 UI | ✅ | 见下方「功能清单」 |
| 6 | 配置 release 签名 | ✅ | keystore + key.properties（已 gitignore）+ build.gradle.kts signingConfigs.release |
| 7 | 构建 release APK | ✅ | `flutter build apk --release` 成功 |
| 8 | 安装到真机 | ✅ | 经 adb 安装到手机，功能实测正常 |
| 9 | 自定义应用图标 | ✅ | 用 flutter_launcher_icons 生成 Excel 图标，已安装确认 |

## 功能清单（lib/main.dart）

- ✅ 用 file_picker 选择 .xlsx（`withData: true` 直接拿字节）
- ✅ 用 excel 包解析每个 sheet 的二维单元格数据
- ✅ 用 Table widget 渲染：整表边框、首行表头加粗、末行 GRAND TOTAL 加粗、金额列右对齐
- ✅ 多个 sheet 用 TabBar / DefaultTabController 切换
- ✅ SingleChildScrollView 横向 + 纵向双滚动，支持大表格
- ✅ 坏文件 / 空文件 / 无 sheet 的友好提示

## 构建过程中解决的报错

1. **TextCellValue 类型错误** —— excel 4.0.6 的 `TextCellValue.value` 是包内自定义的 `TextSpan`，不是 String 也没有 `toPlainText()`。改用 `.toString()`（其 toString 会拼出纯文本）。
2. **旧测试文件编译失败** —— 默认 `test/widget_test.dart` 仍引用旧类名 `MyApp` 并测试计数器。改写为针对本应用的冒烟测试。
3. **compileSdk 不匹配** —— file_picker 8.x 在自身 build.gradle 写死 `compileSdk 34`，与要求 36+ 的 flutter_plugin_android_lifecycle 冲突。在项目级 `android/build.gradle.kts` 中强制所有 Android library 子模块 compileSdk = 36。
4. **afterEvaluate 时机错误** —— 因前置 `evaluationDependsOn(":app")` 使 `:app` 提前评估完毕，直接 afterEvaluate 报错。改为对「已评估 / 未评估」子模块分别处理。

## 重要提醒（签名密钥）

⚠️ 必须单独、安全地备份以下两项，**丢失后将无法用同一签名更新此 App**：
- `android/app/upload-keystore.jks`（密钥库文件，已 gitignore，不进版本库）
- keystore / key 密码

`android/key.properties` 内含明文密码，已加入 `.gitignore`，不会被提交。

## 后续待办

- [x] 安装到真机实测：已安装，功能正常
- [x] 自定义应用图标：Excel 图标，已生成并安装
- [ ] （可选）换用 1024×1024 正方形高清图标源，提升清晰度
- [ ] （可选）支持 .xls 旧格式 / CSV
- [ ] （可选）按文件名记忆最近打开
