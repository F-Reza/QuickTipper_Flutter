import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class TipsScreen extends StatefulWidget {
  const TipsScreen({super.key});

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _billController = TextEditingController();
  final TextEditingController _peopleController = TextEditingController();
  final TextEditingController _customTipController = TextEditingController(); // Custom tip controller
  double? _selectedTipPercentage;
  double? _calculatedTip;
  double? _tipPerPerson;
  bool _isTipSelected = false;

  List<Map<String, dynamic>> _history = []; // List to store history

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

  // Save history to SharedPreferences
  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tip_history', jsonEncode(_history));
  }

  // Calculate tip and save history with date
  void _calculateTip() {
    if (_formKey.currentState!.validate()) {
      if (_selectedTipPercentage == null && _customTipController.text.isEmpty) {
        setState(() {
          _isTipSelected = true;
        });
        return;
      }

      final billAmount = double.tryParse(_billController.text);
      final peopleCount = int.tryParse(_peopleController.text);

      if (billAmount != null && ( _selectedTipPercentage != null || _customTipController.text.isNotEmpty )) {
        setState(() {
          // Use custom tip if entered, otherwise use selected tip percentage
          double tipPercentage = _selectedTipPercentage ?? double.tryParse(_customTipController.text) ?? 0;

          _calculatedTip = billAmount * (tipPercentage / 100);
          if (peopleCount != null && peopleCount > 0) {
            _tipPerPerson = _calculatedTip! / peopleCount;
          } else {
            _tipPerPerson = null;
          }

          // Save calculation to history with date
          _history.add({
            'bill': billAmount,
            'tipPercentage': tipPercentage,
            'totalTip': _calculatedTip,
            'tipPerPerson': _tipPerPerson,
            'people': peopleCount,
            'date': DateTime.now().toString(), // Add current date and time
          });

          _saveHistory();
        });
      }
    }
  }

  // Reset the form
  void _reset() {
    setState(() {
      _billController.clear();
      _peopleController.clear();
      _selectedTipPercentage = null;
      _customTipController.clear(); // Reset custom tip field
      _calculatedTip = null;
      _tipPerPerson = null;
      _isTipSelected = false;
    });
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      decoration: BoxDecoration(
        color: const Color(0xFFF15B25).withOpacity(.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.blueGrey),
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Bill",
                style: TextStyle(
                  color: Colors.deepOrange,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              _buildCustomTextField(
                controller: _billController,
                hintText: 'Enter bill amount',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the bill amount';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Please enter a valid amount greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                "Tip Person",
                style: TextStyle(
                  color: Colors.deepOrange,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              _buildCustomTextField(
                controller: _peopleController,
                hintText: 'Enter person number',
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                      return 'Please enter a valid number greater than 0';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                "Select Tip %",
                style: TextStyle(
                  color: Colors.deepOrange,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2.2,
                children: [2, 5, 10, 15, 20, 25].map((percentage) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTipPercentage = percentage.toDouble();
                        _isTipSelected = false;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: _selectedTipPercentage == percentage
                            ?  Colors.teal
                            : const Color(0xFFF15B25),
                      ),
                      child: Center(
                        child: Text(
                          "$percentage%",
                          style: TextStyle(
                            color: _selectedTipPercentage == percentage
                                ? Colors.black54
                                : Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (_isTipSelected)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    "Please select a tip percentage",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 16),

              // Custom Tip Input
              const Text(
                "Custom Tip %",
                style: TextStyle(
                  color: Colors.deepOrange,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              _buildCustomTextField(
                controller: _customTipController,
                hintText: 'Enter custom tip percentage',
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (double.tryParse(value) == null || double.parse(value) <= 0) {
                      return 'Please enter a valid percentage greater than 0';
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              Stack(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 14),
                    color: Colors.teal,
                    height: 110,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: "Total Tip: ",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                              if (_calculatedTip != null)
                              TextSpan(
                                text: '\$ ${_calculatedTip!.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5,),
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: "Tip Per Person: ",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                              if (_calculatedTip != null)
                              TextSpan(
                                text: '\$ ${_tipPerPerson!.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Positioned(
                    right: 15,
                    top: 25,
                    child: Icon(Icons.tips_and_updates_outlined,size: 35,color: Colors.white,),
                  ),
                ],
              ),
              const SizedBox(height: 18,),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _calculateTip,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFFF15B25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Calculate Tip",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _reset,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.blueGrey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "RESET",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
