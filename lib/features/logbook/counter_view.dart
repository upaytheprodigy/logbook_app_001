import 'package:flutter/material.dart';
import 'package:logbook_app_001/features/logbook/counter_controller.dart';
import 'package:logbook_app_001/features/onboarding/onboarding_view.dart';

class CounterView extends StatefulWidget {
  // Tambahkan variabel final untuk menampung nama
  final String username;

  // Update Constructor agar mewajibkan (required) kiriman nama
  const CounterView({super.key, required this.username});

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  final CounterController _controller = CounterController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    await _controller.loadAll(widget.username);
    setState(() {});
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi Logout"),
          content: const Text("Apakah Anda yakin ingin keluar dari akun ini?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OnboardingView(),
                  ),
                  (route) => false,
                );
              },
              child: const Text(
                "Ya, Keluar",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Logbook: ${widget.username}"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutDialog();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Selamat Datang, ${widget.username}!"),
            const SizedBox(height: 10),

            const Text("Total Hitungan:"),
            Text('${_controller.value}', style: const TextStyle(fontSize: 40)),

            const SizedBox(height: 40),

            const Text("Nilai Step:"),
            Text('${_controller.step}', style: const TextStyle(fontSize: 20)),

            Slider(
              value: _controller.step.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: '${_controller.step}',
              onChanged: (value) =>
                  setState(() => _controller.step = value.toInt()),
            ),

            const SizedBox(height: 30),

            const Text(
              "Riwayat Aktivitas Terakhir:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            SizedBox(
              height: 170,
              child: _controller.history.isEmpty
                  ? const Center(child: Text("Belum ada aktivitas."))
                  : ListView(
                      shrinkWrap: true,
                      children: _controller.history.map((e) {
                        Color? color;
                        if (e.toLowerCase().contains('menambah')) {
                          color = Colors.green;
                        } else if (e.toLowerCase().contains('mengurangi')) {
                          color = Colors.red;
                        } else if (e.toLowerCase().contains('reset')) {
                          color = Colors.orange;
                        }
                        return Text(
                          e,
                          style: TextStyle(fontSize: 14, color: color),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),

      // =========================
      // FLOATING BUTTONS
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(width: 32),

          // RESET
          FloatingActionButton(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Konfirmasi Reset'),
                  content: const Text('Apakah Anda yakin ingin mereset nilai?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await _controller.reset(widget.username);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Counter berhasil di-reset!')),
                );
              }
            },
            child: const Text("Reset"),
          ),

          const SizedBox(width: 135),

          // DECREMENT
          FloatingActionButton(
            onPressed: () async {
              await _controller.decrement(widget.username);
              setState(() {});
            },
            child: const Icon(Icons.remove),
          ),

          const SizedBox(width: 16),

          // INCREMENT
          FloatingActionButton(
            onPressed: () async {
              await _controller.increment(widget.username);
              setState(() {});
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
