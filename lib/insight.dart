import 'dart:math';
import 'data.dart';
import 'theme.dart';

int total(List<Tx> l) => l.fold(0, (s, t) => s + t.amount);

Map<String, int> byCategory(List<Tx> l) {
  final m = <String, int>{};
  for (final t in l) {
    m[t.category] = (m[t.category] ?? 0) + t.amount;
  }
  return m;
}

/// Tổng chi theo 5 tuần trong tháng (ngày 1-7, 8-14, ...).
List<int> weekly(List<Tx> l) {
  final w = List<int>.filled(5, 0);
  for (final t in l) {
    w[min((t.date.day - 1) ~/ 7, 4)] += t.amount;
  }
  return w;
}

String trend(List<Tx> cur, List<Tx> prev) {
  final t = total(cur), p = total(prev);
  if (p == 0) return 'Chưa có dữ liệu tháng trước';
  final d = ((t - p) * 100 / p).round();
  if (d >= 10) return 'Cao hơn tháng trước $d%';
  if (d <= -10) return 'Thấp hơn tháng trước ${-d}%';
  return 'Tương đương tháng trước';
}

/// "AI" phân tích bằng luật, chạy trên máy, không cần mạng.
String aiInsight(List<Tx> cur, List<Tx> prev) {
  if (cur.isEmpty) {
    return 'Chưa có giao dịch tháng này. Hãy quét hóa đơn hoặc dán tin nhắn ngân hàng để AI phân tích.';
  }
  final t = total(cur), p = total(prev);
  final cats = byCategory(cur).entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  final top = cats.first;
  final share = (top.value * 100 / t).round();
  final w = weekly(cur);
  final peak = w.indexOf(w.reduce(max));
  final b = StringBuffer();
  if (p == 0) {
    b.write('Chưa có dữ liệu tháng trước để so sánh. ');
  } else {
    final d = ((t - p) * 100 / p).round();
    if (d >= 10) {
      b.write('Tháng này bạn chi NHIỀU hơn tháng trước $d%. ');
    } else if (d <= -10) {
      b.write('Tháng này bạn chi ÍT hơn tháng trước ${-d}%. ');
    } else {
      b.write('Chi tiêu tháng này tương đương tháng trước ($d%). ');
    }
  }
  b.write('${top.key} chiếm $share% tổng chi, cao nhất. ');
  b.write('Tuần ${peak + 1} chi nhiều nhất (${vnd(w[peak])}).');
  if (share >= 45) b.write(' Hãy thử đặt hạn mức riêng cho mục ${top.key}.');
  if (t > kBudget) b.write(' Bạn đã vượt hạn mức tháng.');
  return b.toString();
}
