import 'package:flutter/material.dart';
import '../services/local_repo.dart';

class LoginScreen extends StatefulWidget {
  final Function(String) onLogin;
  const LoginScreen({Key? key, required this.onLogin}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController(text: 'admin@catering.com');
  final _passCtrl = TextEditingController(text: 'admin123');
  bool _loading = false;
  String? _error;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final ok = LocalRepo.instance.authenticate(_emailCtrl.text.trim(), _passCtrl.text);
    await Future.delayed(Duration(milliseconds: 400));
    if (ok) {
      widget.onLogin(_emailCtrl.text.trim());
    } else {
      setState(() {
        _error = 'Giriş başarısız — e-posta veya parola yanlış';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Yönetici Girişi')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 420),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _emailCtrl,
                        decoration: InputDecoration(labelText: 'E-posta'),
                        validator: (v) => v == null || v.isEmpty ? 'E-posta girin' : null,
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _passCtrl,
                        decoration: InputDecoration(labelText: 'Parola'),
                        obscureText: true,
                        validator: (v) => v == null || v.isEmpty ? 'Parola girin' : null,
                      ),
                      SizedBox(height: 12),
                      if (_error != null) ...[
                        Text(_error!, style: TextStyle(color: Colors.red)),
                        SizedBox(height: 8),
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          child: _loading ? CircularProgressIndicator() : Text('Giriş'),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
