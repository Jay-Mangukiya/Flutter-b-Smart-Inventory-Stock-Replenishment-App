import 'package:hive/hive.dart';

const int stockLogTypeId = 1;

enum StockLogType { stockIn, stockOut }

class StockLog extends HiveObject {
  String id;
  String productId;
  String productName;
  StockLogType type;
  double quantityChanged;
  double quantityBefore;
  double quantityAfter;
  String? note;
  DateTime timestamp;

  StockLog({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantityChanged,
    required this.quantityBefore,
    required this.quantityAfter,
    this.note,
    required this.timestamp,
  });
}

class StockLogAdapter extends TypeAdapter<StockLog> {
  @override
  final int typeId = stockLogTypeId;

  @override
  StockLog read(BinaryReader reader) {
    final id = reader.readString();
    final productId = reader.readString();
    final productName = reader.readString();
    final type = StockLogType.values[reader.readInt()];
    final quantityChanged = reader.readDouble();
    final quantityBefore = reader.readDouble();
    final quantityAfter = reader.readDouble();
    final noteRaw = reader.readString();
    final timestamp = DateTime.fromMillisecondsSinceEpoch(reader.readInt());

    return StockLog(
      id: id,
      productId: productId,
      productName: productName,
      type: type,
      quantityChanged: quantityChanged,
      quantityBefore: quantityBefore,
      quantityAfter: quantityAfter,
      note: noteRaw.isEmpty ? null : noteRaw,
      timestamp: timestamp,
    );
  }

  @override
  void write(BinaryWriter writer, StockLog obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.productId);
    writer.writeString(obj.productName);
    writer.writeInt(obj.type.index);
    writer.writeDouble(obj.quantityChanged);
    writer.writeDouble(obj.quantityBefore);
    writer.writeDouble(obj.quantityAfter);
    writer.writeString(obj.note ?? '');
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
  }
}
