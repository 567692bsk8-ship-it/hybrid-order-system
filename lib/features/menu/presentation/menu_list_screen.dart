import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_order_app/features/menu/data/menu_model.dart';
import 'package:mobile_order_app/features/menu/data/menu_repository.dart';
import 'package:mobile_order_app/features/order/providers/cart_provider.dart';

import 'package:mobile_order_app/features/table/data/table_repository.dart';
import 'package:mobile_order_app/features/table/providers/table_provider.dart';

class MenuListScreen extends ConsumerStatefulWidget {
  final String? token;
  const MenuListScreen({super.key, this.token});

  @override
  ConsumerState<MenuListScreen> createState() => _MenuListScreenState();
}

class _MenuListScreenState extends ConsumerState<MenuListScreen> {
  String selectedCategory = 'ラーメン';
  String selectedSubCategory = 'すべて';
  bool _isValidating = false;
  bool _isValidTable = false;

  @override
  void initState() {
    super.initState();
    if (widget.token != null) {
      _validateTable();
    }
  }

  Future<void> _validateTable() async {
    setState(() => _isValidating = true);
    final table = await ref.read(tableRepositoryProvider).getTableByToken(widget.token!);
    if (table != null) {
      ref.read(currentTableProvider.notifier).setTable(table.tableNumber);
      ref.read(userRoleProvider.notifier).setRole(table.role);
      ref.read(authenticatedRoleProvider.notifier).setAuthenticatedRole(table.role);
      
      setState(() {
        _isValidTable = true;
        _isValidating = false;
      });

      // スタッフ権限の場合は直接管理画面へ
      if (table.role == 'staff' && mounted) {
        context.go('/staff-management');
      }
    } else {
      setState(() {
        _isValidTable = false;
        _isValidating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isValidating) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF006241)),
        ),
      );
    }

    if (!_isValidTable && widget.token != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 80, color: Colors.redAccent),
                const SizedBox(height: 24),
                Text('無効なアクセスです', style: GoogleFonts.notoSansJp(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text('お手数ですが、テーブルのQRコードを再度読み込んでください。', textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      );
    }

    final cartCount = ref.watch(cartProvider).length;
    final currentRole = ref.watch(userRoleProvider);
    final authRole = ref.watch(authenticatedRoleProvider);
    final menuStream = (currentRole == 'staff' || currentRole == 'developer')
        ? ref.watch(menuRepositoryProvider).watchAllMenu()
        : ref.watch(menuRepositoryProvider).watchMenu();
    final currentTable = ref.watch(currentTableProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('MENU', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 2)),
                const SizedBox(width: 8),
                _buildRoleBadge(currentRole),
                // 開発者専用：テーブル番号切り替えプルダウン
                if (authRole == 'developer')
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: _buildTableDropdown(currentTable, currentRole),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Color(0xFF006241)),
            onPressed: () => context.push('/history'),
          ),
          // 本来の権限が開発者であれば、いつでもロール切り替えが可能
          // 開発者専用：ロール切り替えランチャー
          if (authRole == 'developer')
            PopupMenuButton<String>(
              icon: const Icon(Icons.psychology_outlined, color: Colors.orange),
              onSelected: (role) => ref.read(userRoleProvider.notifier).setRole(role),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'customer', child: Text('利用者ビュー')),
                const PopupMenuItem(value: 'staff', child: Text('管理者ビュー')),
                const PopupMenuItem(value: 'developer', child: Text('開発者ビュー')),
              ],
            ),
          // スタッフまたは開発者のみ「注文管理」ボタンを表示
          if (currentRole == 'staff' || currentRole == 'developer')
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_outlined, color: Color(0xFF006241)),
              onPressed: () => context.push('/staff-management'),
              tooltip: '注文管理',
            ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.shopping_bag_outlined, color: Color(0xFF006241)),
                  if (cartCount > 0)
                    Positioned(
                      right: 0, top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                        child: Text('$cartCount', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      ),
                    ),
                ],
              ),
              onPressed: () => context.push('/cart'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 開発者モードバナー
          if (currentRole == 'developer')
            Container(
              width: double.infinity,
              color: Colors.orange.shade800,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: const Text(
                '● Developer モードでフルアクセス中',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          Expanded(
            child: StreamBuilder<List<MenuModel>>(
              stream: menuStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                final allMenus = snapshot.data!;
                final categories = ['ラーメン', 'つけ麺', 'サイド', 'ドリンク'];
                
                final subCategories = selectedCategory == 'ラーメン' 
                    ? ['すべて', '醤油', '味噌', '塩'] 
                    : <String>[];

                final filteredMenus = allMenus.where((m) {
                  final categoryMatch = m.category == selectedCategory;
                  final subCategoryMatch = selectedSubCategory == 'すべて' || m.subCategory == selectedSubCategory;
                  return categoryMatch && subCategoryMatch;
                }).toList();

                return Column(
                  children: [
                    Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          Container(
                            height: 70,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: ListView(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              scrollDirection: Axis.horizontal,
                              children: [
                                ...categories.map((c) => _buildCategoryChip(c)),
                                // 最後に「トッピング」チップを追加
                                Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: ActionChip(
                                    label: Text('トッピング', style: GoogleFonts.notoSansJp(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF006241))),
                                    avatar: const Icon(Icons.tune, size: 16, color: Color(0xFF006241)),
                                    backgroundColor: const Color(0xFFD4E9E2),
                                    onPressed: () => context.push('/option-management'),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            height: subCategories.isNotEmpty ? 64 : 0,
                            child: subCategories.isNotEmpty
                                ? ListView.builder(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: subCategories.length,
                                    itemBuilder: (context, index) => _buildSubCategoryChip(subCategories[index]),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          int crossAxisCount = constraints.maxWidth >= 900 ? 4 : (constraints.maxWidth >= 600 ? 3 : 2);
                          double aspectRatio = constraints.maxWidth >= 900 ? 0.75 : (constraints.maxWidth >= 600 ? 0.7 : 0.61);

                          return GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20,
                              childAspectRatio: aspectRatio,
                            ),
                            itemCount: filteredMenus.length,
                            itemBuilder: (context, index) => _buildMenuTile(context, filteredMenus[index], currentRole),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    Color color = (role == 'developer') ? Colors.orange.shade800 : const Color(0xFF006241);
    String label = (role == 'developer') ? 'Developer' : (role == 'staff' ? 'Staff' : 'Customer');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildTableDropdown(String currentTable, String role) {
    Color color = (role == 'developer') ? Colors.orange.shade800 : const Color(0xFF006241);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1),
      ),
      height: 24,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentTable.isEmpty ? 'Dev' : currentTable,
          isDense: true,
          items: ['Dev', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10']
              .map((val) => DropdownMenuItem(
                    value: val,
                    child: Text('T: $val', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold)),
                  ))
              .toList(),
          onChanged: (val) {
            if (val != null) {
              ref.read(currentTableProvider.notifier).setTable(val);
            }
          },
          icon: Icon(Icons.arrow_drop_down, color: color, size: 14),
          style: TextStyle(color: color),
          dropdownColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSubCategoryChip(String sub) {
    final isSelected = selectedSubCategory == sub;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => selectedSubCategory = sub),
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF006241) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? Colors.transparent : Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: Text(
              sub,
              style: GoogleFonts.notoSansJp(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() {
            selectedCategory = category;
            selectedSubCategory = 'すべて';
          }),
          borderRadius: BorderRadius.circular(32),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF006241) : Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: isSelected ? Colors.transparent : Colors.grey.shade300,
                width: 1.5,
              ),
              boxShadow: isSelected 
                  ? [BoxShadow(color: const Color(0xFF006241).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] 
                  : [],
            ),
            child: Text(
              category,
              style: GoogleFonts.notoSansJp(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context, MenuModel menu, String role) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: InkWell(
        onTap: () {
          if (role == 'staff' || role == 'developer') {
            // 管理者または開発者なら編集ダイアログを開く（後で実装）
            _showEditMenuDialog(context, menu);
          } else {
            // 一般利用者はカスタマイズ画面へ
            context.push('/customization', extra: {
              'name': menu.name,
              'imageUrl': menu.imageUrl,
              'price': menu.basePrice,
              'category': menu.category,
            });
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 110,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.asset(
                      menu.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.restaurant)),
                    ),
                  ),
                ),
                if (role == 'staff' || role == 'developer')
                  Positioned(
                    right: 8, top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.white70, shape: BoxShape.circle),
                      child: const Icon(Icons.edit, size: 16, color: Color(0xFF006241)),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(menu.name, style: GoogleFonts.notoSansJp(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1),
                  const SizedBox(height: 2),
                  // 説明文を薄いグレーで表示
                  Text(
                    menu.description,
                    style: GoogleFonts.notoSansJp(fontSize: 10, color: Colors.grey.shade600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text('¥${menu.basePrice}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF006241))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditMenuDialog(BuildContext context, MenuModel menu) {
    final nameController = TextEditingController(text: menu.name);
    final priceController = TextEditingController(text: menu.basePrice.toString());
    final descController = TextEditingController(text: menu.description);
    bool isAvailable = menu.isAvailable;
    String category = menu.category;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24, right: 24, top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('メニュー編集', style: GoogleFonts.notoSansJp(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: '商品名', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: category,
                        decoration: const InputDecoration(labelText: 'カテゴリー', border: OutlineInputBorder()),
                        items: ['ラーメン', 'つけ麺', 'サイド', 'ドリンク'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (val) => setModalState(() => category = val!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: '価格 (¥)', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: '商品説明', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('販売可能（品切れでない）'),
                  value: isAvailable,
                  activeColor: const Color(0xFF006241),
                  onChanged: (val) => setModalState(() => isAvailable = val),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('削除の確認'),
                              content: const Text('このメニューを削除してもよろしいですか？'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('キャンセル')),
                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('削除', style: TextStyle(color: Colors.red))),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await ref.read(menuRepositoryProvider).deleteMenu(menu.id);
                            if (context.mounted) Navigator.pop(context);
                          }
                        },
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                        child: const Text('削除'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final updatedMenu = menu.copyWith(
                            name: nameController.text,
                            basePrice: int.tryParse(priceController.text) ?? menu.basePrice,
                            description: descController.text,
                            category: category,
                            isAvailable: isAvailable,
                          );
                          await ref.read(menuRepositoryProvider).updateMenu(updatedMenu);
                          if (context.mounted) Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF006241),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('保存する'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
