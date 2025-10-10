import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/dialogs/add_player_dialog.dart';
import '../widgets/dialogs/add_match_dialog.dart';
import '../widgets/dialogs/manage_players_dialog.dart';
import '../widgets/dialogs/match_history_dialog.dart';
import '../widgets/dialogs/login_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isAuthenticated = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  // Verifica se o usuário já está logado
  Future<void> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isAuthenticated') ?? false;
    
    if (mounted) {
      setState(() {
        _isAuthenticated = isLoggedIn;
        _isLoading = false;
      });
    }
  }

  // Salva o estado de autenticação
  Future<void> _saveAuthStatus(bool isAuthenticated) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', isAuthenticated);
  }

  @override
  Widget build(BuildContext context) {
    // Tela de carregamento enquanto verifica autenticação
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.dark 
          ? Colors.grey[900] 
          : Colors.grey[100],
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_isAuthenticated) {
      return _buildLockedScreen(context);
    }
    return _buildUnlockedScreen(context);
  }

  // Tela quando o usuário NÃO está autenticado
  Widget _buildLockedScreen(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 24.0 : 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: isSmallScreen ? 80 : 100,
                  color: isDarkMode ? Colors.grey[700] : Colors.grey[400],
                ),
                const SizedBox(height: 24),
                Text(
                  'Área Restrita',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 24 : 28,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Faça login para acessar as configurações',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => _showLoginDialog(context),
                  icon: const Icon(Icons.login),
                  label: const Text('Fazer Login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 32 : 48,
                      vertical: isSmallScreen ? 14 : 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Tela quando o usuário ESTÁ autenticado
  Widget _buildUnlockedScreen(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com título e botão de logout
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Configurações',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 24 : 32,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Gerencie jogadores e partidas',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Botão de Logout
                  IconButton(
                    onPressed: () => _showLogoutDialog(context),
                    icon: const Icon(Icons.logout),
                    tooltip: 'Sair',
                    color: Colors.red,
                    iconSize: isSmallScreen ? 24 : 28,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Botões de ação
              Expanded(
                child: GridView.count(
                  crossAxisCount: isSmallScreen ? 1 : 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isSmallScreen ? 3 : 2.5,
                  children: [
                    _buildActionCard(
                      context: context,
                      icon: Icons.person_add,
                      title: 'Cadastrar Jogador',
                      subtitle: 'Adicione um novo jogador ao ranking',
                      color: Colors.blue,
                      onTap: () => _showAddPlayerDialog(context),
                      isDarkMode: isDarkMode,
                    ),
                    _buildActionCard(
                      context: context,
                      icon: Icons.sports_soccer,
                      title: 'Registrar Partida',
                      subtitle: 'Adicione uma nova partida ao histórico',
                      color: Colors.green,
                      onTap: () => _showAddMatchDialog(context),
                      isDarkMode: isDarkMode,
                    ),
                    _buildActionCard(
                      context: context,
                      icon: Icons.groups,
                      title: 'Gerenciar Jogadores',
                      subtitle: 'Visualize e edite jogadores existentes',
                      color: Colors.orange,
                      onTap: () => _showManagePlayersDialog(context),
                      isDarkMode: isDarkMode,
                    ),
                    _buildActionCard(
                      context: context,
                      icon: Icons.history,
                      title: 'Histórico Completo',
                      subtitle: 'Veja todas as partidas registradas',
                      color: Colors.purple,
                      onTap: () => _showMatchHistoryDialog(context),
                      isDarkMode: isDarkMode,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: isSmallScreen ? 24 : 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 11 : 12,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Dialog de login
  void _showLoginDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const LoginDialog(),
    );
    
    if (result == true && mounted) {
      setState(() {
        _isAuthenticated = true;
      });
      // Salva o estado de autenticação
      await _saveAuthStatus(true);
    }
  }

  // Dialog de confirmação de logout
  void _showLogoutDialog(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
        title: Text(
          'Sair',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        content: Text(
          'Deseja realmente sair?',
          style: TextStyle(
            color: isDarkMode ? Colors.grey[300] : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              setState(() {
                _isAuthenticated = false;
              });
              // Remove o estado de autenticação
              await _saveAuthStatus(false);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  // Diálogos existentes
  void _showAddPlayerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AddPlayerDialog(),
    );
  }

  void _showAddMatchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AddMatchDialog(),
    );
  }

  void _showManagePlayersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const ManagePlayersDialog(),
    );
  }

  void _showMatchHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const MatchHistoryDialog(),
    );
  }
}