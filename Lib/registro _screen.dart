import 'package:flutter/material.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _placaController = TextEditingController();
  final _contacto1Controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _placaController,
                decoration: const InputDecoration(labelText: 'Placa del Vehículo'),
              ),
              TextFormField(
                controller: _contacto1Controller,
                decoration: const InputDecoration(labelText: 'Número de Emergencia'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'placa': _placaController.text,
                    'contacto1': _contacto1Controller.text,
                    'contacto2': '',
                    'marca': 'Vehículo Registrado',
                    'color': '',
                  });
                },
                child: const Text('Guardar'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
