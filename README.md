# logbook_app_001

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)


## Refleksi SRP (Single Responsibility Principle)

"Bagaimana prinsip SRP membantu kalian saat harus menambah fitur History Logger tadi?"

SRP memudahkan penambahan fitur History Logger karena setiap class hanya fokus pada satu tanggung jawab. CounterController hanya mengelola logika data dan riwayat, sedangkan CounterView hanya mengelola tampilan. Dengan pemisahan ini, penambahan fitur history tidak menyebabkan kode UI menjadi rumit, dan logika penambahan riwayat cukup ditambahkan di controller tanpa mengubah struktur view secara besar-besaran.
