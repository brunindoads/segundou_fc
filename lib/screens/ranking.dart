import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho
              Text(
                'Ranking de Jogadores',
                style: TextStyle(
                  fontSize: isSmallScreen ? 24 : 32,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              
              // StreamBuilder para contar jogadores
              StreamBuilder<List<PlayerRanking>>(
                stream: FirestoreService().getRankingStream(),
                builder: (context, snapshot) {
                  final playerCount = snapshot.hasData ? snapshot.data!.length : 0;
                  return Text(
                    '$playerCount jogadores registrados',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              
              // Indicador de scroll horizontal para mobile
              if (isSmallScreen)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.swipe,
                        size: 16,
                        color: Colors.blue[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Deslize para navegar no ranking',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Tabela com dados do Firestore
              Expanded(
                child: StreamBuilder<List<PlayerRanking>>(
                  stream: FirestoreService().getRankingStream(),
                  builder: (context, snapshot) {
                    // Loading
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    
                    // Error
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Erro ao carregar ranking',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              snapshot.error.toString(),
                              style: TextStyle(
                                fontSize: 14,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                // Force rebuild
                                (context as Element).markNeedsBuild();
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    // No data
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhum jogador cadastrado',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Cadastre jogadores para aparecerem aqui',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    // Has data - build table
                    final players = snapshot.data!;
                    
                    return Container(
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[800] : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: _buildDataTable(players, isDarkMode, isSmallScreen),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataTable(List<PlayerRanking> players, bool isDarkMode, bool isSmallScreen) {
    return DataTable(
      columnSpacing: isSmallScreen ? 24 : 56,
      horizontalMargin: isSmallScreen ? 12 : 24,
      headingRowHeight: 48,
      dataRowHeight: isSmallScreen ? 48 : 52,
      headingRowColor: WidgetStateProperty.resolveWith(
        (states) => isDarkMode 
          ? Colors.grey[700] 
          : Colors.blue.withOpacity(0.1),
      ),
      headingTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: isSmallScreen ? 12 : 14,
        color: isDarkMode 
          ? Colors.white 
          : Colors.blue[800],
      ),
      dataTextStyle: TextStyle(
        fontSize: isSmallScreen ? 12 : 14,
        color: isDarkMode ? Colors.white70 : Colors.black87,
      ),
      columns: const [
        DataColumn(
          label: Text('Pos'),
        ),
        DataColumn(
          label: Text('Nome'),
        ),
        DataColumn(
          label: Text('Pontos'),
          numeric: true,
        ),
        DataColumn(
          label: Text('Jogos'),
          numeric: true,
        ),
        DataColumn(
          label: Text('V'),
          tooltip: 'Vitórias',
          numeric: true,
        ),
        DataColumn(
          label: Text('E'),
          tooltip: 'Empates',
          numeric: true,
        ),
        DataColumn(
          label: Text('D'),
          tooltip: 'Derrotas',
          numeric: true,
        ),
        DataColumn(
          label: Text('Gols'),
          numeric: true,
        ),
        DataColumn(
          label: Text('Aprov.'),
          tooltip: 'Aproveitamento (%)',
          numeric: true,
        ),
      ],
      rows: _buildRows(players, isDarkMode),
    );
  }

  List<DataRow> _buildRows(List<PlayerRanking> players, bool isDarkMode) {
    return players.asMap().entries.map((entry) {
      final int index = entry.key;
      final PlayerRanking player = entry.value;
      final bool isTop3 = index < 3;
      
      // Calcula aproveitamento
      final double aproveitamento = player.games > 0
          ? ((player.wins * 3 + player.draws * 1) / (player.games * 3)) * 100
          : 0;

      return DataRow(
        color: WidgetStateProperty.resolveWith((states) {
          if (isTop3) {
            if (index == 0) {
              return Colors.amber.withOpacity(isDarkMode ? 0.2 : 0.1);
            } else if (index == 1) {
              return Colors.grey[400]!.withOpacity(isDarkMode ? 0.2 : 0.1);
            } else if (index == 2) {
              return Colors.orange[700]!.withOpacity(isDarkMode ? 0.2 : 0.1);
            }
          }
          return null;
        }),
        cells: [
          // Posição
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isTop3)
                  Container(
                    margin: const EdgeInsets.only(right: 4),
                    child: Icon(
                      Icons.emoji_events,
                      size: 16,
                      color: index == 0
                          ? Colors.amber
                          : index == 1
                              ? Colors.grey
                              : Colors.orange[700],
                    ),
                  ),
                Text(
                  (index + 1).toString(),
                  style: TextStyle(
                    fontWeight: isTop3 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          // Nome
          DataCell(
            Text(
              player.name,
              style: TextStyle(
                fontWeight: isTop3 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          // Pontos
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                player.points.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
          // Jogos
          DataCell(Text(player.games.toString())),
          // Vitórias
          DataCell(
            Text(
              player.wins.toString(),
              style: TextStyle(
                color: Colors.green[isDarkMode ? 400 : 700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Empates
          DataCell(
            Text(
              player.draws.toString(),
              style: TextStyle(
                color: Colors.yellow[isDarkMode ? 400 : 700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Derrotas
          DataCell(
            Text(
              player.losses.toString(),
              style: TextStyle(
                color: Colors.red[isDarkMode ? 400 : 700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Gols
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.sports_soccer,
                  size: 14,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(player.goals.toString()),
              ],
            ),
          ),
          // Aproveitamento
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getAproveitamentoColor(aproveitamento).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${aproveitamento.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _getAproveitamentoColor(aproveitamento),
                ),
              ),
            ),
          ),
        ],
      );
    }).toList();
  }

  Color _getAproveitamentoColor(double aproveitamento) {
    if (aproveitamento >= 70) return Colors.green;
    if (aproveitamento >= 50) return Colors.orange;
    return Colors.red;
  }
}