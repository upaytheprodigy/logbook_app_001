class LogModel {
  final String title;
  final String description;
  final String date;
  final String category;

  LogModel({
    required this.title,
    required this.description,
    required this.date,
    required this.category,
  });

  // Untuk Tugas HOTS: Konversi Map (JSON) ke Object
  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      title: map['title'],
      description: map['description'],
      date: map['date'],
      category: map['category'] ?? "Pribadi",
    );
  }

  // Konversi Object ke Map (JSON) untuk disimpan
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': date,
      'category': category,
    };
  }
}