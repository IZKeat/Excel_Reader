import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';

void main() {
  runApp(const ExcelReaderApp());
}

class ExcelReaderApp extends StatelessWidget {
  const ExcelReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Excel Reader',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Excel? _excel;
  String? _fileName;
  String? _errorMessage;

  Future<void> _pickFile() async {
    setState(() {
      _errorMessage = null;
      _excel = null;
      _fileName = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      if (file.bytes == null) {
        setState(() => _errorMessage = '无法读取文件内容，请重试。');
        return;
      }

      final excel = Excel.decodeBytes(file.bytes!);

      if (excel.sheets.isEmpty) {
        setState(() => _errorMessage = '该文件没有任何工作表。');
        return;
      }

      setState(() {
        _excel = excel;
        _fileName = file.name;
      });
    } catch (e) {
      setState(() => _errorMessage = '文件解析失败，请确认文件格式正确。\n错误：$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_fileName ?? 'Excel Reader'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: '打开文件',
            onPressed: _pickFile,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.folder_open),
                label: const Text('重新选择文件'),
              ),
            ],
          ),
        ),
      );
    }

    if (_excel == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.table_chart_outlined, size: 72, color: Colors.teal),
            const SizedBox(height: 24),
            const Text(
              '点击下方按钮打开 .xlsx 文件',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.folder_open),
              label: const Text('选择文件'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      );
    }

    final sheetNames = _excel!.sheets.keys.toList();

    if (sheetNames.length == 1) {
      return SheetView(sheet: _excel!.sheets[sheetNames.first]!);
    }

    return DefaultTabController(
      length: sheetNames.length,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabs: sheetNames.map((name) => Tab(text: name)).toList(),
          ),
          Expanded(
            child: TabBarView(
              children: sheetNames
                  .map((name) => SheetView(sheet: _excel!.sheets[name]!))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class SheetView extends StatelessWidget {
  final Sheet sheet;

  const SheetView({super.key, required this.sheet});

  String _cellText(Data? cell) {
    if (cell == null || cell.value == null) return '';
    final v = cell.value;
    if (v is TextCellValue) return v.value.toString();
    if (v is IntCellValue) return v.value.toString();
    if (v is DoubleCellValue) return v.value.toString();
    if (v is BoolCellValue) return v.value.toString();
    if (v is DateCellValue) {
      return '${v.year}-${v.month.toString().padLeft(2, '0')}-${v.day.toString().padLeft(2, '0')}';
    }
    if (v is TimeCellValue) {
      return '${v.hour.toString().padLeft(2, '0')}:${v.minute.toString().padLeft(2, '0')}';
    }
    return v.toString();
  }

  bool _isAmountColumn(List<List<Data?>> rows, int colIndex) {
    for (final row in rows.skip(1)) {
      if (colIndex >= row.length) continue;
      final cell = row[colIndex];
      if (cell == null || cell.value == null) continue;
      final v = cell.value;
      if (v is DoubleCellValue || v is IntCellValue) return true;
      if (v is TextCellValue) {
        final text = v.value.toString().trim();
        if (RegExp(r'^-?\d[\d,\.]*$').hasMatch(text)) return true;
      }
      return false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final rows = sheet.rows;

    if (rows.isEmpty) {
      return const Center(child: Text('此工作表为空'));
    }

    final lastRowIndex = rows.length - 1;
    final colCount =
        rows.map((r) => r.length).fold(0, (a, b) => a > b ? a : b);
    final amountCols =
        List.generate(colCount, (i) => _isAmountColumn(rows, i));

    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Scrollbar(
          thumbVisibility: true,
          notificationPredicate: (n) => n.depth == 1,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Table(
                border: TableBorder.all(color: Colors.grey.shade400),
                defaultColumnWidth: const IntrinsicColumnWidth(),
                children: rows.asMap().entries.map((entry) {
                  final rowIndex = entry.key;
                  final row = entry.value;
                  final isHeader = rowIndex == 0;
                  final isGrandTotal = rowIndex == lastRowIndex &&
                      _cellText(row.isNotEmpty ? row.first : null)
                          .toUpperCase()
                          .contains('GRAND TOTAL');

                  return TableRow(
                    decoration: BoxDecoration(
                      color: isHeader
                          ? Colors.teal.shade50
                          : isGrandTotal
                              ? Colors.grey.shade100
                              : null,
                    ),
                    children: List.generate(colCount, (colIndex) {
                      final cell =
                          colIndex < row.length ? row[colIndex] : null;
                      final text = _cellText(cell);
                      final isBold = isHeader || isGrandTotal;
                      final isRight = amountCols[colIndex] && !isHeader;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        child: Text(
                          text,
                          textAlign:
                              isRight ? TextAlign.right : TextAlign.left,
                          style: TextStyle(
                            fontWeight: isBold
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      );
                    }),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
