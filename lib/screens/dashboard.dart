import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  // Dados simulados das partidas
  final List<PartidaResultado> ultimasPartidas = [
    PartidaResultado(
      data: DateTime(2024, 1, 15),
      pontosLaranja: 3,
      pontosVerde: 1,
      duracao: '45 min',
      tipoPartida: 'Amistoso',
    ),
    PartidaResultado(
      data: DateTime(2024, 1, 14),
      pontosLaranja: 2,
      pontosVerde: 2,
      duracao: '50 min',
      tipoPartida: 'Campeonato',
    ),
    PartidaResultado(
      data: DateTime(2024, 1, 13),
      pontosLaranja: 1,
      pontosVerde: 4,
      duracao: '40 min',
      tipoPartida: 'Treino',
    ),
    PartidaResultado(
      data: DateTime(2024, 1, 12),
      pontosLaranja: 5,
      pontosVerde: 3,
      duracao: '55 min',
      tipoPartida: 'Campeonato',
    ),
    PartidaResultado(
      data: DateTime(2024, 1, 11),
      pontosLaranja: 2,
      pontosVerde: 3,
      duracao: '48 min',
      tipoPartida: 'Amistoso',
    ),
    PartidaResultado(
      data: DateTime(2024, 1, 10),
      pontosLaranja: 4,
      pontosVerde: 4,
      duracao: '60 min',
      tipoPartida: 'Final',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth < 900;
    
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 12.0 : 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título do Dashboard
              Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: isSmallScreen ? 24 : 32,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Últimas Partidas',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              
              // Cards das partidas
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = 1;
                  if (constraints.maxWidth > 900) {
                    crossAxisCount = 3;
                  } else if (constraints.maxWidth > 600) {
                    crossAxisCount = 2;
                  }
                  
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: isSmallScreen ? 2.2 : 1.8,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: ultimasPartidas.length,
                    itemBuilder: (context, index) {
                      return _buildPartidaCard(
                        ultimasPartidas[index], 
                        isDarkMode, 
                        isSmallScreen
                      );
                    },
                  );
                },
              ),
              
              // Estatísticas resumidas
              const SizedBox(height: 24),
              _buildEstatisticasResumo(isDarkMode, isSmallScreen, isMediumScreen),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPartidaCard(PartidaResultado partida, bool isDarkMode, bool isSmallScreen) {
    final vencedor = partida.pontosLaranja > partida.pontosVerde 
        ? 'Laranja' 
        : partida.pontosVerde > partida.pontosLaranja 
            ? 'Verde' 
            : 'Empate';
    
    return Container(
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
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho com data e tipo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    '${partida.data.day}/${partida.data.month}/${partida.data.year}',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 8 : 12, 
                      vertical: 4
                    ),
                    decoration: BoxDecoration(
                      color: _getCorTipoPartida(partida.tipoPartida),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      partida.tipoPartida,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 10 : 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            
            // Placar
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Time Laranja
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          isSmallScreen ? 'LAR' : 'Laranja',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 4 : 8),
                      Container(
                        width: isSmallScreen ? 18 : 24,
                        height: isSmallScreen ? 18 : 24,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.orange.shade700,
                            width: isSmallScreen ? 1.5 : 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Placar
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 16),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 8 : 16, 
                        vertical: isSmallScreen ? 4 : 8
                      ),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[700] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${partida.pontosLaranja} - ${partida.pontosVerde}',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 20 : 24,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Time Verde
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: isSmallScreen ? 18 : 24,
                        height: isSmallScreen ? 18 : 24,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.green.shade700,
                            width: isSmallScreen ? 1.5 : 2,
                          ),
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 4 : 8),
                      Flexible(
                        child: Text(
                          isSmallScreen ? 'VER' : 'Verde',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const Spacer(),
            
            // Rodapé com duração e vencedor
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: isSmallScreen ? 14 : 16,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          partida.duracao,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 11 : 13,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (vencedor != 'Empate')
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.emoji_events_outlined,
                          size: isSmallScreen ? 14 : 16,
                          color: vencedor == 'Laranja' ? Colors.orange : Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            isSmallScreen 
                              ? vencedor 
                              : 'Vitória $vencedor',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 11 : 13,
                              fontWeight: FontWeight.w600,
                              color: vencedor == 'Laranja' ? Colors.orange : Colors.green,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    'Empate',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 11 : 13,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstatisticasResumo(bool isDarkMode, bool isSmallScreen, bool isMediumScreen) {
    int vitoriasLaranja = 0;
    int vitoriasVerde = 0;
    int empates = 0;
    
    for (var partida in ultimasPartidas) {
      if (partida.pontosLaranja > partida.pontosVerde) {
        vitoriasLaranja++;
      } else if (partida.pontosVerde > partida.pontosLaranja) {
        vitoriasVerde++;
      } else {
        empates++;
      }
    }
    
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
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
      child: isSmallScreen 
        ? Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildEstatisticaItem(
                    'Vitórias LAR',
                    vitoriasLaranja.toString(),
                    Colors.orange,
                    isDarkMode,
                    isSmallScreen,
                  ),
                  _buildEstatisticaItem(
                    'Empates',
                    empates.toString(),
                    isDarkMode ? Colors.grey[400]! : Colors.grey[600]!,
                    isDarkMode,
                    isSmallScreen,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildEstatisticaItem(
                    'Vitórias VER',
                    vitoriasVerde.toString(),
                    Colors.green,
                    isDarkMode,
                    isSmallScreen,
                  ),
                  _buildEstatisticaItem(
                    'Total',
                    ultimasPartidas.length.toString(),
                    isDarkMode ? Colors.blue[400]! : Colors.blue,
                    isDarkMode,
                    isSmallScreen,
                  ),
                ],
              ),
            ],
          )
        : Wrap(
            spacing: isMediumScreen ? 20 : 40,
            runSpacing: 16,
            alignment: WrapAlignment.spaceAround,
            children: [
              _buildEstatisticaItem(
                'Vitórias Laranja',
                vitoriasLaranja.toString(),
                Colors.orange,
                isDarkMode,
                isSmallScreen,
              ),
              _buildEstatisticaItem(
                'Empates',
                empates.toString(),
                isDarkMode ? Colors.grey[400]! : Colors.grey[600]!,
                isDarkMode,
                isSmallScreen,
              ),
              _buildEstatisticaItem(
                'Vitórias Verde',
                vitoriasVerde.toString(),
                Colors.green,
                isDarkMode,
                isSmallScreen,
              ),
              _buildEstatisticaItem(
                'Total de Partidas',
                ultimasPartidas.length.toString(),
                isDarkMode ? Colors.blue[400]! : Colors.blue,
                isDarkMode,
                isSmallScreen,
              ),
            ],
          ),
    );
  }

  Widget _buildEstatisticaItem(String label, String valor, Color cor, bool isDarkMode, bool isSmallScreen) {
    return Column(
      children: [
        Text(
          valor,
          style: TextStyle(
            fontSize: isSmallScreen ? 24 : 32,
            fontWeight: FontWeight.bold,
            color: cor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: isSmallScreen ? 12 : 14,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Color _getCorTipoPartida(String tipo) {
    switch (tipo) {
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

class PartidaResultado {
  final DateTime data;
  final int pontosLaranja;
  final int pontosVerde;
  final String duracao;
  final String tipoPartida;

  PartidaResultado({
    required this.data,
    required this.pontosLaranja,
    required this.pontosVerde,
    required this.duracao,
    required this.tipoPartida,
  });
}