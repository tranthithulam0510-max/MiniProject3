import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'data.dart';
import 'insight.dart';
import 'parser.dart';
import 'theme.dart';

/// 0 = hóa đơn, 1 = SMS, 2 = hợp đồng
final scanMode = ValueNotifier<int>(0);
const _modes = ['receipt', 'sms', 'contract'];

Widget _header(String title, {String? badge = 'Offline'}) => Row(children: [
      Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: mint, width: 2),
        ),
        child: const Text('₫', style: TextStyle(color: mint, fontWeight: FontWeight.w700)),
      ),
      const SizedBox(width: 10),
      Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
      const Spacer(),
      if (badge != null)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: mint.withOpacity(.6)),
          ),
          child: Text(badge, style: const TextStyle(fontSize: 11, color: mint)),
        ),
    ]);

Future<void> _manualEntry(BuildContext context) async {
  final a = TextEditingController(), m = TextEditingController();
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF24363F),
      title: const Text('Nhập tay'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: a, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Số tiền (VND)')),
        TextField(controller: m, decoration: const InputDecoration(labelText: 'Nơi chi / nội dung')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Lưu')),
      ],
    ),
  );
  final amount = int.tryParse(a.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  if (ok == true && amount > 0) {
    await Db.insert(Tx(amount: amount, merchant: m.text.trim(), category: categorize(m.text), date: DateTime.now()));
  }
}

// ───────────────────────── Tổng quan ─────────────────────────

class HomeScreen extends StatelessWidget {
  final void Function(int) onCapture;
  const HomeScreen({super.key, required this.onCapture});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return ValueListenableBuilder<int>(
      valueListenable: dbTick,
      builder: (_, __, ___) => FutureBuilder<List<List<Tx>>>(
        future: Future.wait<List<Tx>>([Db.month(now), Db.month(DateTime(now.year, now.month - 1))]),
        builder: (context, s) {
          final cur = s.data?[0] ?? <Tx>[];
          final prev = s.data?[1] ?? <Tx>[];
          final t = total(cur);
          final cats = byCategory(cur);
          return ListView(padding: const EdgeInsets.all(16), children: [
            _header('SpendWise AI'),
            const SizedBox(height: 12),
            Glass(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                sectionTitle('Quick Capture'),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  MintBtn('Quét hóa đơn', () => onCapture(0), filled: true),
                  MintBtn('Dán SMS', () => onCapture(1)),
                  MintBtn('Hợp đồng', () => onCapture(2)),
                  MintBtn('Nhập tay', () => _manualEntry(context)),
                ]),
              ]),
            ),
            const SizedBox(height: 12),
            Glass(
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    sectionTitle('Tháng ${now.month} · Tổng chi'),
                    Text(vnd(t), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(trend(cur, prev), style: const TextStyle(fontSize: 12, color: mint)),
                  ]),
                ),
                SizedBox(
                  width: 96,
                  height: 96,
                  child: cats.isEmpty
                      ? const SizedBox()
                      : PieChart(PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 28,
                          sections: [
                            for (final e in cats.entries)
                              PieChartSectionData(value: e.value.toDouble(), color: catColors[e.key], radius: 16, showTitle: false),
                          ],
                        )),
                ),
              ]),
            ),
            const SizedBox(height: 12),
            Glass(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                sectionTitle('Giao dịch gần đây (giữ để xóa)'),
                if (cur.isEmpty) const Text('Chưa có giao dịch.', style: TextStyle(color: sub)),
                for (final x in cur.take(5))
                  InkWell(
                    onLongPress: () => Db.delete(x.id!),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(children: [
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(x.merchant.isEmpty ? 'Không tên' : x.merchant, maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text('${x.category} · ${x.source}', style: const TextStyle(fontSize: 11, color: sub)),
                          ]),
                        ),
                        Text('-${vnd(x.amount)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ),
              ]),
            ),
            const SizedBox(height: 12),
            Glass(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                sectionTitle('Hạn mức tháng · ${vnd(kBudget)}'),
                LinearProgressIndicator(
                  value: (t / kBudget).clamp(0, 1).toDouble(),
                  minHeight: 10,
                  color: t > kBudget ? const Color(0xFFE6A08F) : mint,
                  backgroundColor: Colors.white12,
                  borderRadius: BorderRadius.circular(8),
                ),
              ]),
            ),
          ]);
        },
      ),
    );
  }
}

