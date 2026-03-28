class TableModel {
  final String id;
  final String tableNumber; // 表示名（Staff, Dev なども可）
  final String token;
  final bool isActive;
  final String role; // customer, staff, developer

  TableModel({
    required this.id,
    required this.tableNumber,
    required this.token,
    required this.role,
    this.isActive = true,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id'] as String,
      tableNumber: json['tableNumber'] as String,
      token: json['token'] as String,
      role: json['role'] as String? ?? 'customer',
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tableNumber': tableNumber,
      'token': token,
      'role': role,
      'isActive': isActive,
    };
  }
}
