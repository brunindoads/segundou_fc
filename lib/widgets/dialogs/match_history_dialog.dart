import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';

class MatchHistoryDialog extends StatelessWidget {
  const MatchHistoryDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
      title: Row(
        children: [
          Icon(Icons.history, color: Colors.purple),
          const SizedBox(width: 12),
          const Text('Histórico de Partidas'),
        ],
      ),
      content: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 400),
        child: StreamBuilder<List<GameMatch>>(
          stream: FirestoreService().getMatchesStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'Nenhuma partida registrada',
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              );
            }

            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final match = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ExpansionTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getMatchTypeColor(match.matchType).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.sports_soccer,
                        color: _getMatchTypeColor(match.matchType),
                      ),
                    ),
                    title: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${match.orangeScore}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('x'),
                        ),
                        Text(
                          '${match.greenScore}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          match.matchType,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      '${match.date.day}/${match.date.month}/${match.date.year} - ${match.duration}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: () => _deleteMatch(context, match),
                      tooltip: 'Excluir partida',
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Time Laranja
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.group, color: Colors.orange, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Time Laranja:',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(match.orangePlayers.join(', ')),
                                      if (match.orangeGoals.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'Gols: ${match.orangeGoals.map((g) => '${g.playerName} (${g.goals})').join(', ')}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Time Verde
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.group, color: Colors.green, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Time Verde:',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(match.greenPlayers.join(', ')),
                                      if (match.greenGoals.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'Gols: ${match.greenGoals.map((g) => '${g.playerName} (${g.goals})').join(', ')}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
      ],
    );
  }

  Color _getMatchTypeColor(String type) {
    switch (type) {
      case 'Campeonato':
        return Colors.purple;
      case 'Final':
        return Colors.red;
      case 'Amistoso':
        return Colors.blue;
      case 'Treino':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  void _deleteMatch(BuildContext context, GameMatch match) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.orange),
            const SizedBox(width: 12),
            const Text('Confirmar exclusão'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Deseja realmente excluir esta partida?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Partida: ${match.orangeScore} x ${match.greenScore}',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            Text(
              'Data: ${match.date.day}/${match.date.month}/${match.date.year}',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'As estatísticas dos jogadores serão revertidas',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.orange[300] : Colors.orange[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Salva o Navigator antes de fechar o dialog
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              
              // Fecha o dialog de confirmação
              Navigator.of(dialogContext).pop();
              
              // Mostrar loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (loadingContext) => const Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Excluindo partida...'),
                        ],
                      ),
                    ),
                  ),
                ),
              );

              try {
                // Reverter estatísticas dos jogadores
                await _revertPlayerStats(match);
                
                // Excluir a partida
                await FirestoreService().deleteMatch(match.id);
                
                // Fecha o loading
                navigator.pop();
                
                // Mostra mensagem de sucesso
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Partida excluída com sucesso!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                // Fecha o loading
                navigator.pop();
                
                // Mostra mensagem de erro
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('Erro ao excluir partida: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Future<void> _revertPlayerStats(GameMatch match) async {
    final service = FirestoreService();
    
    // Determinar resultado da partida
    bool isDraw = match.orangeScore == match.greenScore;
    bool orangeWon = match.orangeScore > match.greenScore;
    bool greenWon = match.greenScore > match.orangeScore;

    // Buscar todos os jogadores atuais
    final allPlayers = await service.getRankingStream().first;

    // Criar map de gols por jogador
    Map<String, int> goalsMap = {};
    for (var goal in match.orangeGoals) {
      goalsMap[goal.playerName] = goal.goals;
    }
    for (var goal in match.greenGoals) {
      goalsMap[goal.playerName] = goal.goals;
    }

    // Reverter estatísticas dos jogadores do time Laranja
    for (String playerName in match.orangePlayers) {
      PlayerRanking? player = allPlayers.firstWhere(
        (p) => p.name == playerName,
        orElse: () => PlayerRanking(
          id: '',
          name: playerName,
          points: 0,
          games: 0,
          wins: 0,
          draws: 0,
          losses: 0,
          goals: 0,
        ),
      );

      if (player.id.isNotEmpty) {
        // Calcular novos valores (subtraindo os valores da partida)
        int newGames = player.games - 1;
        int newWins = player.wins - (orangeWon ? 1 : 0);
        int newDraws = player.draws - (isDraw ? 1 : 0);
        int newLosses = player.losses - (greenWon ? 1 : 0);
        int newGoals = player.goals - (goalsMap[playerName] ?? 0);
        int newPoints = player.points;

        if (isDraw) {
          newPoints -= 1;
        } else if (orangeWon) {
          newPoints -= 3;
        } else if (greenWon) {
          newPoints -= 1; // Derrota também perde 1 ponto
        }

        // Garantir que valores não fiquem negativos
        newGames = newGames < 0 ? 0 : newGames;
        newWins = newWins < 0 ? 0 : newWins;
        newDraws = newDraws < 0 ? 0 : newDraws;
        newLosses = newLosses < 0 ? 0 : newLosses;
        newGoals = newGoals < 0 ? 0 : newGoals;
        newPoints = newPoints < 0 ? 0 : newPoints;

        // Atualizar no Firestore
        await service.updatePlayerStats(
          playerName: playerName,
          games: newGames,
          wins: newWins,
          draws: newDraws,
          losses: newLosses,
          points: newPoints,
          goals: newGoals,
        );
      }
    }

    // Reverter estatísticas dos jogadores do time Verde
    for (String playerName in match.greenPlayers) {
      PlayerRanking? player = allPlayers.firstWhere(
        (p) => p.name == playerName,
        orElse: () => PlayerRanking(
          id: '',
          name: playerName,
          points: 0,
          games: 0,
          wins: 0,
          draws: 0,
          losses: 0,
          goals: 0,
        ),
      );

      if (player.id.isNotEmpty) {
        // Calcular novos valores (subtraindo os valores da partida)
        int newGames = player.games - 1;
        int newWins = player.wins - (greenWon ? 1 : 0);
        int newDraws = player.draws - (isDraw ? 1 : 0);
        int newLosses = player.losses - (orangeWon ? 1 : 0);
        int newGoals = player.goals - (goalsMap[playerName] ?? 0);
        int newPoints = player.points;

        if (isDraw) {
          newPoints -= 1;
        } else if (greenWon) {
          newPoints -= 3;
        } else if (orangeWon) {
          newPoints -= 1; // Derrota também perde 1 ponto
        }

        // Garantir que valores não fiquem negativos
        newGames = newGames < 0 ? 0 : newGames;
        newWins = newWins < 0 ? 0 : newWins;
        newDraws = newDraws < 0 ? 0 : newDraws;
        newLosses = newLosses < 0 ? 0 : newLosses;
        newGoals = newGoals < 0 ? 0 : newGoals;
        newPoints = newPoints < 0 ? 0 : newPoints;

        // Atualizar no Firestore
        await service.updatePlayerStats(
          playerName: playerName,
          games: newGames,
          wins: newWins,
          draws: newDraws,
          losses: newLosses,
          points: newPoints,
          goals: newGoals,
        );
      }
    }
  }
}