// ───────────────────────── Quét AI ─────────────────────────

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});
  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final textC = TextEditingController(), amountC = TextEditingController(), merchantC = TextEditingController();
  String cat = 'Khác';
  DateTime date = DateTime.now();
  bool analyzed = false, busy = false;
  Future<void> _pick(ImageSource src) async {
    final f = await ImagePicker().pickImage(source: src, maxWidth: 1600, imageQuality: 85);
    if (f == null) return;
    setState(() => busy = true);
    final rec = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final r = await rec
          .processImage(InputImage.fromFilePath(f.path))
          .timeout(const Duration(seconds: 30));
      textC.text = r.text;
      if (!mounted) return;
      setState(() => busy = false);
      _analyze();
    } catch (e) {
      if (!mounted) return;
      setState(() => busy = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Không đọc được ảnh: $e')));
    } finally {
      await rec.close();
    }
  }

  void _analyze() {
    final p = parse(textC.text, _modes[scanMode.value]);
    setState(() {
      amountC.text = '${p.amount}';
      merchantC.text = p.merchant;
      cat = p.category;
      date = p.date;
      analyzed = true;
    });
  }

  Future<void> _save() async {
    final a = int.tryParse(amountC.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final msg = ScaffoldMessenger.of(context);
    if (a <= 0) {
      msg.showSnackBar(const SnackBar(content: Text('Chưa có số tiền hợp lệ')));
      return;
    }
    await Db.insert(Tx(
      amount: a,
      merchant: merchantC.text.trim(),
      category: cat,
      date: date,
      source: _modes[scanMode.value],
      raw: textC.text,
    ));
    setState(() {
      textC.clear();
      analyzed = false;
    });
    msg.showSnackBar(const SnackBar(content: Text('Đã lưu vào dữ liệu trên máy')));
  }

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
        _header('Quét & trích xuất'),
        const SizedBox(height: 12),
        ValueListenableBuilder<int>(
          valueListenable: scanMode,
          builder: (_, m, __) => SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('Hóa đơn')),
              ButtonSegment(value: 1, label: Text('SMS')),
              ButtonSegment(value: 2, label: Text('Hợp đồng')),
            ],
            selected: {m},
            onSelectionChanged: (s) => scanMode.value = s.first,
          ),
        ),
        const SizedBox(height: 12),
        Glass(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            sectionTitle('Nguồn: ảnh (ML Kit OCR) hoặc dán văn bản'),
            Wrap(spacing: 8, children: [
              MintBtn('Chụp ảnh', busy ? null : () => _pick(ImageSource.camera), filled: true),
              MintBtn('Chọn ảnh', busy ? null : () => _pick(ImageSource.gallery)),
            ]),
            const SizedBox(height: 10),
            TextField(
              controller: textC,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'Dán tin nhắn ngân hàng / nội dung hợp đồng…',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            MintBtn(busy ? 'Đang đọc ảnh…' : 'Phân tích bằng Regex', busy ? null : _analyze),
          ]),
        ),
        if (analyzed) ...[
          const SizedBox(height: 12),
          Glass(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              sectionTitle('Kết quả AI (có thể sửa)'),
              TextField(controller: merchantC, decoration: const InputDecoration(labelText: 'Cửa hàng / nội dung')),
              TextField(controller: amountC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Số tiền (VND)')),
              const SizedBox(height: 8),
              Row(children: [
                Text('Ngày: ${dmy(date)}'),
                const Spacer(),
                DropdownButton<String>(
                  value: cat,
                  dropdownColor: const Color(0xFF24363F),
                  items: [for (final c in catColors.keys) DropdownMenuItem(value: c, child: Text(c))],
                  onChanged: (v) => setState(() => cat = v ?? cat),
                ),
              ]),
              const SizedBox(height: 8),
              SizedBox(width: double.infinity, child: MintBtn('Lưu vào dữ liệu máy', _save, filled: true)),
            ]),
          ),
        ],
      ]);
}

