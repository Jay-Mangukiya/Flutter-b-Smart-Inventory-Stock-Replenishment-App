import 'package:hive/hive.dart';

const int productTypeId = 0;

class Product extends HiveObject {
  String id;
  String name;
  String category;
  double quantity;
  double minThreshold;
  DateTime createdAt;
  DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.minThreshold,
    required this.createdAt,
    required this.updatedAt,
  });

  StockStatus get stockStatus {
    if (quantity <= 0) return StockStatus.outOfStock;
    if (quantity <= minThreshold * 0.5) return StockStatus.critical;
    if (quantity <= minThreshold) return StockStatus.low;
    return StockStatus.normal;
  }

  bool get isLowStock => quantity <= minThreshold;
  bool get isOutOfStock => quantity <= 0;
}

enum StockStatus { normal, low, critical, outOfStock }

class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = productTypeId;

  @override
  Product read(BinaryReader reader) {
    return Product(
      id: reader.readString(),
      name: reader.readString(),
      category: reader.readString(),
      quantity: reader.readDouble(),
      minThreshold: reader.readDouble(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.category);
    writer.writeDouble(obj.quantity);
    writer.writeDouble(obj.minThreshold);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    writer.writeInt(obj.updatedAt.millisecondsSinceEpoch);
  }
}
