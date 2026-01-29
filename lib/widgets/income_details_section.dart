// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../utils/validators.dart'; // Assuming FormValidators is used for input validation
//
// class IncomeDetailsSection extends StatefulWidget {
//   final List<TextEditingController> incomeControllers;
//   final TextEditingController totalIncomeController;
//
//   const IncomeDetailsSection({
//     super.key,
//     required this.incomeControllers,
//     required this.totalIncomeController,
//   });
//
//   @override
//   State<IncomeDetailsSection> createState() => _IncomeDetailsSectionState();
// }
//
// class _IncomeDetailsSectionState extends State<IncomeDetailsSection> {
//   @override
//   void initState() {
//     super.initState();
//     // Add listeners to controllers to calculate total income whenever input changes
//     for (var controller in widget.incomeControllers) {
//       controller.addListener(_calculateTotal);
//     }
//   }
//
//   @override
//   void dispose() {
//     // Dispose controllers to prevent memory leaks
//     for (var controller in widget.incomeControllers) {
//       controller.removeListener(_calculateTotal);
//     }
//     super.dispose();
//   }
//
//   void _calculateTotal() {
//     int total = 0;
//     for (var controller in widget.incomeControllers) {
//       if (controller.text.isNotEmpty) {
//         total += int.tryParse(controller.text) ?? 0;
//       }
//     }
//     widget.totalIncomeController.text = total.toString();
//   }
//
//   @override
//   Widget build(BuildContext contextIncome) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Gross annual income of the family (during preceding financial year)',
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 16),
//         _buildIncomeField(0, '1. Agriculture (including plantation, horticulture, dairying, poultry, fisheries etc.)'),
//         const SizedBox(height: 16),
//         _buildIncomeField(1, '2. Salary/Wages/Remuneration etc.'),
//         const SizedBox(height: 16),
//         _buildIncomeField(2, '3. Trade/Business/Profession (Please specify)'),
//         const SizedBox(height: 16),
//         _buildIncomeField(3, '4. Other Sources (Please Specify)'),
//         const SizedBox(height: 32),
//         const Text(
//           'Total Income (In Rs)',
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 16),
//         TextFormField(
//           controller: widget.totalIncomeController,
//           readOnly: true, // Total income is calculated, not directly editable
//           decoration: const InputDecoration(
//             labelText: 'Total Income',
//             filled: true,
//             fillColor: Color(0xFFF5F5F5), // Light grey background
//             border: OutlineInputBorder(),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildIncomeField(int index, String label) {
//     return TextFormField(
//       controller: widget.incomeControllers[index],
//       decoration: InputDecoration(labelText: label),
//       keyboardType: TextInputType.number,
//       inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Only allow digits
//       validator: FormValidators.validateRequired, // Use validateRequired for now, can be adjusted if needed
//     );
//   }
// }
