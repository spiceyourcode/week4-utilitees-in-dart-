import 'dart:io';
import 'package:intl/intl.dart';

class LogEntry {
  String content;
  DateTime timestamp;

  LogEntry(this.content, this.timestamp);

  @override
  String toString() {
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return '${formatter.format(timestamp)}: $content';
  }
}

class LogSystem {
  List<LogEntry> entries = [];
  Set<String> uniqueWords = Set();
  Map<String, int> wordCount = {};

  void addEntry(String content) {
    // String manipulation
    content = content.trim().toLowerCase();
    String reversed = content.split('').reversed.join();
    content = '$content (Reversed: $reversed)';

    // Create log entry
    final entry = LogEntry(content, DateTime.now());
    entries.add(entry);

    // Update collections
    List<String> words = content.split(' ');
    uniqueWords.addAll(words);
    for (var word in words) {
      wordCount[word] = (wordCount[word] ?? 0) + 1;
    }
  }

  void saveToFile(String filename) {
    try {
      final file = File(filename);
      final sink = file.openWrite();
      for (var entry in entries) {
        sink.writeln(entry.toString());
      }
      sink.close();
      print('Log saved to $filename');
    } catch (e) {
      print('Error saving file: $e');
    }
  }

  void loadFromFile(String filename) {
    try {
      final file = File(filename);
      final lines = file.readAsLinesSync();
      for (var line in lines) {
        final parts = line.split(': ');
        if (parts.length >= 2) {
          final timestamp = DateTime.parse(parts[0]);
          addEntry(parts.sublist(1).join(': '));
          entries.last.timestamp = timestamp;
        }
      }
      print('Log loaded from $filename');
    } catch (e) {
      print('Error loading file: $e');
    }
  }

  void printStatistics() {
    print('\nLog Statistics:');
    print('Total entries: ${entries.length}');
    print('Unique words: ${uniqueWords.length}');
    print(
        'Most common word: ${wordCount.entries.reduce((a, b) => a.value > b.value ? a : b).key}');

    if (entries.isNotEmpty) {
      final now = DateTime.now();
      final oldestEntry =
          entries.reduce((a, b) => a.timestamp.isBefore(b.timestamp) ? a : b);
      final daysSinceOldest = now.difference(oldestEntry.timestamp).inDays;
      print('Days since oldest entry: $daysSinceOldest');
    }
  }
}

void main() {
  final logSystem = LogSystem();

  // Load existing entries if file exists
  logSystem.loadFromFile('log.txt');

  while (true) {
    stdout.write('\nEnter a log entry (or "quit" to exit): ');
    final input = stdin.readLineSync();

    if (input?.toLowerCase() == 'quit') break;

    if (input != null && input.isNotEmpty) {
      logSystem.addEntry(input);
      print('Entry added. Current count: ${logSystem.entries.length}');
    }
  }

  logSystem.saveToFile('log.txt');
  logSystem.printStatistics();
}
