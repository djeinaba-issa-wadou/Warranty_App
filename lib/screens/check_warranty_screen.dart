import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/warranty.dart';
import '../services/warranty_service.dart';

class CheckWarrantyScreen extends StatefulWidget {
  @override
  _CheckWarrantyScreenState createState() => _CheckWarrantyScreenState();
}

class _CheckWarrantyScreenState extends State<CheckWarrantyScreen> {
  final _productIdController = TextEditingController();
  Warranty? _warranty;
  bool _searched = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Check Warranty'),
        backgroundColor: Colors.blue[700],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _productIdController,
              decoration: InputDecoration(
                hintText: 'Enter Product ID',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkWarranty,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Check',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            SizedBox(height: 40),
            if (_searched) _buildResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (_warranty == null) {
      return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Results:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'No warranty found for this Product ID',
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Results:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            'Warranty Status: ${_warranty!.isValid ? 'Valid' : 'Expired'}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _warranty!.isValid ? Colors.green : Colors.red,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Expires On: ${DateFormat('yyyy-MM-dd').format(_warranty!.expiryDate)}',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _checkWarranty() {
    final productId = _productIdController.text.trim();
    if (productId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a Product ID')),
      );
      return;
    }

    setState(() {
      _warranty = WarrantyService().getWarranty(productId);
      _searched = true;
    });
  }

  @override
  void dispose() {
    _productIdController.dispose();
    super.dispose();
  }
}
