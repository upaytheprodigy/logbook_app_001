class CounterController {
  int _counter = 0; // Variabel private (Enkapsulasi)
  int _step = 1;    // Variabel private (Enkapsulasi)
  final List<String> _history = [];

  int get value => _counter; // Getter untuk akses data
  int get step => _step;     // Getter untuk akses data
  List<String> get history => List.unmodifiable(_history.reversed.take(5).toList().reversed);

  set step(int value) => _step = value; // Setter untuk mengubah step

  void increment() {
    _counter += _step;
    _addHistory("User menambah nilai sebesar $_step pada jam ${_getTime()}");
  }

  void decrement() {
    if (_counter > 0) {
      int before = _counter;
      _counter -= _step;
      if (_counter < 0) _counter = 0;
      int actual = before - _counter;
      _addHistory("User mengurangi nilai sebesar $actual pada jam ${_getTime()}");
    }
  }

  void reset() {
    _counter = 0;
    _addHistory("User melakukan reset pada jam ${_getTime()}");
  }

  void _addHistory(String entry) {
    _history.add(entry);
    if (_history.length > 5) {
      _history.removeAt(0);
    }
  }

  String _getTime() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }
}
