// NOTA: NFC temporalmente deshabilitado por problemas de compatibilidad
// Descomentar cuando nfc_manager se actualice o usar flutter_nfc_kit
// import 'package:nfc_manager/nfc_manager.dart';
import 'dart:typed_data';

class NfcService {
  bool _isAvailable = false;

  Future<void> initialize() async {
    // Temporalmente deshabilitado
    _isAvailable = false;
    // _isAvailable = await NfcManager.instance.isAvailable();
  }

  bool get isAvailable => _isAvailable;

  Future<String?> readNfcTag() async {
    if (!_isAvailable) {
      throw Exception('NFC no está disponible en este dispositivo');
    }

    // Temporalmente deshabilitado - simula lectura exitosa para testing
    await Future.delayed(const Duration(seconds: 2));
    return 'MOCK_NFC_TAG_ID_${DateTime.now().millisecondsSinceEpoch}';

    /* Código original - descomentar cuando se habilite NFC
    String? result;

    await NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        final ndef = Ndef.from(tag);

        if (ndef != null && ndef.cachedMessage != null) {
          final records = ndef.cachedMessage!.records;
          if (records.isNotEmpty) {
            final payload = records.first.payload;
            result = String.fromCharCodes(payload);
          }
        } else {
          final identifier = tag.data['nfca']?['identifier'] ??
              tag.data['nfcb']?['identifier'] ??
              tag.data['nfcf']?['identifier'] ??
              tag.data['nfcv']?['identifier'];

          if (identifier != null) {
            result = _bytesToHex(identifier);
          }
        }

        await NfcManager.instance.stopSession();
      },
      onError: (error) async {
        await NfcManager.instance.stopSession(errorMessage: error.message);
      },
    );

    return result;
    */
  }

  Future<bool> writeNfcTag(String data) async {
    if (!_isAvailable) {
      throw Exception('NFC no está disponible en este dispositivo');
    }

    // Temporalmente deshabilitado - simula escritura exitosa
    await Future.delayed(const Duration(seconds: 2));
    return true;

    /* Código original - descomentar cuando se habilite NFC
    bool success = false;

    await NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        final ndef = Ndef.from(tag);

        if (ndef == null || !ndef.isWritable) {
          await NfcManager.instance.stopSession(
            errorMessage: 'Tag no es escribible',
          );
          return;
        }

        final message = NdefMessage([
          NdefRecord.createText(data),
        ]);

        try {
          await ndef.write(message);
          success = true;
          await NfcManager.instance.stopSession();
        } catch (e) {
          await NfcManager.instance.stopSession(
            errorMessage: 'Error al escribir: $e',
          );
        }
      },
      onError: (error) async {
        await NfcManager.instance.stopSession(errorMessage: error.message);
      },
    );

    return success;
    */
  }

  Future<bool> unlockDoor(String roomNumber, String nfcId) async {
    if (!_isAvailable) {
      throw Exception('NFC no está disponible en este dispositivo');
    }

    // Temporalmente deshabilitado - simula desbloqueo exitoso
    await Future.delayed(const Duration(seconds: 2));
    return true;

    /* Código original - descomentar cuando se habilite NFC
    bool success = false;

    await NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        final identifier = tag.data['nfca']?['identifier'] ??
            tag.data['nfcb']?['identifier'] ??
            tag.data['nfcf']?['identifier'] ??
            tag.data['nfcv']?['identifier'];

        if (identifier != null) {
          final tagId = _bytesToHex(identifier);

          if (tagId == nfcId) {
            success = true;
            await NfcManager.instance.stopSession(
              alertMessage: 'Puerta de la habitación $roomNumber desbloqueada',
            );
          } else {
            await NfcManager.instance.stopSession(
              errorMessage: 'NFC no coincide con la habitación $roomNumber',
            );
          }
        } else {
          await NfcManager.instance.stopSession(
            errorMessage: 'No se pudo leer el tag NFC',
          );
        }
      },
      onError: (error) async {
        await NfcManager.instance.stopSession(errorMessage: error.message);
      },
    );

    return success;
    */
  }

  void stopSession({String? errorMessage, String? alertMessage}) {
    // Temporalmente deshabilitado
    // NfcManager.instance.stopSession(
    //   errorMessage: errorMessage,
    //   alertMessage: alertMessage,
    // );
  }

  String _bytesToHex(Uint8List bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('');
  }
}
