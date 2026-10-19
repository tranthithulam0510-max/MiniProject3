import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Hạn mức chi tiêu tháng (VND). Có thể chuyển sang bảng settings sau.
const kBudget = 10000000;

/// Tăng mỗi khi dữ liệu thay đổi để các màn hình tự tải lại.
final dbTick = ValueNotifier<int>(0);

class Tx {
  final int? id;
  final int amount;
  final String merchant, category, source, raw;
  final DateTime date;

  Tx({
    this.id,
    required this.amount,
    required this.merchant,
    required this.category,
    required this.date,
    this.source = 'manual',
    this.raw = '',
  });

  Map<String, Object?> toMap() => {
        'amount': amount,
        'merchant': merchant,
        'category': category,
        'date': date.millisecondsSinceEpoch,
        'source': source,
        'raw': raw,
      };

  factory Tx.fromMap(Map<String, Object?> m) => Tx(
        id: m['id'] as int,
        amount: m['amount'] as int,
        merchant: (m['merchant'] ?? '') as String,
        category: (m['category'] ?? 'Khác') as String,
        date: DateTime.fromMillisecondsSinceEpoch(m['date'] as int),
        source: (m['source'] ?? 'manual') as String,
        raw: (m['raw'] ?? '') as String,
      );
}

class Db {
  static Database? _db;

  static Future<Database> get db async =>
      _db ??= await openDatabase(
        p.join(await getDatabasesPath(), 'spendwise.db'),
        version: 1,
        onCreate: (d, _) => d.execute(
          'CREATE TABLE tx(id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'amount INTEGER NOT NULL, merchant TEXT, category TEXT, '
          'date INTEGER NOT NULL, source TEXT, raw TEXT)',
        ),
      );

  static Future<void> insert(Tx t) async {
    await (await db).insert('tx', t.toMap());
    dbTick.value++;
  }

  static Future<void> delete(int id) async {
    await (await db).delete('tx', where: 'id = ?', whereArgs: [id]);
    dbTick.value++;
  }

  static Future<List<Tx>> month(DateTime m) async {
    final from = DateTime(m.year, m.month).millisecondsSinceEpoch;
    final to = DateTime(m.year, m.month + 1).millisecondsSinceEpoch;
    final r = await (await db).query(
      'tx',
      where: 'date >= ? AND date < ?',
      whereArgs: [from, to],
      orderBy: 'date DESC, id DESC',
    );
    return r.map(Tx.fromMap).toList();
  }
}
