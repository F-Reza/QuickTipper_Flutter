import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString('tip_history');
    if (historyJson != null) {
      setState(() {
        _history = List<Map<String, dynamic>>.from(jsonDecode(historyJson));
      });
    }
  }

  Future<void> _deleteHistoryEntry(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _history.removeAt(index);
    });
    // Save the updated history back to SharedPreferences
    await prefs.setString('tip_history', jsonEncode(_history));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _history.isEmpty
          ? const Center(
        child: Text(
          "No history available",
          style: TextStyle(fontSize: 18, color: Colors.blueGrey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _history.length,
        itemBuilder: (context, index) {
          // Reverse the index for descending order
          final entry = _history[_history.length - 1 - index];
          final date = DateTime.parse(entry['date']);
          final formattedDate =
              "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}";

          return Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.tips_and_updates_outlined,
                    size: 35,
                  ),
                  const SizedBox(width: 2),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black45,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Bill: \$${entry['bill'].toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Tip: \$${entry['totalTip'].toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Tip Percentage: ${entry['tipPercentage']}%",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black45,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Per Person: \$${entry['tipPerPerson']?.toStringAsFixed(2) ?? 'N/A'}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Delete Button
                  Column(
                    children: [
                      const Icon(
                        Icons.history,
                        size: 35,
                      ),
                      const SizedBox(height: 5),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.black54),
                        onPressed: () {
                          _showDeleteConfirmationDialog(
                              _history.length - 1 - index);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(int index) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete History Entry'),
          content: const Text('Are you sure you want to delete this entry?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteHistoryEntry(index);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
