import 'dart:typed_data';

import 'package:flutter/material.dart';

// Gerencia o estado da foto de perfil.
// Usamos ChangeNotifier para atualizar a UI quando a foto mudar.
class ProfileStore extends ChangeNotifier {
  ProfileStore._();
  
  // Instância global única.
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
