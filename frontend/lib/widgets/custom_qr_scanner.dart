import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:universal_platform/universal_platform.dart';

class CustomQRScanner extends StatefulWidget {
  final Function(String) onScan;

  const CustomQRScanner({super.key, required this.onScan});

  @override
  State<CustomQRScanner> createState() => _CustomQRScannerState();
}

class _CustomQRScannerState extends State<CustomQRScanner> {
  final MobileScannerController controller = MobileScannerController();
  bool _isScanning = true;

  @override
  Widget build(BuildContext context) {
    // Detectar si es web
    final bool isWeb = UniversalPlatform.isWeb;
    
    if (isWeb) {
      return _buildWebScanner();
    } else {
      return _buildMobileScanner();
    }
  }

  Widget _buildWebScanner() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear QR'),
        backgroundColor: const Color(0xFF1e3c72),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red, width: 3),
                ),
                child: const Icon(
                  Icons.qr_code_scanner,
                  size: 150,
                  color: Color(0xFF1e3c72),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Escaneo en Web',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                'Para escanear un código QR en versión web, ingresa el código manualmente:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _simularScan,
                icon: const Icon(Icons.qr_code),
                label: const Text('INGRESAR CÓDIGO'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  backgroundColor: const Color(0xFF1e3c72),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileScanner() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear QR'),
        backgroundColor: const Color(0xFF1e3c72),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: controller,
              builder: (context, state, child) {
                return Icon(
                  state.torchState == TorchState.on
                      ? Icons.flash_on
                      : Icons.flash_off,
                );
              },
            ),
            onPressed: () => controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              if (!_isScanning) return;
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _isScanning = false;
                  widget.onScan(barcode.rawValue!);
                  break;
                }
              }
            },
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red, width: 3),
            ),
            margin: const EdgeInsets.all(50),
          ),
          const Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Text(
              'Coloca el código QR dentro del recuadro',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                backgroundColor: Colors.black54,
                fontSize: 16
                
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _simularScan() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ingresar Código'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Ej: AULA-101',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              Navigator.pop(context);
              widget.onScan(value);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // Cerramos el diálogo sin hacer nada
              Navigator.pop(context);
            },
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}