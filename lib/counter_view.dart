import 'package:flutter/material.dart';
import 'counter_controller.dart';

class CounterView extends StatefulWidget {
  const CounterView({super.key});
  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  final CounterController _controller = CounterController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Counter App")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
              onChanged: (value) => setState(() => _controller.step = value.toInt()),
            ),
            const SizedBox(height: 30),
            const Text("Riwayat Aktivitas Terakhir:", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(
              height: 170,
              child: ListView(
                shrinkWrap: true,
                children: _controller.history.isEmpty
                  ? [const Text("Belum ada aktivitas.")]
                  : _controller.history.map((e) {
                      Color? color;
                      if (e.toLowerCase().contains('menambah')) {
                        color = Colors.green;
                      } else if (e.toLowerCase().contains('mengurangi')) {
                        color = Colors.red;
                      }
                      return Text(e, style: TextStyle(fontSize: 14, color: color));
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(width: 32),
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
                setState(() => _controller.reset());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Counter berhasil di-reset!')),
                );
              }
            },
            child: const Text("Reset"),
          ),
          const SizedBox(width: 135),
          FloatingActionButton(
            onPressed: () => setState(() => _controller.decrement()),
            child: const Icon(Icons.remove),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            onPressed: () => setState(() => _controller.increment()),
            child: const Icon(Icons.add),
          )
        ],
      ),
    );
  }
}