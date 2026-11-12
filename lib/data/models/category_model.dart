class MedicineCategory {
  final String id;
  final String name;
  final String description;

  const MedicineCategory({
    required this.id,
    required this.name,
    this.description = '',
  });

  MedicineCategory copyWith({
    String? id,
    String? name,
    String? description,
  }) {
    return MedicineCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }
}

