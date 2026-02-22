// login_controller.dart
class LoginController {
  // Database sederhana (Hardcoded) untuk multiple users
  final Map<String, String> _users = {
    "admin": "123",
    "budi": "456",
  };


  // Fungsi pengecekan (Logic-Only)
  // Fungsi ini mengembalikan true jika cocok, false jika salah.
  bool login(String username, String password) {
    return _users[username] == password;
  }

  // Fungsi untuk logout
  void logout() {
    
  }
}
