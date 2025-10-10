import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/firestore_service.dart';

class TeamSelectionWidget extends StatelessWidget {
  final String title;
  final Color color;
  final List<String> players;
  final Map<String, int> goals;
  final int maxGoals;
  final List<PlayerRanking> allPlayers;
  final List<String> opposingTeamPlayers;
  final Function(String) onPlayerToggle;
  final Function(String, int) onGoalsChanged;

  const TeamSelectionWidget({
    super.key,
    required this.title,
    required this.color,
    required this.players,
    required this.goals,
    required this.maxGoals,
    required this.allPlayers,
    required this.opposingTeamPlayers,
    required this.onPlayerToggle,
    required this.onGoalsChanged,
  });

  Widget _buildGoalsField(String playerName) {
    return Container(
      width: 50,
      height: 30,
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: TextFormField(
        initialValue: goals[playerName]?.toString() ?? '0',
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(2),
        ],
        onChanged: (value) {
          final g = int.tryParse(value) ?? 0;
          onGoalsChanged(playerName, g);
        },
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: color,
        ),
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Lista de jogadores disponíveis
              Container(
                height: 120,
                padding: const EdgeInsets.all(8),
                child: allPlayers.isEmpty
                    ? Center(
                        child: Text(
                          'Nenhum jogador cadastrado',
                          style: TextStyle(
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: allPlayers.length,
                        itemBuilder: (context, index) {
                          final player = allPlayers[index];
                          final isSelected = players.contains(player.name);
                          final isInOtherTeam = opposingTeamPlayers.contains(player.name);

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isSelected,
                                  onChanged: isInOtherTeam
                                      ? null
                                      : (value) => onPlayerToggle(player.name),
                                  activeColor: color,
                                  visualDensity: VisualDensity.compact,
                                ),
                                Expanded(
                                  child: Text(
                                    player.name,
                                    style: TextStyle(
                                      color: isInOtherTeam
                                          ? Colors.grey
                                          : isDarkMode
                                              ? Colors.white
                                              : Colors.black87,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isSelected) ...[
                                  const SizedBox(width: 8),
                                  _buildGoalsField(player.name),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
              ),
              // Resumo
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${players.length} jogadores'),
                    Text(
                      'Total de gols: ${goals.values.fold(0, (sum, g) => sum + g)} / $maxGoals',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: goals.values.fold(0, (sum, g) => sum + g) == maxGoals
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}