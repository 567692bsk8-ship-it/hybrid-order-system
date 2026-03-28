import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_order_app/features/menu/data/menu_option_model.dart';
import 'package:mobile_order_app/features/menu/data/menu_repository.dart';
import 'package:mobile_order_app/features/order/providers/cart_provider.dart';
import 'package:mobile_order_app/features/order/data/order_model.dart';

class CustomizationScreen extends ConsumerStatefulWidget {
  final String itemName;
  final String imageUrl;
  final int price;
  final String category;

  const CustomizationScreen({
    super.key,
    required this.itemName,
    required this.imageUrl,
    required this.price,
    required this.category,
  });

  @override
  ConsumerState<CustomizationScreen> createState() => _CustomizationScreenState();
}

class _CustomizationScreenState extends ConsumerState<CustomizationScreen> {
  final List<String> _selectedOptions = [];
  int _additionalPrice = 0;
  String _noodleHardness = '普通';
  String _flavorIntensity = '普通';
  List<MenuOptionModel>? _options;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    try {
      final options = await ref.read(menuRepositoryProvider).watchOptionsByCategory(widget.category).first;
      if (mounted) {
        setState(() {
          _options = options;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        key: const PageStorageKey('customization_scroll'), // スクロール位置の保持
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(widget.imageUrl, fit: BoxFit.cover),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.itemName,
                      style: GoogleFonts.notoSansJp(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '¥${widget.price + _additionalPrice}',
                      style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF006241)),
                    ),
                    const Divider(height: 48),
                    
                    if (widget.category == 'ラーメン') ...[
                      _buildSectionTitle('麺の硬さ'),
                      _buildChipSelection(
                        ['柔らかめ', '普通', '硬め', 'バリカタ'],
                        _noodleHardness,
                        (val) => setState(() => _noodleHardness = val),
                      ),
                      const SizedBox(height: 32),
                      _buildSectionTitle('味の濃さ'),
                      _buildChipSelection(
                        ['薄め', '普通', '濃いめ'],
                        _flavorIntensity,
                        (val) => setState(() => _flavorIntensity = val),
                      ),
                      const SizedBox(height: 32),
                    ],

                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_options != null && _options!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('追加オプション / トッピング'),
                          _buildMultiChipSelection(_options!),
                        ],
                      ),
                    
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
      bottomSheet: _buildAddToCartButton(context),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: GoogleFonts.notoSansJp(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildChipSelection(List<String> options, String current, Function(String) onSelected) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: options.map((opt) => ChoiceChip(
        label: Text(opt),
        selected: current == opt,
        onSelected: (val) => onSelected(opt),
        selectedColor: const Color(0xFFD4E9E2),
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        side: BorderSide(color: current == opt ? const Color(0xFF006241) : Colors.grey.shade300),
        labelStyle: GoogleFonts.notoSansJp(
          fontSize: 14,
          color: current == opt ? const Color(0xFF006241) : Colors.black87,
          fontWeight: current == opt ? FontWeight.bold : FontWeight.normal,
        ),
      )).toList(),
    );
  }

  Widget _buildMultiChipSelection(List<MenuOptionModel> options) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: options.map((opt) {
        final isSelected = _selectedOptions.contains(opt.name);
        return FilterChip(
          label: Text('${opt.name} (+¥${opt.price})'),
          selected: isSelected,
          onSelected: (val) {
            setState(() {
              if (val) {
                _selectedOptions.add(opt.name);
                _additionalPrice += opt.price;
              } else {
                _selectedOptions.remove(opt.name);
                _additionalPrice -= opt.price;
              }
            });
          },
          selectedColor: const Color(0xFFD4E9E2),
          backgroundColor: Colors.white,
          checkmarkColor: const Color(0xFF006241),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          side: BorderSide(color: isSelected ? const Color(0xFF006241) : Colors.grey.shade300),
          labelStyle: GoogleFonts.notoSansJp(
            fontSize: 14,
            color: isSelected ? const Color(0xFF006241) : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddToCartButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: ElevatedButton(
        onPressed: () {
          final options = [
            if (widget.category == 'ラーメン') ...['麺:$_noodleHardness', '味:$_flavorIntensity'],
            ..._selectedOptions,
          ];
          
          final item = OrderItem(
            name: widget.itemName,
            quantity: 1,
            unitPrice: widget.price + _additionalPrice,
            selectedOptions: options,
          );
          
          ref.read(cartProvider.notifier).addItem(item);
          context.pop();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF006241),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        child: Text('カートに追加', style: GoogleFonts.notoSansJp(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}


