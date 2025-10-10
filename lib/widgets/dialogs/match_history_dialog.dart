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
}