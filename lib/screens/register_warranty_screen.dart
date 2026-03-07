import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/warranty.dart';
import '../services/warranty_service.dart';
import '../services/blockchain_service.dart';

class RegisterWarrantyScreen extends StatefulWidget {
  @override
  _RegisterWarrantyScreenState createState() => _RegisterWarrantyScreenState();
}

class _RegisterWarrantyScreenState extends State<RegisterWarrantyScreen> {
  final BlockchainService blockchain = BlockchainService();
  final _formKey = GlobalKey<FormState>();
  final _productIdController = TextEditingController();
  final _productNameController = TextEditingController();
  final _customerNameController = TextEditingController();
  DateTime? _purchaseDate;
  int? _warrantyPeriod;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _warrantyPeriods = [
    {'label': '6 Months', 'value': 6},
    {'label': '1 Year', 'value': 12},
    {'label': '2 Years', 'value': 24},
    {'label': '3 Years', 'value': 36},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register Warranty'),
        backgroundColor: Colors.blue[700],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField('Product ID', _productIdController),
              SizedBox(height: 16),
              _buildTextField('Product Name', _productNameController),
              SizedBox(height: 16),
              _buildTextField('Customer Name', _customerNameController),
              SizedBox(height: 16),
              _buildDateField(),
              SizedBox(height: 16),
              _buildDropdown(),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Submit',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16)),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          validator: (value) =>
              value?.isEmpty ?? true ? 'This field is required' : null,
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Purchase Date', style: TextStyle(fontSize: 16)),
        SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (date != null) setState(() => _purchaseDate = date);
          },
          child: InputDecorator(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            child: Text(
              _purchaseDate == null
                  ? 'Select Date'
                  : DateFormat('yyyy-MM-dd').format(_purchaseDate!),
              style: TextStyle(
                color: _purchaseDate == null ? Colors.grey : Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Warranty Period', style: TextStyle(fontSize: 16)),
        SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: _warrantyPeriod,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          hint: Text('Select Period'),
          items: _warrantyPeriods.map((period) {
            return DropdownMenuItem<int>(
              value: period['value'],
              child: Text(period['label']),
            );
          }).toList(),
          onChanged: (value) => setState(() => _warrantyPeriod = value),
          validator: (value) => value == null ? 'Please select a period' : null,
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _purchaseDate != null) {
      setState(() => _isLoading = true);
      try {
        final warranty = Warranty(
          productId: _productIdController.text,
          productName: _productNameController.text,
          customerName: _customerNameController.text,
          purchaseDate: _purchaseDate!,
          warrantyPeriodMonths: _warrantyPeriod!,
        );
        WarrantyService().registerWarranty(warranty);
        await blockchain.registerWarranty(
          warranty.productId,
          warranty.productName,
          warranty.customerName,
          warranty.purchaseDate.millisecondsSinceEpoch,
          warranty.warrantyPeriodMonths,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Warranty registered successfully!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else if (_purchaseDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a purchase date')),
      );
    }
  }

  @override
  void dispose() {
    _productIdController.dispose();
    _productNameController.dispose();
    _customerNameController.dispose();
    super.dispose();
  }
}
