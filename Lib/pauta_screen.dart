import 'package:flutter/material.dart';

class PautaScreen extends StatelessWidget {
  const PautaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Anúnciate en la Ruta')),
      body: const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: Text('Formulario de Publicidad (Próximamente)', style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}
