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
  bool _isProcessing = false;
  bool _isTorchOn = false;
  bool _isFrontCamera = false;

  @override
  Widget build(BuildContext context) {
    final bool isWeb = UniversalPlatform.isWeb;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear QR'),
        backgroundColor: const Color(0xFF1e3c72),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!isWeb) ...[
            // Botón de flash
            IconButton(
              icon: Icon(
                _isTorchOn ? Icons.flash_on : Icons.flash_off,
              ),
              onPressed: () {
                setState(() {
                  _isTorchOn = !_isTorchOn;
                });
                controller.toggleTorch();
              },
            ),
            // Botón de cambiar cámara
            IconButton(
              icon: Icon(
                _isFrontCamera ? Icons.camera_front : Icons.camera_rear,
              ),
              onPressed: () {
                setState(() {
                  _isFrontCamera = !_isFrontCamera;
                });
                controller.switchCamera();
              },
            ),
          ],
        ],
      ),
      body: isWeb ? _buildWebScanner() : _buildMobileScanner(),
    );
  }

  Widget _buildMobileScanner() {
    return Stack(
      children: [
        MobileScanner(
          controller: controller,
          onDetect: _processBarcode,
        ),
        // Recuadro de escaneo
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red, width: 3),
          ),
          margin: const EdgeInsets.all(50),
        ),
        // Texto inferior
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
              fontSize: 16,
            ),
          ),
        ),
        // Indicador de procesamiento
        if (_isProcessing)
          const Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildWebScanner() {
    return Center(
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
                border: Border.all(color: const Color(0xFF1e3c72), width: 3),
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
              'Para escanear en versión web,\ningresa el código manualmente:',
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
    );
  }

  void _processBarcode(BarcodeCapture capture) {
    if (!_isScanning || _isProcessing) return;
    
    setState(() {
      _isProcessing = true;
    });
    
    for (final barcode in capture.barcodes) {
      if (barcode.rawValue != null) {
        controller.stop();
        widget.onScan(barcode.rawValue!);
        break;
      }
    }
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    });
  }

  void _simularScan() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ingresar Código QR'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Ej: AULA-101',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.qr_code),
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