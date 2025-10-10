import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/firestore_service.dart';
import '../components/team_selection_widget.dart';

class AddMatchDialog extends StatefulWidget {
  const AddMatchDialog({super.key});

  @override
  State<AddMatchDialog> createState() => _AddMatchDialogState();
}

class _AddMatchDialogState extends State<AddMatchDialog> {
  final _formKey = GlobalKey<FormState>();
  final _durationController = TextEditingController(text: '45 min');
  
  DateTime _selectedDate = DateTime.now();
  String _matchType = 'Amistoso';
  
  // Controle de placar
  int _orangeScore = 0;
  int _greenScore = 0;
  
  // Jogadores selecionados
  List<String> _orangePlayers = [];
  List<String> _greenPlayers = [];
  
  // Gols marcados
  Map<String, int> _orangeGoals = {};
  Map<String, int> _greenGoals = {};
  
  // Lista de todos os jogadores
  List<PlayerRanking> _allPlayers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    final service = FirestoreService();
    service.getRankingStream().listen((players) {
      if (mounted) {
        setState(() => _allPlayers = players);
      }
    });
  }

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveMatch() async {
    if (!_formKey.currentState!.validate()) return;

    if (_orangePlayers.isEmpty || _greenPlayers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione jogadores para ambos os times'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validar se os gols marcados correspondem ao placar
    int totalOrangeGoals = _orangeGoals.values.fold(0, (sum, goals) => sum + goals);
    int totalGreenGoals = _greenGoals.values.fold(0, (sum, goals) => sum + goals);

    if (totalOrangeGoals != _orangeScore) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gols do time Laranja ($totalOrangeGoals) não correspondem ao placar ($_orangeScore)'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (totalGreenGoals != _greenScore) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gols do time Verde ($totalGreenGoals) não correspondem ao placar ($_greenScore)'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = FirestoreService();
      
      // Preparar lista de gols
      List<PlayerGoal> orangeGoalsList = _orangeGoals.entries
          .where((e) => e.value > 0)
          .map((e) => PlayerGoal(playerName: e.key, goals: e.value))
          .toList();
      
      List<PlayerGoal> greenGoalsList = _greenGoals.entries
          .where((e) => e.value > 0)
          .map((e) => PlayerGoal(playerName: e.key, goals: e.value))
          .toList();

      // Registrar a partida
      final matchId = await service.addMatch(
        date: _selectedDate,
        orangeScore: _orangeScore,
        greenScore: _greenScore,
        duration: _durationController.text.trim(),
        matchType: _matchType,
        orangePlayers: _orangePlayers,
        greenPlayers: _greenPlayers,
        orangeGoals: orangeGoalsList,
        greenGoals: greenGoalsList,
      );

      if (matchId != null) {
        // Atualizar estatísticas dos jogadores
        await _updatePlayerStats();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Partida registrada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao registrar partida: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _updatePlayerStats() async {
    final service = FirestoreService();
    
    // Determinar resultado da partida
    bool isDraw = _orangeScore == _greenScore;
    bool orangeWon = _orangeScore > _greenScore;
    bool greenWon = _greenScore > _orangeScore;

    // Atualizar estatísticas dos jogadores do time Laranja
    for (String playerName in _orangePlayers) {
      // Buscar jogador atual
      PlayerRanking? player = _allPlayers.firstWhere(
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

      // Calcular novos valores
      int newGames = player.games + 1;
      int newWins = player.wins;
      int newDraws = player.draws;
      int newLosses = player.losses;
      int newPoints = player.points;
      int newGoals = player.goals + (_orangeGoals[playerName] ?? 0);

      if (isDraw) {
        newDraws += 1;
        newPoints += 1;
      } else if (orangeWon) {
        newWins += 1;
        newPoints += 3;
      } else {
        newLosses += 1;
        newPoints += 1;
      }

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

    // Atualizar estatísticas dos jogadores do time Verde
    for (String playerName in _greenPlayers) {
      // Buscar jogador atual
      PlayerRanking? player = _allPlayers.firstWhere(
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

      // Calcular novos valores
      int newGames = player.games + 1;
      int newWins = player.wins;
      int newDraws = player.draws;
      int newLosses = player.losses;
      int newPoints = player.points;
      int newGoals = player.goals + (_greenGoals[playerName] ?? 0);

      if (isDraw) {
        newDraws += 1;
        newPoints += 1;
      } else if (greenWon) {
        newWins += 1;
        newPoints += 3;
      } else {
        newLosses += 1;
        newPoints += 1;
      }

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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
      title: Row(
        children: [
          Icon(Icons.sports_soccer, color: Colors.green),
          const SizedBox(width: 12),
          const Text('Registrar Partida'),
        ],
      ),
      content: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Data e tipo da partida
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Data',
                            prefixIcon: const Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _matchType,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Tipo',
                          prefixIcon: const Icon(Icons.category),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: ['Amistoso', 'Campeonato', 'Treino', 'Final']
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(
                                    type,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() => _matchType = value!);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Duração
                TextFormField(
                  controller: _durationController,
                  decoration: InputDecoration(
                    labelText: 'Duração',
                    prefixIcon: const Icon(Icons.timer),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Digite a duração da partida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Placar
                Text(
                  'PLACAR',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Time Laranja
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: Colors.orange,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Laranja',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: _orangeScore > 0
                                      ? () => setState(() => _orangeScore--)
                                      : null,
                                ),
                                Text(
                                  '$_orangeScore',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () => setState(() => _orangeScore++),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Time Verde
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Verde',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: _greenScore > 0
                                      ? () => setState(() => _greenScore--)
                                      : null,
                                ),
                                Text(
                                  '$_greenScore',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () => setState(() => _greenScore++),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Jogadores do Time Laranja
                TeamSelectionWidget(
                  title: 'TIME LARANJA',
                  color: Colors.orange,
                  players: _orangePlayers,
                  goals: _orangeGoals,
                  maxGoals: _orangeScore,
                  allPlayers: _allPlayers,
                  opposingTeamPlayers: _greenPlayers,
                  onPlayerToggle: (player) {
                    setState(() {
                      if (_orangePlayers.contains(player)) {
                        _orangePlayers.remove(player);
                        _orangeGoals.remove(player);
                      } else if (!_greenPlayers.contains(player)) {
                        _orangePlayers.add(player);
                        _orangeGoals[player] = 0;
                      }
                    });
                  },
                  onGoalsChanged: (player, goals) {
                    setState(() => _orangeGoals[player] = goals);
                  },
                ),
                const SizedBox(height: 24),

                // Jogadores do Time Verde
                TeamSelectionWidget(
                  title: 'TIME VERDE',
                  color: Colors.green,
                  players: _greenPlayers,
                  goals: _greenGoals,
                  maxGoals: _greenScore,
                  allPlayers: _allPlayers,
                  opposingTeamPlayers: _orangePlayers,
                  onPlayerToggle: (player) {
                    setState(() {
                      if (_greenPlayers.contains(player)) {
                        _greenPlayers.remove(player);
                        _greenGoals.remove(player);
                      } else if (!_orangePlayers.contains(player)) {
                        _greenPlayers.add(player);
                        _greenGoals[player] = 0;
                      }
                    });
                  },
                  onGoalsChanged: (player, goals) {
                    setState(() => _greenGoals[player] = goals);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveMatch,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Registrar'),
        ),
      ],
    );
  }
}