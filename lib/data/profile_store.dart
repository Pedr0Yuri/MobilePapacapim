import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Bytes da foto de perfil escolhida (somente na sessão do app, sem upload).
class ProfileStore extends ChangeNotifier {
  ProfileStore._();
  static final ProfileStore instance = ProfileStore._();

  Uint8List? localProfileImageBytes;

  void setLocalProfileImageBytes(Uint8List bytes) {
    localProfileImageBytes = bytes;
    notifyListeners();
  }

  ImageProvider? get profileImageProvider {
    final bytes = localProfileImageBytes;
    if (bytes == null) return null;
    return MemoryImage(bytes);
  }
}
