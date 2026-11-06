setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
      _mapController.move(_currentPosition, 14.0);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de GPS: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Ejecuta la búsqueda de la ruta usando la API de OpenStreetMap mediante nuestro servicio
  void _drawRoute() async {
    setState(() => _isLoading = true);
    // Simulación: Genera un destino moviendo ligeramente tus coordenadas de origen
    LatLng destination = LatLng(_currentPosition.latitude + 0.02, _currentPosition.longitude + 0.02);
    
    var points = await RouteService.getRoute(_currentPosition, destination);
    setState(() {
      _routePoints = points;
      _isLoading = false;
    });
  }

  // Gestiona el envío de alertas leyendo dinámicamente los datos SOS del registro
  void _handleAlert(String alertType, Color color) {
    String mensajeAdicional = "";

    // Si es una alerta crítica y el usuario ya completó el perfil
    if (alertType == 'En Peligro' || alertType == 'Robo Carro') {
      if (_datosUsuario != null) {
        mensajeAdicional = '\n\n🚨 NOTIFICANDO SOS A: ${_datosUsuario!['contacto1']}';
        if (_datosUsuario!['contacto2'] != null && _datosUsuario!['contacto2'].toString().isNotEmpty) {
          mensajeAdicional += ' y ${_datosUsuario!['contacto2']}';
        }
        mensajeAdicional += '\n📦 Vehículo: Placa [${_datosUsuario!['placa'].toString().toUpperCase()}] - ${_datosUsuario!['marca']} (${_datosUsuario!['color']})';
      } else {
        mensajeAdicional = '\n\n⚠️ Alerta general enviada. Configura tus contactos de confianza en el botón de "Registrarse" para enviar mensajes automáticos SMS de pánico.';
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Alerta "$alertType" reportada con éxito en tus coordenadas actuales.$mensajeAdicional',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ruta Segura', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.business, color: Colors.orangeAccent),
            tooltip: 'Paute Aquí',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PautaScreen())),
          ),
          IconButton(
            icon: Icon(Icons.person_add, color: _datosUsuario != null ? Colors.green : null),
            tooltip: 'Registrarse',
            onPressed: () async {
              // Navega a la pantalla de registro esperando la respuesta del formulario
              final resultado = await Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => const RegistroScreen())
              );
              
              if (resultado != null) {
                setState(() {
                  _datosUsuario = resultado as Map<String, dynamic>;
                });
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // MAPA INTERACTIVO CON CAPA DE RUTA Y MARCADOR GPS
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition, 
              initialZoom: 14.0
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://openstreetmap.org{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.seguridad_vial_app',
              ),
              // Capa de Líneas (Muestra la ruta azul en el mapa)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePoints,
                    strokeWidth: 5.0,
                    color: Colors.blueAccent,
                  ),
                ],
              ),
              // Capa de Marcadores (Icono de ubicación del conductor)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentPosition,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.navigation, color: Colors.blue, size: 35),
                  ),
                ],
              ),
            ],
          ),

          // BARRA SUPERIOR INTERACTIVA PARA SIMULAR LA RUTA
          Positioned(
            top: 15,
            left: 15,
            right: 15,
            child: Card(
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.search, color: Colors.blueGrey),
                title: const Text('Trazar Ruta / Simular Viaje'),
                trailing: _isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.directions, color: Colors.blue),
                onTap: _drawRoute,
              ),
            ),
          ),

          // BOTÓN FLOTANTE PARA VOLVER A CENTRAR EL GPS
          Positioned(
            top: 85,
            right: 15,
            child: FloatingActionButton(
              mini: true,
              onPressed: _determinePosition,
              child: const Icon(Icons.my_location),
            ),
          ),

          // CONTENEDOR INFERIOR CON LOS 5 BOTONES DE ASISTENCIA VIAL
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.96),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24), 
                  topRight: Radius.circular(24)
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -2))
                ]
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '¿Necesitas ayuda en la vía?', 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildButton('Me varé', Icons.build, Colors.orange)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildButton('Accidente', Icons.car_crash, Colors.red.shade700)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _buildButton('En Peligro', Icons.warning, Colors.red.shade900)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildButton('Robo Carro', Icons.lock_open, Colors.purple)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _buildButton('Agente Tránsito', Icons.local_police, Colors.blue.shade700)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
