import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';

class AddPlayerDialog extends StatefulWidget {
  const AddPlayerDialog({super.key});

  @override
  State<AddPlayerDialog> createState() => _AddPlayerDialogState();
}

class _AddPlayerDialogState extends State<AddPlayerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _savePlayer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final service = FirestoreService();
      
      // Verificar se o jogador já existe
      final existingPlayer = await service.getPlayerByName(_nameController.text.trim());
      
      if (existingPlayer != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Jogador já existe!'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      // Adicionar novo jogador
      final playerId = await service.addPlayer(
        name: _nameController.text.trim(),
      );

      if (playerId != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jogador cadastrado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao cadastrar jogador: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
      title: Row(
        children: [
          Icon(Icons.person_add, color: Colors.blue),
          const SizedBox(width: 12),
          const Text('Cadastrar Jogador'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Nome do Jogador',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Digite o nome do jogador';
                }
                if (value.trim().length < 3) {
                  return 'Nome deve ter pelo menos 3 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text(
              'O jogador iniciará com 0 jogos, 0 gols e 0 pontos.',
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _savePlayer,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
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
              : const Text('Cadastrar'),
        ),
      ],
    );
  }
}