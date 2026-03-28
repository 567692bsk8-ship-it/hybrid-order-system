import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_order_app/features/menu/data/menu_option_model.dart';
import 'package:mobile_order_app/features/menu/data/menu_repository.dart';

class OptionManagementScreen extends ConsumerStatefulWidget {
  const OptionManagementScreen({super.key});

  @override
  ConsumerState<OptionManagementScreen> createState() => _OptionManagementScreenState();
}

class _OptionManagementScreenState extends ConsumerState<OptionManagementScreen> {
  String selectedCategory = 'ラーメン';

  @override
  Widget build(BuildContext context) {
    final optionStream = ref.watch(menuRepositoryProvider).watchOptionsByCategory(selectedCategory);

    return Scaffold(
      appBar: AppBar(
        title: Text('トッピング管理', style: GoogleFonts.notoSansJp(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // カテゴリー選択
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: ['ラーメン', 'つけ麺', 'サイド', 'ドリンク'].map((c) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(c),
                  selected: selectedCategory == c,
                  onSelected: (val) => setState(() => selectedCategory = c),
                  selectedColor: const Color(0xFFD4E9E2),
                  labelStyle: TextStyle(color: selectedCategory == c ? const Color(0xFF006241) : Colors.black87),
                ),
              )).toList(),
            ),
          ),
          
          Expanded(
            child: StreamBuilder<List<MenuOptionModel>>(
              stream: optionStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final options = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: options.length,
                  itemBuilder: (context, index) => _buildOptionCard(options[index]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditOptionDialog(null), // 新規追加
        backgroundColor: const Color(0xFF006241),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildOptionCard(MenuOptionModel option) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(option.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('¥${option.price}', style: const TextStyle(color: Color(0xFF006241), fontWeight: FontWeight.bold)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _showEditOptionDialog(option)),
            IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: () => _deleteOption(option)),
          ],
        ),
      ),
    );
  }

  void _showEditOptionDialog(MenuOptionModel? option) {
    final nameController = TextEditingController(text: option?.name ?? '');
    final priceController = TextEditingController(text: option?.price.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(option == null ? 'トッピング追加' : 'トッピング編集'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'トッピング名')),
            const SizedBox(height: 16),
            TextField(controller: priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '価格 (¥)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('キャンセル')),
          ElevatedButton(
            onPressed: () async {
              final newOption = MenuOptionModel(
                id: option?.id ?? '',
                name: nameController.text,
                price: int.tryParse(priceController.text) ?? 0,
                targetCategory: selectedCategory,
              );
              if (option == null) {
                await ref.read(menuRepositoryProvider).addOption(newOption);
              } else {
                await ref.read(menuRepositoryProvider).updateOption(newOption);
              }
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006241), foregroundColor: Colors.white),
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteOption(MenuOptionModel option) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除の確認'),
        content: Text('${option.name}を削除してよろしいですか？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('キャンセル')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('削除', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(menuRepositoryProvider).deleteOption(option.id);
    }
  }
}
