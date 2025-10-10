import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth < 900;
    
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
      body: StreamBuilder<List<GameMatch>>(
        stream: FirestoreService().getRecentMatches(6), // Busca as últimas 6 partidas
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
                    'Erro ao carregar partidas',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            );
          }

          // No data
          final ultimasPartidas = snapshot.data ?? [];

          return SingleChildScrollView(
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
                    ultimasPartidas.isEmpty 
                      ? 'Nenhuma partida registrada' 
                      : 'Últimas Partidas',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Cards das partidas
                  if (ultimasPartidas.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.sports_soccer,
                              size: 64,
                              color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhuma partida cadastrada ainda',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
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
                  if (ultimasPartidas.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildEstatisticasResumo(
                      ultimasPartidas, 
                      isDarkMode, 
                      isSmallScreen, 
                      isMediumScreen
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPartidaCard(GameMatch partida, bool isDarkMode, bool isSmallScreen) {
    final vencedor = partida.orangeScore > partida.greenScore 
        ? 'Laranja' 
        : partida.greenScore > partida.orangeScore 
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
                    '${partida.date.day}/${partida.date.month}/${partida.date.year}',
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
                      color: _getCorTipoPartida(partida.matchType),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      partida.matchType,
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
                          '${partida.orangeScore} - ${partida.greenScore}',
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
                          partida.duration,
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

  Widget _buildEstatisticasResumo(
    List<GameMatch> partidas, 
    bool isDarkMode, 
    bool isSmallScreen, 
    bool isMediumScreen
  ) {
    int vitoriasLaranja = 0;
    int vitoriasVerde = 0;
    int empates = 0;
    
    for (var partida in partidas) {
      if (partida.orangeScore > partida.greenScore) {
        vitoriasLaranja++;
      } else if (partida.greenScore > partida.orangeScore) {
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
                    partidas.length.toString(),
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
                partidas.length.toString(),
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