// ───────────────────────── Báo cáo ─────────────────────────

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});
  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  DateTime month = DateTime(DateTime.now().year, DateTime.now().month);
  int chart = 1; // 0 pie, 1 donut, 2 cột

  AxisTitles _noTitles() => const AxisTitles(sideTitles: SideTitles(showTitles: false));

  FlTitlesData _titles(String Function(int) label) => FlTitlesData(
        leftTitles: _noTitles(),
        rightTitles: _noTitles(),
        topTitles: _noTitles(),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            getTitlesWidget: (v, meta) => Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(label(v.toInt()), style: const TextStyle(fontSize: 10, color: sub)),
            ),
          ),
        ),
      );

  Widget _categoryChart(Map<String, int> m, int t) {
    if (m.isEmpty) return const SizedBox(height: 120, child: Center(child: Text('Chưa có dữ liệu')));
    final e = m.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    if (chart == 2) {
      return SizedBox(
        height: 190,
        child: BarChart(BarChartData(
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: _titles((i) => i < e.length ? e[i].key.split(' ').first : ''),
          barGroups: [
            for (var i = 0; i < e.length; i++)
              BarChartGroupData(x: i, barRods: [
                BarChartRodData(toY: e[i].value.toDouble(), color: catColors[e[i].key], width: 18, borderRadius: BorderRadius.circular(6)),
              ]),
          ],
        )),
      );
    }
    final donut = chart == 1;
    return Row(children: [
      SizedBox(
        width: 150,
        height: 150,
        child: PieChart(PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: donut ? 38 : 0,
          sections: [
            for (final x in e)
              PieChartSectionData(
                value: x.value.toDouble(),
                color: catColors[x.key],
                radius: donut ? 24 : 70,
                title: donut ? '' : '${(x.value * 100 / t).round()}%',
                titleStyle: const TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w600),
              ),
          ],
        )),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (final x in e)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Text('● ${x.key} ${(x.value * 100 / t).round()}%', style: TextStyle(fontSize: 12, color: catColors[x.key])),
            ),
        ]),
      ),
    ]);
  }

  Widget _weeklyChart(List<int> w) {
    final mx = w.reduce((a, b) => a > b ? a : b);
    return SizedBox(
      height: 150,
      child: BarChart(BarChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: _titles((i) => 'Tuần ${i + 1}'),
        barGroups: [
          for (var i = 0; i < w.length; i++)
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: w[i].toDouble(),
                color: (w[i] == mx && mx > 0) ? mint : peri,
                width: 26,
                borderRadius: BorderRadius.circular(8),
              ),
            ]),
        ],
      )),
    );
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
        valueListenable: dbTick,
        builder: (_, __, ___) => FutureBuilder<List<List<Tx>>>(
          future: Future.wait<List<Tx>>([Db.month(month), Db.month(DateTime(month.year, month.month - 1))]),
          builder: (context, s) {
            final cur = s.data?[0] ?? <Tx>[];
            final prev = s.data?[1] ?? <Tx>[];
            final t = total(cur);
            return ListView(padding: const EdgeInsets.all(16), children: [
              Row(children: [
                IconButton(onPressed: () => setState(() => month = DateTime(month.year, month.month - 1)), icon: const Icon(Icons.chevron_left)),
                Expanded(
                  child: Text('Báo cáo tháng ${month.month}/${month.year}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ),
                IconButton(onPressed: () => setState(() => month = DateTime(month.year, month.month + 1)), icon: const Icon(Icons.chevron_right)),
              ]),
              const SizedBox(height: 8),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text('Pie')),
                  ButtonSegment(value: 1, label: Text('Donut')),
                  ButtonSegment(value: 2, label: Text('Cột')),
                ],
                selected: {chart},
                onSelectionChanged: (v) => setState(() => chart = v.first),
              ),
              const SizedBox(height: 12),
              Glass(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  sectionTitle('Theo danh mục · ${vnd(t)}'),
                  _categoryChart(byCategory(cur), t == 0 ? 1 : t),
                ]),
              ),
              const SizedBox(height: 12),
              Glass(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  sectionTitle('Biến động chi tiêu theo tuần'),
                  _weeklyChart(weekly(cur)),
                ]),
              ),
              const SizedBox(height: 12),
              Glass(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('AI phân tích · on-device', style: TextStyle(fontSize: 13, color: mint)),
                  const SizedBox(height: 6),
                  Text(aiInsight(cur, prev), style: const TextStyle(height: 1.5)),
                ]),
              ),
            ]);
          },
        ),
      );
}
