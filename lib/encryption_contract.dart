import 'video_model.dart';

abstract class IEncryption {
  String encrypt(String video);
  String decrypt(String encryptedVideo);
}
