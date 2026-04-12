import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../screens/login_screen.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _nombreCompleto;
  String? _puestoNombre;
  String? _departamentoNombre;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarDatos();
    });
  }

  Future<void> _cargarDatos() async {
    final empleado = context.read<AuthProvider>().empleado;

    if (empleado == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    setState(() {
      _nombreCompleto = empleado.nombreCompleto;
      _isLoading = true;
      _error = null;
    });

    try {
      // =========================
      // 🔹 CARGAR PUESTO
      // =========================
      if (empleado.puestoId != null) {
        final puestoResponse = await http.get(
          Uri.parse('https://localhost:7168/Puesto/${empleado.puestoId}'),
        );

        if (puestoResponse.statusCode == 200) {
          final puestoData = jsonDecode(puestoResponse.body);
          _puestoNombre = puestoData['nombre'];
        } else {
          _puestoNombre = 'No asignado';
        }
      }

      // =========================
      // 🔹 CARGAR DEPARTAMENTO
      // =========================
      if (empleado.departamentoId != null) {
        final deptoResponse = await http.get(
          Uri.parse('https://localhost:7168/Departamento/${empleado.departamentoId}'),
        );

        if (deptoResponse.statusCode == 200) {
          final deptoData = jsonDecode(deptoResponse.body);
          _departamentoNombre = deptoData['nombre'];
        } else {
          _departamentoNombre = 'No asignado';
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = "Error cargando datos";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.empleado == null) {
          return const LoginScreen();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Perfil'),
            centerTitle: true,
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Text(_error!))
                  : Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),

                          // 👤 Avatar
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.blue.shade100,
                            child: const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.blue,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // 👤 Nombre
                          Text(
                            _nombreCompleto ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 30),

                          // 📦 Card info
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.work),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          _puestoNombre ?? 'No asignado',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  Row(
                                    children: [
                                      const Icon(Icons.apartment),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          _departamentoNombre ?? 'No asignado',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const Spacer(),

                          // 🔴 Logout
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () {
                                authProvider.logout();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const LoginScreen()),
                                );
                              },
                              child: const Text(
                                'Cerrar sesión',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
        );
      },
    );
  }
}