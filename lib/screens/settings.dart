import 'package:flutter/material.dart';
import '../widgets/dialogs/add_player_dialog.dart';
import '../widgets/dialogs/add_match_dialog.dart';
import '../widgets/dialogs/manage_players_dialog.dart';
import '../widgets/dialogs/match_history_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              // Título
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
              // Ícone
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
              // Textos
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
              // Seta indicativa
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

  // Dialog para adicionar jogador
  void _showAddPlayerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AddPlayerDialog(),
    );
  }

  // Dialog para adicionar partida
  void _showAddMatchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AddMatchDialog(),
    );
  }

  // Dialog para gerenciar jogadores
  void _showManagePlayersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const ManagePlayersDialog(),
    );
  }

  // Dialog para histórico de partidas
  void _showMatchHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const MatchHistoryDialog(),
    );
  }
}