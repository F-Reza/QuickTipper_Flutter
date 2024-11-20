import 'package:flutter/material.dart';

class SplitBillScreen extends StatefulWidget {
  const SplitBillScreen({super.key});

  @override
  State<SplitBillScreen> createState() => _SplitBillScreenState();
}

class _SplitBillScreenState extends State<SplitBillScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _billController = TextEditingController();
  final TextEditingController _peopleController = TextEditingController();
  final TextEditingController _customTipController = TextEditingController(); // Custom tip controller
  double? _selectedTipPercentage;
  double? _totalBillWithTip;
  double? _billPerPerson;

  bool _isTipSelected = false;

  void _calculateSplitBill() {
    if (_formKey.currentState!.validate()) {
      if (_selectedTipPercentage == null && _customTipController.text.isEmpty) {
        setState(() {
          _isTipSelected = true;
        });
        return;
      }

      final billAmount = double.tryParse(_billController.text);
      final peopleCount = int.tryParse(_peopleController.text);

      double tipPercentage = _selectedTipPercentage ?? double.tryParse(_customTipController.text) ?? 0;

      if (billAmount != null && peopleCount != null && peopleCount > 0) {
        setState(() {
          // Calculate total bill including tip
          final tipAmount = billAmount * (tipPercentage / 100);
          _totalBillWithTip = billAmount + tipAmount;

          // Calculate bill per person
          _billPerPerson = _totalBillWithTip! / peopleCount;
        });
      }
    }
  }

  void _reset() {
    setState(() {
      _billController.clear();
      _peopleController.clear();
      _customTipController.clear();
      _selectedTipPercentage = null;
      _totalBillWithTip = null;
      _billPerPerson = null;
      _isTipSelected = false;
    });
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF15B25).withOpacity(0.1),
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
                  color: Color(0xFF1562B1),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              _buildCustomTextField(
                controller: _billController,
                hintText: 'Enter total bill amount',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the total bill amount';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Please enter a valid amount greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                "Bill Per Person",
                style: TextStyle(
                  color: Color(0xFF1562B1),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              _buildCustomTextField(
                controller: _peopleController,
                hintText: 'Enter number of people',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of people';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Please enter a valid number greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                "Select Tip %",
                style: TextStyle(
                  color: Color(0xFF1562B1),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
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
                childAspectRatio: 1.8,
                children: [0, 5, 10, 15, 20, 25].map((percentage) {
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
                            ?  Colors.redAccent.withOpacity(0.9)
                            : Colors.blueAccent,
                      ),
                      child: Center(
                        child: Text(
                          "$percentage%",
                          style: TextStyle(
                            color: _selectedTipPercentage == percentage
                                ? Colors.black
                                : Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
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
              // Custom Tip input
              const Text(
                "Custom Tip %",
                style: TextStyle(
                  color: Color(0xFF1562B1),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              _buildCustomTextField(
                controller: _customTipController,
                hintText: 'Enter custom tip percentage (Optional)',
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final parsedValue = double.tryParse(value);
                    if (parsedValue == null || parsedValue < 0) {
                      return 'Please enter a valid positive percentage';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_totalBillWithTip != null)
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: "Total Bill (with Tip) : ",
                        style: TextStyle(
                          color: Color(0xFF1562B1),
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      TextSpan(
                        text: "\$ ${_totalBillWithTip!.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Color(0xFF1562B1),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              if (_billPerPerson != null)
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: "Bill Per Person : ",
                        style: TextStyle(
                          color: Color(0xFF1562B1),
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      TextSpan(
                        text: "\$ ${_billPerPerson!.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Color(0xFF1562B1),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _calculateSplitBill,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: const Color(0xFF1562B1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    "CALCULATE",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _reset,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: Colors.deepOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    "RESET",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
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
