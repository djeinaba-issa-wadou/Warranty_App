import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/warranty.dart';
import '../services/warranty_service.dart';
import '../services/blockchain_service.dart';

class CheckWarrantyScreen extends StatefulWidget {
  @override
  _CheckWarrantyScreenState createState() => _CheckWarrantyScreenState();
}

class _CheckWarrantyScreenState extends State<CheckWarrantyScreen> {
  final BlockchainService blockchain = BlockchainService();
  final _productIdController = TextEditingController();
  Warranty? _warranty;
  bool _searched = false;
  bool _isLoading = false;

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
              onPressed: _isLoading ? null : _checkWarranty,
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
            'Warranty Details:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          _buildDetailRow('Product Name', _warranty!.productName),
          SizedBox(height: 12),
          _buildDetailRow('Customer Name', _warranty!.customerName),
          SizedBox(height: 12),
          _buildDetailRow(
            'Purchase Date',
            DateFormat('yyyy-MM-dd').format(_warranty!.purchaseDate),
          ),
          SizedBox(height: 12),
          _buildDetailRow(
            'Expires On',
            DateFormat('yyyy-MM-dd').format(_warranty!.expiryDate),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _warranty!.isValid ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _warranty!.isValid ? Colors.green : Colors.red,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _warranty!.isValid ? Icons.check_circle : Icons.cancel,
                  color: _warranty!.isValid ? Colors.green : Colors.red,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'Status: ${_warranty!.isValid ? 'Valid' : 'Expired'}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _warranty!.isValid ? Colors.green[800] : Colors.red[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _checkWarranty() async {
    final productId = _productIdController.text.trim();
    if (productId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a Product ID')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await blockchain.checkWarranty(productId);

      if (result.isEmpty) {
        setState(() {
          _warranty = null;
          _searched = true;
          _isLoading = false;
        });
        return;
      }

      final productName = result[0] as String;
      final customerName = result[1] as String;
      final purchaseDate = DateTime.fromMillisecondsSinceEpoch(
          (result[2] as BigInt).toInt());
      final warrantyPeriod = (result[3] as BigInt).toInt();

      setState(() {
        _warranty = Warranty(
          productId: productId,
          productName: productName,
          customerName: customerName,
          purchaseDate: purchaseDate,
          warrantyPeriodMonths: warrantyPeriod,
        );
        _searched = true;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
        setState(() {
          _warranty = null;
          _searched = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _productIdController.dispose();
    super.dispose();
  }
}
