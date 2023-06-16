import 'package:encrypt/encrypt.dart';
import 'video_model.dart';

import 'encryption_contract.dart';

class EncryptionService implements IEncryption {
  final Encrypter _encrypter;
  final _iv = IV.fromLength(16);

  EncryptionService(this._encrypter);

  @override
  String decrypt(String encryptedVideo) {
    final encrypted = Encrypted.fromBase64(encryptedVideo);
    return _encrypter.decrypt(encrypted, iv: this._iv);
  }

  @override
  String encrypt(String video) {
    return _encrypter.encrypt(video, iv: _iv).base64;
  }
}
