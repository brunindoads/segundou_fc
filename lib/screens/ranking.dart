import 'package:flutter/material.dart';

/// Uma classe para representar um jogador
class Player {
  final String name;
  final int games;
  final int wins;
  final int draws;
  final int losses;
  final int goals;
  late final int points; // Campo para a pontuação

  Player({
    required this.name,
    required this.games,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.goals,
  }) {
    // Calcula os pontos no construtor (3 por vitória, 1 por empate)
    points = (wins * 3) + (draws * 1);
  }
}

class RankingScreen extends StatelessWidget {
  RankingScreen({super.key});

  // Dados mockados para demonstração
  final List<Player> players = [
    // Usando a nova classe Player
    Player(name: 'Alice', games: 10, wins: 8, draws: 1, losses: 1, goals: 25),
    Player(name: 'Bob', games: 10, wins: 7, draws: 2, losses: 1, goals: 20),
    Player(name: 'Charlie', games: 10, wins: 6, draws: 3, losses: 1, goals: 18),
    Player(name: 'David', games: 10, wins: 5, draws: 2, losses: 3, goals: 15),
    Player(name: 'Eve', games: 10, wins: 4, draws: 4, losses: 2, goals: 12),
    Player(name: 'Frank', games: 10, wins: 3, draws: 3, losses: 4, goals: 10),
    Player(name: 'Grace', games: 10, wins: 2, draws: 5, losses: 3, goals: 8),
    Player(name: 'Heidi', games: 10, wins: 1, draws: 6, losses: 3, goals: 5),
    Player(name: 'Ivan', games: 10, wins: 0, draws: 2, losses: 8, goals: 3),
    Player(name: 'Judy', games: 10, wins: 0, draws: 1, losses: 9, goals: 2),
    Player(name: 'Alice', games: 10, wins: 8, draws: 1, losses: 1, goals: 25),
    Player(name: 'Bob', games: 10, wins: 7, draws: 2, losses: 1, goals: 20),
    Player(name: 'Charlie', games: 10, wins: 6, draws: 3, losses: 1, goals: 18),
    Player(name: 'David', games: 10, wins: 5, draws: 2, losses: 3, goals: 15),
    Player(name: 'Eve', games: 10, wins: 4, draws: 4, losses: 2, goals: 12),
    Player(name: 'Frank', games: 10, wins: 3, draws: 3, losses: 4, goals: 10),
    Player(name: 'Grace', games: 10, wins: 2, draws: 5, losses: 3, goals: 8),
    Player(name: 'Heidi', games: 10, wins: 1, draws: 6, losses: 3, goals: 5),
    Player(name: 'Ivan', games: 10, wins: 0, draws: 2, losses: 8, goals: 3),
    Player(name: 'Judy', games: 10, wins: 0, draws: 1, losses: 9, goals: 2),
    Player(name: 'Alice', games: 10, wins: 8, draws: 1, losses: 1, goals: 25),
    Player(name: 'Bob', games: 10, wins: 7, draws: 2, losses: 1, goals: 20),
    Player(name: 'Charlie', games: 10, wins: 6, draws: 3, losses: 1, goals: 18),
    Player(name: 'David', games: 10, wins: 5, draws: 2, losses: 3, goals: 15),
    Player(name: 'Eve', games: 10, wins: 4, draws: 4, losses: 2, goals: 12),
    Player(name: 'Frank', games: 10, wins: 3, draws: 3, losses: 4, goals: 10),
    Player(name: 'Grace', games: 10, wins: 2, draws: 5, losses: 3, goals: 8),
    Player(name: 'Heidi', games: 10, wins: 1, draws: 6, losses: 3, goals: 5),
    Player(name: 'Ivan', games: 10, wins: 0, draws: 2, losses: 8, goals: 3),
    Player(name: 'Judy', games: 10, wins: 0, draws: 1, losses: 9, goals: 2),
    Player(name: 'Alice', games: 10, wins: 8, draws: 1, losses: 1, goals: 25),
    Player(name: 'Bob', games: 10, wins: 7, draws: 2, losses: 1, goals: 20),
    Player(name: 'Charlie', games: 10, wins: 6, draws: 3, losses: 1, goals: 18),
    Player(name: 'David', games: 10, wins: 5, draws: 2, losses: 3, goals: 15),
    Player(name: 'Eve', games: 10, wins: 4, draws: 4, losses: 2, goals: 12),
    Player(name: 'Frank', games: 10, wins: 3, draws: 3, losses: 4, goals: 10),
    Player(name: 'Grace', games: 10, wins: 2, draws: 5, losses: 3, goals: 8),
    Player(name: 'Heidi', games: 10, wins: 1, draws: 6, losses: 3, goals: 5),
    Player(name: 'Ivan', games: 10, wins: 0, draws: 2, losses: 8, goals: 3),
    Player(name: 'Judy', games: 10, wins: 0, draws: 1, losses: 9, goals: 2),
  ];

  // Adiciona a lógica para ordenar os jogadores por pontos
  List<Player> get sortedPlayers {
    // Cria uma cópia da lista para não modificar a original
    final List<Player> sortedList = List.from(players);
    sortedList.sort((a, b) => b.points.compareTo(a.points));
    return sortedList;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ranking de Jogadores',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.resolveWith(
                      (states) => Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                    ),
                    columns: const [
                      DataColumn(label: Text('Posição')), // Nova coluna
                      DataColumn(label: Text('Nome')),
                      DataColumn(
                          label: Text('Pontos'), numeric: true), // Nova coluna
                      DataColumn(label: Text('Jogos'), numeric: true),
                      DataColumn(label: Text('Vitórias'), numeric: true),
                      DataColumn(label: Text('Empates'), numeric: true),
                      DataColumn(label: Text('Derrotas'), numeric: true),
                      DataColumn(label: Text('Gols'), numeric: true),
                    ],
                    rows: sortedPlayers.asMap().entries.map((entry) {
                      final int index = entry.key;
                      final Player player = entry.value;

                      return DataRow(cells: [
                        DataCell(
                            Text((index + 1).toString())), // Popula a posição
                        DataCell(Text(player.name)),
                        DataCell(Text(
                            player.points.toString())), // Popula a pontuação
                        DataCell(Text(player.games.toString())),
                        DataCell(Text(player.wins.toString())),
                        DataCell(Text(player.draws.toString())),
                        DataCell(Text(player.losses.toString())),
                        DataCell(Text(player.goals.toString())),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
