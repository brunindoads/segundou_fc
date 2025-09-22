import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/ranking.dart'; // Importa a nova tela de Ranking
import 'widgets/bar/app_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color.fromARGB(255, 1, 102, 43),
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
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
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
          surface: Colors.grey[850],
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system, // Respeita o tema do dispositivo
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
  bool _isCollapsed = true; // Inicia colapsada por padrão

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
        return RankingScreen(); // Retorna a nova tela de Ranking
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
            isCollapsed: _isCollapsed,
            onSelected: (item) {
              setState(() {
                _selected = item;
                _isCollapsed = true; // Colapsa após selecionar
              });
            },
            onCollapse: () {
              setState(() {
                _isCollapsed = !_isCollapsed; // Inverte o estado da barra
              });
            },
            logoAsset: 'assets/app_icon.png', // troque pelo seu asset
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
