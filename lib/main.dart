import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart'; // Importa as opções geradas pelo FlutterFire CLI
import 'screens/dashboard.dart'; // Importa a nova tela de Dashboard
import 'screens/ranking.dart'; // Importa a tela de Ranking
import 'screens/settings.dart'; // Importa a tela de Configurações
import 'widgets/bar/app_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa o Firebase usando as opções geradas pelo FlutterFire CLI
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Faz login anônimo automaticamente
  await _signInAnonymously();
  
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  // Configura o app para desenhar atrás das barras do sistema
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const MyApp());
}

/// Função para fazer login anônimo
Future<void> _signInAnonymously() async {
  try {
    final FirebaseAuth auth = FirebaseAuth.instance;
    
    // Verifica se já existe um usuário logado
    if (auth.currentUser == null) {
      // Se não houver usuário, faz login anônimo
      UserCredential userCredential = await auth.signInAnonymously();
      print('Login anônimo realizado com sucesso: ${userCredential.user?.uid}');
    } else {
      print('Usuário já está logado: ${auth.currentUser?.uid}');
    }
  } catch (e) {
    print('Erro ao fazer login anônimo: $e');
    // Não interrompe a execução do app mesmo se houver erro
  }
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
      home: const AuthWrapper(),
    );
  }
}

/// Widget para gerenciar o estado de autenticação
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Enquanto verifica a autenticação, mostra loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Inicializando...'),
                ],
              ),
            ),
          );
        }
        
        // Se houver erro, tenta fazer login anônimo novamente
        if (snapshot.hasError) {
          return FutureBuilder(
            future: _signInAnonymously(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              // Após tentar login, vai para a tela principal
              return const MyHomePage(title: 'Flutter Demo Home Page');
            },
          );
        }
        
        // Se o usuário está autenticado (mesmo que anonimamente), vai para a tela principal
        if (snapshot.hasData && snapshot.data != null) {
          return const MyHomePage(title: 'Flutter Demo Home Page');
        }
        
        // Se não está autenticado, tenta fazer login anônimo
        return FutureBuilder(
          future: _signInAnonymously(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Autenticando...'),
                    ],
                  ),
                ),
              );
            }
            // Após login, vai para a tela principal
            return const MyHomePage(title: 'Flutter Demo Home Page');
          },
        );
      },
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
  NavItem _selected = NavItem.dashboard;
  bool _isCollapsed = true; // Inicia colapsada por padrão (para desktop)

  /// Retorna o conteúdo da página de acordo com o item selecionado
  Widget _buildPage() {
    switch (_selected) {
      case NavItem.dashboard:
        return DashboardScreen(); // Retorna a nova tela de Dashboard
      case NavItem.ranking:
        return RankingScreen(); // Retorna a tela de Ranking
      case NavItem.historico:
        return const Center(child: Text('Histórico'));
      case NavItem.configuracoes:
        return const SettingsScreen(); // Retorna a tela de Configurações
    }
  }

  @override
  Widget build(BuildContext context) {
    // Detecta se é mobile (largura menor que 600px)
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    
    if (isMobile) {
      // Layout para mobile com bottom navigation bar
      return Scaffold(
        body: SafeArea(
          bottom: false, // Permite que o conteúdo vá até a bottom bar
          child: _buildPage(),
        ),
        bottomNavigationBar: AppBottomBar(
          selected: _selected,
          onSelected: (item) {
            setState(() {
              _selected = item;
            });
          },
          logoAsset: 'assets/app_icon.png', // troque pelo seu asset
        ),
      );
    } else {
      // Layout para desktop/tablet com sidebar
      return Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              /// Sidebar para desktop
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
        ),
      );
    }
  }
}