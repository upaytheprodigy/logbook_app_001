class CounterController {
  int _counter = 0; // Variabel private (Enkapsulasi)
  int _step = 1;    // Variabel private (Enkapsulasi)

  int get value => _counter; // Getter untuk akses data
  int get step => _step;     // Getter untuk akses data

  set step(int value) => _step = value; // Setter untuk mengubah step
  
  void increment() => _counter += _step;
  void decrement() { if (_counter > 0) _counter -= _step; }
  void reset() => _counter = 0;
}
