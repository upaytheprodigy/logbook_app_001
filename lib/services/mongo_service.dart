import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logbook_app_001/helpers/log_helper.dart';
import 'package:logbook_app_001/features/logbook/models/log_model.dart';

class MongoService {
  static final MongoService _instance = MongoService._internal();

  Db? _db;
  DbCollection? _collection;

  final String _source = "mongo_service.dart";
  factory MongoService() {
    return _instance;
  }

  MongoService._internal();

  Future<DbCollection> _getSafeCollection() async {
    if (_db == null || ! _db!.isConnected || _collection == null) {
      await LogHelper.writeLog(
        "INFO: Koleksi belum siap, mencoba koneksi ulang...",
        source: _source,
        level: 3,
      );
      await connect();
    }
    return _collection!;
  }
  
  // Inisialisai koneksi ke MongoDB Atlas
  Future<void> connect() async {
    try {
      final dbUri = dotenv.env['MONGO_URI'];
      if (dbUri == null)throw Exception("MONGO_URI tidak ditemukan di .env");

      _db = await Db.create(dbUri);

      //Timeout 15 detik agar lebih toleran terhadap jaringan seluler
      await _db!.open().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception(
            "Koneksi Timeout. Cek IP Whitelist (0.0.0.0/0) atau Sinyal HP."
          );
        },
      );

      _collection = _db!.collection('logs');

      await LogHelper.writeLog(
        "DATABASE: Terhubung & Koleksi Siap",
        source: _source,
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "DATABASE ERROR: $e",
        source: _source,
        level: 1,
      );
      rethrow; // Biarkan error ini ditangani di UI untuk menampilkan pesan ke pengguna
    }
  }

  // READ: Ambil semua log dari database
  Future<List<LogModel>> getLogs() async {
    try {
      final collection = await _getSafeCollection();

      await LogHelper.writeLog(
        "INFO: Fetching data from Cloud...",
        source: _source,
        level: 3,
      );

      final List<Map<String, dynamic>> data = await collection.find().toList();
      return data.map((json) => LogModel.fromMap(json)).toList();
    } catch (e) {
      await LogHelper.writeLog(
        "ERROR: Fetch failed - $e",
        source: _source,
        level: 1,
      );
      return []; // Kembalikan list kosong jika terjadi error
    }
  }

  // CREATE: Menambahkan data baru
  Future<void> insertLog(LogModel log) async {
    try {
      final collection = await _getSafeCollection();
      await collection.insertOne(log.toMap());

      await LogHelper.writeLog(
        "SUCCESS: Data '${log.title}' Saved to Cloud",
        source: _source,
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "ERROR: Insert failed - $e",
        source: _source,
        level: 1,
      );
      rethrow;
    }
  }
  
  // UPDATE: Update data berdasarkan ID
  Future<void> updateLog(LogModel log) async {
    try {
      final collection = await _getSafeCollection();
      if (log.id == null) throw Exception("Log ID tidak ditemukan untuk update");
      await collection.replaceOne(where.id(log.id!), log.toMap());

      await LogHelper.writeLog(
        "SUCCESS: Data '${log.title}' Updated in Cloud",
        source: _source,
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "ERROR: Update failed - $e",
        source: _source,
        level: 1,
      );
      rethrow;
    }
  }
 
  // DELETE: Menghapus dokumen berdasarkan ID
  Future<void> deleteLog(ObjectId id) async {
    try {
      final collection = await _getSafeCollection();
      await collection.deleteOne(where.id(id));

      await LogHelper.writeLog(
        "SUCCESS: Data with ID '$id' Deleted from Cloud",
        source: _source,
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "ERROR: Delete failed - $e",
        source: _source,
        level: 1,
      );
      rethrow;
    }
  }

  Future<void> close() async {
    if (_db != null) {
      await _db !.close();
      await LogHelper.writeLog(
        "INFO: Database connection closed",
        source: _source,
        level: 2,
      );
    }
  }
}
