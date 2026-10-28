import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Servicio encargado exclusivamente de gestionar la imagen del perfil.
///
/// La imagen seleccionada por el usuario se copia al almacenamiento
/// privado de la aplicación para que permanezca disponible después
/// de cerrar y volver a abrir el juego.
class ProfileImageService {
  static const String _fileName = 'profile_avatar.jpg';

  /// Obtiene la ubicación permanente donde guardaremos el avatar.
  Future<File> _getProfileImageFile() async {
    final directory = await getApplicationDocumentsDirectory();

    return File('${directory.path}/$_fileName');
  }

  /// Guarda una imagen seleccionada por el usuario.
  ///
  /// Copia la imagen original al almacenamiento privado de la aplicación.
  /// Devuelve el archivo permanente guardado.
  Future<File> saveProfileImage(File selectedImage) async {
    final profileImageFile = await _getProfileImageFile();

    return selectedImage.copy(profileImageFile.path);
  }

  /// Recupera la imagen de perfil guardada.
  ///
  /// Devuelve null si todavía no existe ninguna imagen.
  Future<File?> getProfileImage() async {
    final profileImageFile = await _getProfileImageFile();

    if (await profileImageFile.exists()) {
      return profileImageFile;
    }

    return null;
  }

  /// Comprueba si existe una imagen de perfil guardada.
  Future<bool> hasProfileImage() async {
    final profileImageFile = await _getProfileImageFile();

    return profileImageFile.exists();
  }

  /// Elimina la imagen de perfil guardada.
  ///
  /// Esto nos permitirá posteriormente implementar una opción
  /// como "Eliminar foto" y volver a mostrar la inicial del usuario.
  Future<void> deleteProfileImage() async {
    final profileImageFile = await _getProfileImageFile();

    if (await profileImageFile.exists()) {
      await profileImageFile.delete();
    }
  }
}
