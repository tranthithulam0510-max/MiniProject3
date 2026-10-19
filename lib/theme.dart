import 'dart:ui';
import 'package:flutter/material.dart';

const mint = Color(0xFF8FE6C0);
const peri = Color(0xFF8FA3D9);
const teal = Color(0xFF4FC7A0);
const ink = Color(0xFF133A2E);
const txt = Color(0xFFEEFAF4);
const sub = Color(0xFFBFE0D2);

const catColors = <String, Color>{
  'Ăn uống': mint,
  'Hóa đơn': peri,
  'Đi lại': teal,
  'Mua sắm': Color(0xFFC9D6F5),
  'Sức khỏe': Color(0xFF7FC8E8),
  'Giải trí': Color(0xFFB59BE0),
  'Khác': Color(0xFF9DB5AC),
};

String vnd(int v) =>
    '${v.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')} ₫';

String dmy(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

class Bg extends StatelessWidget {
  final Widget child;
  const Bg({super.key, required this.child});

  Widget _blob(double x, double y, Color c, double o) => Align(
        alignment: Alignment(x, y),
        child: Container(
          width: 260,
          height: 260,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [c.withOpacity(o), c.withOpacity(0)]),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3A5163), Color(0xFF1D2A34), Color(0xFF233F49)],
          ),
        ),
        child: Stack(fit: StackFit.expand, children: [
          _blob(1.0, -.3, mint, .35),
          _blob(-1.1, .3, const Color(0xFF50D296), .28),
          _blob(1.1, .8, peri, .3),
          child,
        ]),
      );
}

class Glass extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const Glass({super.key, required this.child, this.padding = const EdgeInsets.all(14)});

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white.withOpacity(.2), Colors.white.withOpacity(.06)],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: mint.withOpacity(.38)),
            ),
            child: child,
          ),
        ),
      );
}

class MintBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool filled;
  const MintBtn(this.label, this.onTap, {super.key, this.filled = false});

  @override
  Widget build(BuildContext context) => ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 44),
          backgroundColor: filled ? const Color(0xFF9EE6C8) : Colors.white.withOpacity(.14),
          foregroundColor: filled ? ink : txt,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: mint.withOpacity(.4)),
          ),
        ),
        child: Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
      );
}

Widget sectionTitle(String s) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(s, style: const TextStyle(fontSize: 13, color: sub)),
    );
