import 'package:flutter/material.dart';
import '../network/api_manager.dart';

class SetProxyPage extends StatefulWidget {
  @override
  _SetProxyPageState createState() => _SetProxyPageState();
}

class _SetProxyPageState extends State<SetProxyPage> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _portController = TextEditingController();

  void _setProxy() {
    String address = _addressController.text.trim();
    String port = _portController.text.trim();
    if (address.isNotEmpty && port.isNotEmpty) {
      ApiManager().setProxy(address, port);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('代理已设置为 $address:$port')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请输入有效的代理地址和端口')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置代理'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: '代理地址',
                hintText: '例如：127.0.0.1',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            TextField(
              controller: _portController,
              decoration: InputDecoration(
                labelText: '代理端口',
                hintText: '例如：8888',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _setProxy,
              child: Text('设置代理'),
            ),
          ],
        ),
      ),
    );
  }
}