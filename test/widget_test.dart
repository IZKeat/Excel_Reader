// Basic smoke test for Excel Reader.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:excel_reader/main.dart';

void main() {
  testWidgets('App launches and shows the open-file prompt',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ExcelReaderApp());

    // The empty state should prompt the user to open a file.
    expect(find.text('选择文件'), findsOneWidget);
    expect(find.byIcon(Icons.table_chart_outlined), findsOneWidget);
  });
}
