import 'package:shared_preferences/shared_preferences.dart';

class CounterController {
  int _counter = 0;
  int _step = 1;
  final List<String> _history = [];

  int get value => _counter;
  int get step => _step;

  List<String> get history =>
      List.unmodifiable(_history.take(5));

  set step(int value) => _step = value;

  // INCREMENT
  Future<void> increment(String username) async {
    _counter += _step;

    _addHistory(
      username,
      "menambah nilai sebesar $_step",
    );

    await saveAll(username);
  }

  // DECREMENT
  Future<void> decrement(String username) async {
    if (_counter > 0) {
      int before = _counter;
      _counter -= _step;
      if (_counter < 0) _counter = 0;

      int actual = before - _counter;

      _addHistory(
        username,
        "mengurangi nilai sebesar $actual",
      );

      await saveAll(username);
    }
  }

  // RESET
  Future<void> reset(String username) async {
    _counter = 0;

    _addHistory(
      username,
      "melakukan reset",
    );

    await saveAll(username);
  }

  // HISTORY
  void _addHistory(String username, String action) {
    String log =
        "$username $action pada jam ${_getTime()}";

    _history.insert(0, log); // Tambah di atas

    if (_history.length > 5) {
      _history.removeLast(); // Hapus paling lama
    }
  }

  // SAVE
  Future<void> saveAll(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_counter_$username', _counter);
  }

  // LOAD
  Future<void> loadAll(String username) async {
    final prefs = await SharedPreferences.getInstance();
    _counter = prefs.getInt('last_counter_$username') ?? 0;
  }

  // TIME FORMAT
  String _getTime() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }
}
