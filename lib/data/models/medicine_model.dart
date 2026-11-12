enum DosageForm {
  tablet('Tablet', 'Tablet'),
  capsule('Capsule', 'Capsule'),
  syrup('Syrup', 'ml'),
  injection('Injection', 'Ampoule'),
  cream('Cream', 'Tube'),
  drops('Drops', 'Drop'),
  other('Other', 'Unit');

  final String label;
  final String defaultUnitName;
  const DosageForm(this.label, this.defaultUnitName);
}

enum PackType {
  strip('Strip', true),
  bottle('Bottle', false),
  box('Box', false),
  vial('Vial', false),
  tube('Tube', false),
  other('Other', false);

  final String label;
  final bool defaultLooseEnabled;
  const PackType(this.label, this.defaultLooseEnabled);
}

class Medicine {
  final String id;
  final String name;
  final String genericName;
  final String categoryId;
  final String company;
  final DosageForm form;
  final PackType packType;
  final int unitsPerPack; // Tablets per strip, etc.
  final double salePrice; // Full pack sale price
  final double loosePrice; // Loose unit sale price
  final int minimumStockPacks; // Minimum stock in packs
  final String barcode;
  final bool isControlled; // Controlled drug yes/no
  final bool isLooseEnabled;

  const Medicine({
    required this.id,
    required this.name,
    required this.genericName,
    required this.categoryId,
    required this.company,
    required this.form,
    required this.packType,
    required this.unitsPerPack,
    required this.salePrice,
    required this.loosePrice,
    required this.minimumStockPacks,
    required this.barcode,
    this.isControlled = false,
    this.isLooseEnabled = true,
  });

  String get unitName => form.defaultUnitName;

  Medicine copyWith({
    String? id,
    String? name,
    String? genericName,
    String? categoryId,
    String? company,
    DosageForm? form,
    PackType? packType,
    int? unitsPerPack,
    double? salePrice,
    double? loosePrice,
    int? minimumStockPacks,
    String? barcode,
    bool? isControlled,
    bool? isLooseEnabled,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      genericName: genericName ?? this.genericName,
      categoryId: categoryId ?? this.categoryId,
      company: company ?? this.company,
      form: form ?? this.form,
      packType: packType ?? this.packType,
      unitsPerPack: unitsPerPack ?? this.unitsPerPack,
      salePrice: salePrice ?? this.salePrice,
      loosePrice: loosePrice ?? this.loosePrice,
      minimumStockPacks: minimumStockPacks ?? this.minimumStockPacks,
      barcode: barcode ?? this.barcode,
      isControlled: isControlled ?? this.isControlled,
      isLooseEnabled: isLooseEnabled ?? this.isLooseEnabled,
    );
  }
}

