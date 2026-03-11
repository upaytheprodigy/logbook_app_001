import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/log_model.dart';

class LogController {
  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);
  final ValueNotifier<List<LogModel>> filteredLogs =
      ValueNotifier<List<LogModel>>([]);

  String? _currentUser;

  void setUser(String username) {
    _currentUser = username;
    loadFromDisk();
  }

  String get _storageKey => 'logs_$_currentUser';

  LogController();

  void addLog(String title, String desc, String category) {
    final newLog = LogModel(
      title: title,
      date: DateTime.now(),
      description: desc,
      category: category,
    );

    logsNotifier.value = [...logsNotifier.value, newLog];
    filteredLogs.value = logsNotifier.value;
    saveToDisk();
  }

  void updateLog(int index, String title, String desc, String category) {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    currentLogs[index] = LogModel(
      title: title,
      date: DateTime.now(),
      description: desc,
      category: category,
    );

    logsNotifier.value = currentLogs;
    filteredLogs.value = logsNotifier.value;
    saveToDisk();
  }

  void removeLog(int index) {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    currentLogs.removeAt(index);
    logsNotifier.value = currentLogs;
    filteredLogs.value = logsNotifier.value;
    saveToDisk();
  }

  void filterLogs(String query) {
    if (query.isEmpty) {
      filteredLogs.value = logsNotifier.value;
    } else {
      filteredLogs.value = logsNotifier.value
          .where((log) => log.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  Future<void> saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();

    final jsonString = jsonEncode(
      logsNotifier.value.map((log) => log.toMap()).toList(),
    );

    await prefs.setString(_storageKey, jsonString);
  }

  Future<void> loadFromDisk() async {
    if (_currentUser == null) return;

    final prefs = await SharedPreferences.getInstance();
    String? rawJson = prefs.getString(_storageKey);

    if (rawJson != null) {
      Iterable decoded = jsonDecode(rawJson);

      logsNotifier.value = decoded
          .map((item) => LogModel.fromMap(item))
          .toList();

      filteredLogs.value = logsNotifier.value;
    } else {
      logsNotifier.value = [];
      filteredLogs.value = [];
    }
  }
}
