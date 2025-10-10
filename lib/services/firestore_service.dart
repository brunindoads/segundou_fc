import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo para dados do jogador no ranking
class PlayerRanking {
  final String id;
  final String name;
  final int games;
  final int wins;
  final int draws;
  final int losses;
  final int goals;
  final int points;
  final DateTime lastUpdated;

  PlayerRanking({
    required this.id,
    required this.name,
    required this.games,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.goals,
    required this.points,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  // Construtor para criar do Firestore
  factory PlayerRanking.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PlayerRanking(
      id: doc.id,
      name: data['name'] ?? '',
      games: data['games'] ?? 0,
      wins: data['wins'] ?? 0,
      draws: data['draws'] ?? 0,
      losses: data['losses'] ?? 0,
      goals: data['goals'] ?? 0,
      points: data['points'] ?? 0,
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Converter para Map para salvar no Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'games': games,
      'wins': wins,
      'draws': draws,
      'losses': losses,
      'goals': goals,
      'points': points,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }
}

/// Modelo para informações de gols de um jogador
class PlayerGoal {
  final String playerName;
  final int goals;
  final List<int> minutes; // Minutos em que os gols foram marcados (opcional)

  PlayerGoal({
    required this.playerName,
    required this.goals,
    this.minutes = const [],
  });

  // Converter de Map
  factory PlayerGoal.fromMap(Map<String, dynamic> map) {
    return PlayerGoal(
      playerName: map['playerName'] ?? '',
      goals: map['goals'] ?? 0,
      minutes: List<int>.from(map['minutes'] ?? []),
    );
  }

  // Converter para Map
  Map<String, dynamic> toMap() {
    return {
      'playerName': playerName,
      'goals': goals,
      'minutes': minutes,
    };
  }
}

/// Modelo para dados de partidas no histórico
class GameMatch {
  final String id;
  final DateTime date;
  final int orangeScore;
  final int greenScore;
  final String duration;
  final String matchType; // Amistoso, Campeonato, Treino, Final
  final List<String> orangePlayers;
  final List<String> greenPlayers;
  final List<PlayerGoal> orangeGoals; // Quem marcou gols no time laranja
  final List<PlayerGoal> greenGoals;  // Quem marcou gols no time verde
  final DateTime createdAt;

  GameMatch({
    required this.id,
    required this.date,
    required this.orangeScore,
    required this.greenScore,
    required this.duration,
    required this.matchType,
    required this.orangePlayers,
    required this.greenPlayers,
    required this.orangeGoals,
    required this.greenGoals,
    required this.createdAt,
  });

  // Construtor para criar do Firestore
  factory GameMatch.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Converter lista de maps para lista de PlayerGoal
    List<PlayerGoal> parseGoals(List<dynamic>? goalsList) {
      if (goalsList == null) return [];
      return goalsList.map((goal) => PlayerGoal.fromMap(goal as Map<String, dynamic>)).toList();
    }
    
    return GameMatch(
      id: doc.id,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      orangeScore: data['orangeScore'] ?? 0,
      greenScore: data['greenScore'] ?? 0,
      duration: data['duration'] ?? '',
      matchType: data['matchType'] ?? 'Amistoso',
      orangePlayers: List<String>.from(data['orangePlayers'] ?? []),
      greenPlayers: List<String>.from(data['greenPlayers'] ?? []),
      orangeGoals: parseGoals(data['orangeGoals']),
      greenGoals: parseGoals(data['greenGoals']),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Converter para Map para salvar no Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'date': Timestamp.fromDate(date),
      'orangeScore': orangeScore,
      'greenScore': greenScore,
      'duration': duration,
      'matchType': matchType,
      'orangePlayers': orangePlayers,
      'greenPlayers': greenPlayers,
      'orangeGoals': orangeGoals.map((g) => g.toMap()).toList(),
      'greenGoals': greenGoals.map((g) => g.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Helper para determinar o vencedor
  String get winner {
    if (orangeScore > greenScore) return 'Laranja';
    if (greenScore > orangeScore) return 'Verde';
    return 'Empate';
  }
}

/// Serviço principal para comunicação com Firestore
class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Referencias às collections
  CollectionReference get _rankingCollection => _firestore.collection('ranking');
  CollectionReference get _matchesCollection => _firestore.collection('matches');

  // Sistema de pontuação
  static const int POINTS_PER_WIN = 3;
  static const int POINTS_PER_DRAW = 1;
  static const int POINTS_PER_LOSS = 0;

  // ==================== RANKING METHODS ====================

  /// Buscar todos os jogadores do ranking ordenados por pontos
  Stream<List<PlayerRanking>> getRankingStream() {
    return _rankingCollection
        .orderBy('points', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PlayerRanking.fromFirestore(doc))
          .toList();
    });
  }

  /// Buscar um jogador específico por ID
  Future<PlayerRanking?> getPlayer(String playerId) async {
    try {
      DocumentSnapshot doc = await _rankingCollection.doc(playerId).get();
      if (doc.exists) {
        return PlayerRanking.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar jogador: $e');
      return null;
    }
  }

  /// Buscar jogador por nome
  Future<PlayerRanking?> getPlayerByName(String name) async {
    try {
      QuerySnapshot query = await _rankingCollection
          .where('name', isEqualTo: name)
          .limit(1)
          .get();
      
      if (query.docs.isNotEmpty) {
        return PlayerRanking.fromFirestore(query.docs.first);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar jogador por nome: $e');
      return null;
    }
  }

  /// Adicionar novo jogador ao ranking
  Future<String?> addPlayer({
    required String name,
    int games = 0,
    int wins = 0,
    int draws = 0,
    int losses = 0,
    int goals = 0,
  }) async {
    try {
      // Calcula pontos: 3 por vitória, 1 por empate, 0 por derrota
      int points = (wins * POINTS_PER_WIN) + (draws * POINTS_PER_DRAW) + (losses * POINTS_PER_LOSS);
      
      DocumentReference docRef = await _rankingCollection.add({
        'name': name,
        'games': games,
        'wins': wins,
        'draws': draws,
        'losses': losses,
        'goals': goals,
        'points': points,
        'lastUpdated': Timestamp.now(),
      });
      
      return docRef.id;
    } catch (e) {
      print('Erro ao adicionar jogador: $e');
      return null;
    }
  }

  /// Atualizar estatísticas de um jogador
  Future<bool> updatePlayer(String playerId, Map<String, dynamic> data) async {
    try {
      // Recalcula pontos se vitórias, empates ou derrotas foram atualizados
      if (data.containsKey('wins') || data.containsKey('draws') || data.containsKey('losses')) {
        DocumentSnapshot doc = await _rankingCollection.doc(playerId).get();
        if (doc.exists) {
          Map<String, dynamic> currentData = doc.data() as Map<String, dynamic>;
          int wins = data['wins'] ?? currentData['wins'] ?? 0;
          int draws = data['draws'] ?? currentData['draws'] ?? 0;
          int losses = data['losses'] ?? currentData['losses'] ?? 0;
          
          // Calcula pontos: 3 por vitória, 1 por empate, 0 por derrota
          data['points'] = (wins * POINTS_PER_WIN) + (draws * POINTS_PER_DRAW) + (losses * POINTS_PER_LOSS);
        }
      }
      
      data['lastUpdated'] = Timestamp.now();
      await _rankingCollection.doc(playerId).update(data);
      return true;
    } catch (e) {
      print('Erro ao atualizar jogador: $e');
      return false;
    }
  }

  /// Atualizar estatísticas específicas de um jogador (usado pelo add_match_dialog)
  Future<void> updatePlayerStats({
    required String playerName,
    required int games,
    required int wins,
    required int draws,
    required int losses,
    required int points,
    required int goals,
  }) async {
    try {
      // Buscar o jogador pelo nome
      final querySnapshot = await _rankingCollection
          .where('name', isEqualTo: playerName)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final playerId = querySnapshot.docs.first.id;
        
        // Atualizar as estatísticas do jogador
        await _rankingCollection.doc(playerId).update({
          'games': games,
          'wins': wins,
          'draws': draws,
          'losses': losses,
          'points': points,
          'goals': goals,
          'lastUpdated': Timestamp.now(),
        });
      } else {
        print('Jogador $playerName não encontrado para atualização');
      }
    } catch (e) {
      print('Erro ao atualizar estatísticas do jogador: $e');
      rethrow;
    }
  }

  /// Deletar jogador do ranking
  Future<bool> deletePlayer(String playerId) async {
    try {
      await _rankingCollection.doc(playerId).delete();
      return true;
    } catch (e) {
      print('Erro ao deletar jogador: $e');
      return false;
    }
  }

  // ==================== MATCHES METHODS ====================

  /// Buscar todas as partidas ordenadas por data
  Stream<List<GameMatch>> getMatchesStream() {
    return _matchesCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => GameMatch.fromFirestore(doc))
          .toList();
    });
  }

  /// Buscar últimas N partidas
  Stream<List<GameMatch>> getRecentMatches(int limit) {
    return _matchesCollection
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => GameMatch.fromFirestore(doc))
          .toList();
    });
  }

  /// Buscar partidas por tipo
  Stream<List<GameMatch>> getMatchesByType(String matchType) {
    return _matchesCollection
        .where('matchType', isEqualTo: matchType)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => GameMatch.fromFirestore(doc))
          .toList();
    });
  }

  /// Adicionar nova partida (SEM atualizar estatísticas automáticas)
  /// As estatísticas são atualizadas pelo add_match_dialog usando updatePlayerStats
  Future<String?> addMatch({
    required DateTime date,
    required int orangeScore,
    required int greenScore,
    required String duration,
    required String matchType,
    required List<String> orangePlayers,
    required List<String> greenPlayers,
    required List<PlayerGoal> orangeGoals,
    required List<PlayerGoal> greenGoals,
  }) async {
    try {
      DocumentReference docRef = await _matchesCollection.add({
        'date': Timestamp.fromDate(date),
        'orangeScore': orangeScore,
        'greenScore': greenScore,
        'duration': duration,
        'matchType': matchType,
        'orangePlayers': orangePlayers,
        'greenPlayers': greenPlayers,
        'orangeGoals': orangeGoals.map((g) => g.toMap()).toList(),
        'greenGoals': greenGoals.map((g) => g.toMap()).toList(),
        'createdAt': Timestamp.now(),
      });
      
      return docRef.id;
    } catch (e) {
      print('Erro ao adicionar partida: $e');
      return null;
    }
  }

  /// Atualizar partida existente
  Future<bool> updateMatch(String matchId, Map<String, dynamic> data) async {
    try {
      await _matchesCollection.doc(matchId).update(data);
      return true;
    } catch (e) {
      print('Erro ao atualizar partida: $e');
      return false;
    }
  }

  /// Deletar partida
  Future<bool> deleteMatch(String matchId) async {
    try {
      await _matchesCollection.doc(matchId).delete();
      return true;
    } catch (e) {
      print('Erro ao deletar partida: $e');
      return false;
    }
  }

  // ==================== HELPER METHODS ====================

  /// Buscar estatísticas gerais
  Future<Map<String, dynamic>> getGeneralStats() async {
    try {
      QuerySnapshot matchesSnapshot = await _matchesCollection.get();
      QuerySnapshot playersSnapshot = await _rankingCollection.get();
      
      int totalMatches = matchesSnapshot.docs.length;
      int totalPlayers = playersSnapshot.docs.length;
      int orangeWins = 0;
      int greenWins = 0;
      int draws = 0;
      int totalGoals = 0;
      
      for (var doc in matchesSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        int orangeScore = data['orangeScore'] ?? 0;
        int greenScore = data['greenScore'] ?? 0;
        
        totalGoals += orangeScore + greenScore;
        
        if (orangeScore > greenScore) {
          orangeWins++;
        } else if (greenScore > orangeScore) {
          greenWins++;
        } else {
          draws++;
        }
      }
      
      return {
        'totalMatches': totalMatches,
        'totalPlayers': totalPlayers,
        'orangeWins': orangeWins,
        'greenWins': greenWins,
        'draws': draws,
        'totalGoals': totalGoals,
        'averageGoalsPerMatch': totalMatches > 0 ? (totalGoals / totalMatches).toStringAsFixed(1) : '0',
      };
    } catch (e) {
      print('Erro ao buscar estatísticas gerais: $e');
      return {};
    }
  }
  
  /// Buscar artilheiros (top scorers)
  Future<List<PlayerRanking>> getTopScorers(int limit) async {
    try {
      QuerySnapshot snapshot = await _rankingCollection
          .orderBy('goals', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs
          .map((doc) => PlayerRanking.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Erro ao buscar artilheiros: $e');
      return [];
    }
  }
}