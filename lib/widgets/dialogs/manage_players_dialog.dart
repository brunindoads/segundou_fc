import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';

class ManagePlayersDialog extends StatelessWidget {
  const ManagePlayersDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
      title: Row(
        children: [
          Icon(Icons.groups, color: Colors.orange),
          const SizedBox(width: 12),
          const Text('Gerenciar Jogadores'),
        ],
      ),
      content: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 400),
        child: StreamBuilder<List<PlayerRanking>>(
          stream: FirestoreService().getRankingStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'Nenhum jogador cadastrado',
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              );
            }

            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final player = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange,
                      child: Text(
                        '${index + 1}º',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(player.name),
                    subtitle: Text(
                      'Jogos: ${player.games} | Vitórias: ${player.wins} | Gols: ${player.goals}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${player.points} pts',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deletePlayer(context, player),
                        ),
                      ],
                    ),
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

  void _deletePlayer(BuildContext context, PlayerRanking player) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir ${player.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirestoreService().deletePlayer(player.id);
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Jogador excluído com sucesso'),
                    backgroundColor: Colors.green,
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
}