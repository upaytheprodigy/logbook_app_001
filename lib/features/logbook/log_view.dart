import 'package:flutter/material.dart';
import 'package:logbook_app_001/features/logbook/models/log_model.dart';
import 'package:logbook_app_001/features/onboarding/onboarding_view.dart';
import 'package:logbook_app_001/helpers/log_helper.dart';
import 'package:logbook_app_001/services/mongo_service.dart';
import 'package:intl/intl.dart';


class LogView extends StatefulWidget {
  final String username;

  const LogView({super.key, required this.username});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  final MongoService _mongoService = MongoService();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  List<LogModel> _logs = [];

  String _selectedCategory = "Pribadi";

  final List<String> _categories = ["Pekerjaan", "Pribadi", "Urgent"];

  late Future<List<LogModel>> _logsFuture;
  @override
  void initState() {
    super.initState();
    _logsFuture = _initialize();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<List<LogModel>> _initialize() async {
    try {
      await LogHelper.writeLog(
        "UI: Menghubungi MongoService.connect()...",
        source: "log_view.dart",
      );

      await _mongoService.connect();

      final logs = await _mongoService.getLogs();

      await LogHelper.writeLog(
        "UI: Data berhasil dimuat (${logs.length} item).",
        source: "log_view.dart",
      );

      return logs;
    } catch (e) {
      await LogHelper.writeLog(
        "UI ERROR: $e",
        source: "log_view.dart",
        level: 1,
      );

      rethrow;
    }
  }

  void _refresh() {
    setState(() {
      _logsFuture = _mongoService.getLogs();
    });
  }

  // Category
  Icon _getCategoryIcon(String category) {
    switch (category) {
      case "Pekerjaan":
        return const Icon(Icons.work_outline, color: Colors.blue);
      case "Urgent":
        return const Icon(Icons.warning_amber_rounded, color: Colors.red);
      case "Pribadi":
        return const Icon(Icons.person_outline, color: Colors.green);
      default:
        return const Icon(Icons.note);
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case "Pekerjaan":
        return Colors.blue.shade50;
      case "Urgent":
        return Colors.red.shade50;
      case "Pribadi":
        return Colors.green.shade50;
      default:
        return Colors.grey.shade200;
    }
  }

  // ADD LOG
  void _showAddLogDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Tambah Catatan Baru"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: "Judul Catatan",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                hintText: "Isi Deskripsi",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              items: _categories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: "Kategori",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              final newLog = LogModel(
                title: _titleController.text,
                description: _contentController.text,
                category: _selectedCategory,
                date: DateTime.now(),
              );

              await _mongoService.insertLog(newLog);

              await LogHelper.writeLog(
                "UI: Log baru ditambahkan (${newLog.title})",
                source: "log_view.dart",
              );

              _titleController.clear();
              _contentController.clear();
              Navigator.pop(context);

              _refresh();
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  // EDIT LOG
  void _showEditLogDialog(LogModel log) {
    _titleController.text = log.title;
    _contentController.text = log.description;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Catatan"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _titleController),
            const SizedBox(height: 12),
            TextField(controller: _contentController),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedLog = LogModel(
                id: log.id,
                title: _titleController.text,
                description: _contentController.text,
                category: log.category,
                date: log.date,
              );

              await _mongoService.updateLog(updatedLog);

              await LogHelper.writeLog(
                "UI: Log diperbarui (${updatedLog.title})",
                source: "log_view.dart",
              );

              _titleController.clear();
              _contentController.clear();
              Navigator.pop(context);

              _refresh();
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  // DELETE LOG
  Future<void> _deleteLog(LogModel log) async {
    await _mongoService.deleteLog(log.id!);

    await LogHelper.writeLog(
      "UI: Log dihapus (${log.title})",
      source: "log_view.dart",
      level: 1,
    );

    _refresh();
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Konfirmasi Logout"),
        content: const Text("Apakah Anda yakin ingin keluar?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const OnboardingView()),
                (route) => false,
              );
            },
            child: const Text(
              "Ya, Keluar",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // BUILD
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          "Logbook: ${widget.username}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),

      body: FutureBuilder<List<LogModel>>(
        future: _logsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            // Connection Guard: Friendly offline warning
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 48, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  const Text(
                    "Tidak dapat terhubung ke server.\nPeriksa koneksi internet Anda atau coba lagi nanti.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.redAccent),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Detail: \\${snapshot.error}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final logs = snapshot.data ?? [];

          if (logs.isEmpty) {
            return const Center(child: Text("Belum ada data"));
          }

          // Pull-to-Refresh: Wrap ListView with RefreshIndicator
          return RefreshIndicator(
            onRefresh: () async {
              _refresh();
              // Wait for logs to reload
              await _logsFuture;
            },
            child: ListView.builder(
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];

                return Card(
                  color: _getCategoryColor(log.category),
                  child: ListTile(
                    leading: _getCategoryIcon(log.category),
                    title: Text(log.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(log.description),
                        const SizedBox(height: 4),
                        Builder(
                          builder: (context) {
                            // Format date using intl for Indonesian locale
                            try {
                              final date = log.date is DateTime ? log.date : DateTime.tryParse(log.date.toString());
                              if (date != null) {
                                final now = DateTime.now();
                                final diff = now.difference(date);
                                if (diff.inMinutes < 1) {
                                  return const Text('Baru saja', style: TextStyle(fontSize: 12, color: Colors.grey));
                                } else if (diff.inMinutes < 60) {
                                  return Text('${diff.inMinutes} menit yang lalu', style: const TextStyle(fontSize: 12, color: Colors.grey));
                                } else if (diff.inHours < 24) {
                                  return Text('${diff.inHours} jam yang lalu', style: const TextStyle(fontSize: 12, color: Colors.grey));
                                } else {
                                  final formatted = DateFormat('d MMM yyyy', 'id_ID').format(date);
                                  return Text(formatted, style: const TextStyle(fontSize: 12, color: Colors.grey));
                                }
                              } else {
                                return const Text('-', style: TextStyle(fontSize: 12, color: Colors.grey));
                              }
                            } catch (e) {
                              return const Text('-', style: TextStyle(fontSize: 12, color: Colors.grey));
                            }
                          },
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showEditLogDialog(log),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await _mongoService.deleteLog(log.id!);
                            _refresh();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLogDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
