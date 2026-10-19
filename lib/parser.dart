// Trích xuất giao dịch từ văn bản (OCR hóa đơn, SMS ngân hàng, hợp đồng)
// hoàn toàn bằng Regex, chạy offline.

const _vi = {
  'a': 'àáạảãâầấậẩẫăằắặẳẵ',
  'e': 'èéẹẻẽêềếệểễ',
  'i': 'ìíịỉĩ',
  'o': 'òóọỏõôồốộổỗơờớợởỡ',
  'u': 'ùúụủũưừứựửữ',
  'y': 'ỳýỵỷỹ',
  'd': 'đ',
};

String noDiacritics(String s) {
  var r = s.toLowerCase();
  _vi.forEach((k, v) {
    for (final c in v.split('')) {
      r = r.replaceAll(c, k);
    }
  });
  return r;
}

const _catKeywords = <String, List<String>>{
  'Ăn uống': ['coffee', 'cafe', 'ca phe', 'highlands', 'pho ', 'com ', 'bun ', 'tra sua', 'nha hang', 'an uong', 'grabfood', 'shopeefood', 'banh', 'kfc', 'lotteria', 'quan an'],
  'Hóa đơn': ['dien', 'nuoc', 'internet', 'wifi', 'hop dong', 'vnpt', 'viettel', 'evn', 'hoa don', 'phi dich vu', 'thue bao', 'tien nha'],
  'Đi lại': ['grab', 'xang', 'taxi', 'gojek', 've xe', 'petrolimex', 'xe bus', 'gui xe'],
  'Mua sắm': ['shopee', 'lazada', 'tiki', 'winmart', 'coopmart', 'circle k', 'bach hoa', 'sieu thi', 'mua sam'],
  'Sức khỏe': ['thuoc', 'benh vien', 'pharmacity', 'phong kham', 'long chau'],
  'Giải trí': ['cgv', 'netflix', 'spotify', 'game', 'phim', 'karaoke'],
};

String categorize(String text) {
  final n = noDiacritics(text);
  for (final e in _catKeywords.entries) {
    if (e.value.any(n.contains)) return e.key;
  }
  return 'Khác';
}

class Parsed {
  final int amount;
  final String merchant, category;
  final DateTime date;
  const Parsed(this.amount, this.merchant, this.category, this.date);
}

int? _num(String s) {
  final d = s.replaceAll(RegExp(r'[^0-9]'), '');
  return d.isEmpty ? null : int.tryParse(d);
}

int? _amount(String norm, String source) {
  final noDate = norm.replaceAll(RegExp(r'\d{1,2}[/-]\d{1,2}(?:[/-]\d{2,4})?'), ' ');
  final kw = RegExp(
      r'(?:tong cong|tong tien|tong gia tri|gia tri hop dong|thanh toan|phai tra|total|so tien|tong|gd)[^\d\n]{0,20}([+-]?\d[\d.,]*\d)');
  final cur = RegExp(r'([+-]?\d{1,3}(?:[.,]\d{3})+|\d{4,})\s*(?:vnd|₫|d\b|dong)');
  final any = RegExp(r'(\d{1,3}(?:[.,]\d{3})+|\d{4,})');

  int? pick(RegExp r, {bool max = false}) {
    int? v;
    for (final m in r.allMatches(noDate)) {
      final n = _num(m[1]!);
      if (n == null || n < 1000 || n >= 10000000000) continue;
      if (max) {
        if (v == null || n > v) v = n;
      } else {
        v = n; // lấy số cuối cùng (tổng tiền thường nằm cuối)
      }
    }
    return v;
  }

  if (source == 'sms') {
    return pick(cur) ?? pick(kw) ?? pick(any, max: true);
  }
  return pick(kw) ?? pick(cur) ?? pick(any, max: true);
}

DateTime _date(String norm) {
  for (final m in RegExp(r'(\d{1,2})[/-](\d{1,2})(?:[/-](\d{2,4}))?').allMatches(norm)) {
    final d = int.parse(m[1]!), mo = int.parse(m[2]!);
    var y = m[3] != null ? int.parse(m[3]!) : DateTime.now().year;
    if (y < 100) y += 2000;
    if (d >= 1 && d <= 31 && mo >= 1 && mo <= 12) return DateTime(y, mo, d);
  }
  return DateTime.now();
}

String _merchant(String text, String source) {
  if (source == 'sms') {
    final m = RegExp(r'(?:ND|Nội dung|Noi dung|tại|tai)\s*[:\s]\s*([^\n.;]{3,40})',
            caseSensitive: false)
        .firstMatch(text);
    if (m != null) return m[1]!.trim();
  }
  final lines = text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty);
  for (final l in lines) {
    if (RegExp(r'[A-Za-zÀ-ỹ]{3}').hasMatch(l)) return l.length > 40 ? l.substring(0, 40) : l;
  }
  return 'Không rõ';
}

/// source: 'receipt' | 'sms' | 'contract'
Parsed parse(String text, String source) {
  final norm = noDiacritics(text);
  final merchant = _merchant(text, source);
  return Parsed(
    _amount(norm, source) ?? 0,
    merchant,
    categorize('$merchant $norm'),
    _date(norm),
  );
}
