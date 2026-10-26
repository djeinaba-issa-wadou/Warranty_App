import 'dart:convert';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

class BlockchainService {
  // Values come from config.json at build time (never committed to Git):
  //   flutter run --dart-define-from-file=config.json
  // See config.example.json for the keys needed.
  static const String rpcUrl = String.fromEnvironment('RPC_URL');
  static const String privateKey = String.fromEnvironment('PRIVATE_KEY');
  static const String contractAddress = String.fromEnvironment('CONTRACT_ADDRESS');

  final String abi = '''
  [
    {
      "inputs": [
        {
          "internalType": "string",
          "name": "_productId",
          "type": "string"
        }
      ],
      "name": "checkWarranty",
      "outputs": [
        {
          "internalType": "string",
          "name": "productName",
          "type": "string"
        },
        {
          "internalType": "string",
          "name": "customerName",
          "type": "string"
        },
        {
          "internalType": "uint256",
          "name": "purchaseDate",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "warrantyPeriod",
          "type": "uint256"
        },
        {
          "internalType": "bool",
          "name": "valid",
          "type": "bool"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "string",
          "name": "_productId",
          "type": "string"
        },
        {
          "internalType": "string",
          "name": "_productName",
          "type": "string"
        },
        {
          "internalType": "string",
          "name": "_customerName",
          "type": "string"
        },
        {
          "internalType": "uint256",
          "name": "_purchaseDate",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "_warrantyPeriod",
          "type": "uint256"
        }
      ],
      "name": "registerWarranty",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "string",
          "name": "",
          "type": "string"
        }
      ],
      "name": "warranties",
      "outputs": [
        {
          "internalType": "string",
          "name": "productId",
          "type": "string"
        },
        {
          "internalType": "string",
          "name": "productName",
          "type": "string"
        },
        {
          "internalType": "string",
          "name": "customerName",
          "type": "string"
        },
        {
          "internalType": "uint256",
          "name": "purchaseDate",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "warrantyPeriod",
          "type": "uint256"
        },
        {
          "internalType": "bool",
          "name": "exists",
          "type": "bool"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    }
  ]
  ''';

  late Web3Client client;
  late Credentials credentials;
  late DeployedContract contract;
  late ContractFunction registerWarrantyFunction;
  late ContractFunction checkWarrantyFunction;

  BlockchainService() {
    if (rpcUrl.isEmpty || privateKey.isEmpty || contractAddress.isEmpty) {
      throw StateError(
        'Missing blockchain config. Run the app with '
        '--dart-define-from-file=config.json (see config.example.json).',
      );
    }
    client = Web3Client(rpcUrl, Client());
    credentials = EthPrivateKey.fromHex(privateKey);
    final contractAddr = EthereumAddress.fromHex(contractAddress);
    contract = DeployedContract(
      ContractAbi.fromJson(abi, "WarrantyRegistry"),
      contractAddr,
    );
    registerWarrantyFunction = contract.function("registerWarranty");
    checkWarrantyFunction = contract.function("checkWarranty");
    _testConnection();
  }

  Future<void> _testConnection() async {
    try {
      final chainId = await client.getNetworkId();
      print('✅ Connected to Ganache - Chain ID: $chainId');
    } catch (e) {
      print('❌ Connection error: $e');
    }
  }

  Future<String> registerWarranty(
    String productId,
    String productName,
    String customerName,
    int purchaseDate,
    int warrantyPeriod,
  ) async {
    print('🔗 Registering warranty...');
    print('Product ID: $productId');
    
    try {
      final sender = await credentials.extractAddress();
      print('Sender address: $sender');
      
      // Get nonce
      final nonce = await client.getTransactionCount(sender);
      print('Nonce: $nonce');
      
      final transaction = Transaction.callContract(
        contract: contract,
        function: registerWarrantyFunction,
        parameters: [
          productId,
          productName,
          customerName,
          BigInt.from(purchaseDate),
          BigInt.from(warrantyPeriod)
        ],
        maxGas: 3000000,
        gasPrice: EtherAmount.fromUnitAndValue(EtherUnit.gwei, 20),
        nonce: nonce,
      );

      final result = await client.sendTransaction(
        credentials,
        transaction,
        chainId: 1337,
      );

      print('✅ Transaction hash: $result');
      return result;
    } catch (e) {
      print('❌ Error: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> checkWarranty(String productId) async {
    print('🔍 Checking warranty...');
    print('Product ID: $productId');
    
    final result = await client.call(
      contract: contract,
      function: checkWarrantyFunction,
      params: [productId],
    );

    print('📋 Result: $result');
    return result;
  }
}
