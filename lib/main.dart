import 'package:flutter/material.dart';
import 'screens.dart';
import 'theme.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'SpendWise AI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(useMaterial3: true).copyWith(
          textTheme: ThemeData.dark().textTheme.apply(bodyColor: txt, displayColor: txt),
          colorScheme: const ColorScheme.dark(primary: mint, secondary: peri),
        ),
        home: const Shell(),
      );
}

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int i = 0;

  @override
  Widget build(BuildContext context) => Bg(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: IndexedStack(index: i, children: [
              HomeScreen(onCapture: (m) {
                scanMode.value = m;
                setState(() => i = 1);
              }),
              const ScanScreen(),
              const ReportScreen(),
            ]),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Glass(
              padding: EdgeInsets.zero,
              child: NavigationBar(
                height: 64,
                elevation: 0,
                backgroundColor: Colors.transparent,
                indicatorColor: mint,
                selectedIndex: i,
                onDestinationSelected: (v) => setState(() => i = v),
                destinations: const [
                  NavigationDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home_rounded, color: ink),
                      label: 'Tổng quan'),
                  NavigationDestination(
                      icon: Icon(Icons.document_scanner_outlined),
                      selectedIcon: Icon(Icons.document_scanner, color: ink),
                      label: 'Quét AI'),
                  NavigationDestination(
                      icon: Icon(Icons.pie_chart_outline),
                      selectedIcon: Icon(Icons.pie_chart, color: ink),
                      label: 'Báo cáo'),
                ],
              ),
            ),
          ),
        ),
      );
}
