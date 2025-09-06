import 'package:flutter/material.dart';
import 'widgets/bar/app_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  NavItem _selected = NavItem.dashboard;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  /// Retorna o conteúdo da página de acordo com o item selecionado
  Widget _buildPage() {
    switch (_selected) {
      case NavItem.dashboard:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Dashboard'),
              Text('Contador: $_counter'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _incrementCounter,
                child: const Text("Incrementar"),
              ),
            ],
          ),
        );
      case NavItem.ranking:
        return const Center(child: Text('Ranking'));
      case NavItem.historico:
        return const Center(child: Text('Histórico'));
      case NavItem.configuracoes:
        return const Center(child: Text('Configurações'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          /// Sidebar
          AppSidebar(
            selected: _selected,
            onSelected: (item) {
              setState(() {
                _selected = item;
              });
            },
            logoAsset: 'assets/app_icon.png', // troque pelo seu asset
            collapsible: true,
          ),

          /// Conteúdo principal
          Expanded(
            child: _buildPage(),
          ),
        ],
      ),
    );
  }
}
