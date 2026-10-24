import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:osho/features/personalization/models/user_model.dart';

/// Profile data of the signed-in tailor (Supabase table `users`, bucket
/// `avatars`). Errors are thrown as short French messages, ready to show.
class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final _supabase = Supabase.instance.client;

  /// Bucket for profile photos, one file per user: `<user id>/avatar.<ext>`.
  static const avatarBucket = 'avatars';

  String get _userId {
    final id = _supabase.auth.currentUser?.id;
    if (id == null) throw 'Session expirée. Reconnectez-vous.';
    return id;
  }

  /// Fetch the signed-in user's profile.
  Future<UserModel> fetchUserDetails() async {
    try {
      final response =
          await _supabase.from('users').select().eq('id', _userId).single();
      return UserModel.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching user details: $e');
      throw 'Profil indisponible.';
    }
  }

  /// Save the editable fields of the signed-in user's own profile.
  Future<void> updateUserDetails(UserModel updatedUser) async {
    try {
      await _supabase
          .from('users')
          .update(updatedUser.toProfileUpdateJson())
          .eq('id', _userId);
    } catch (e) {
      debugPrint('Error updating user details: $e');
      throw 'Enregistrement impossible.';
    }
  }

  static const _editableFields = {'full_name', 'phone', 'avatar_url'};

  /// Update a user-editable field in the users table.
  /// Privileged columns (role, email, id) are rejected.
  Future<void> updateSingleField(Map<String, dynamic> json) async {
    final forbidden = json.keys.where((k) => !_editableFields.contains(k));
    if (forbidden.isNotEmpty) {
      throw 'Champ non modifiable : ${forbidden.join(', ')}';
    }
    try {
      await _supabase.from('users').update(json).eq('id', _userId);
    } catch (e) {
      debugPrint('Error updating field: $e');
      throw 'Enregistrement impossible.';
    }
  }

  /// Upload a profile photo and return its public URL. The URL carries a
  /// version so that the new photo replaces the cached one right away.
  Future<String> uploadAvatar(Uint8List bytes, {required String extension}) async {
    final ext = extension.toLowerCase().replaceAll('.', '');
    final path = '$_userId/avatar.$ext';
    try {
      final storage = _supabase.storage.from(avatarBucket);
      await storage.uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(
          upsert: true,
          contentType: ext == 'png' ? 'image/png' : 'image/jpeg',
        ),
      );
      final url = storage.getPublicUrl(path);
      return '$url?v=${DateTime.now().millisecondsSinceEpoch}';
    } on StorageException catch (e) {
      debugPrint('Avatar upload failed: ${e.statusCode} ${e.message}');
      if (e.message.toLowerCase().contains('bucket')) {
        throw 'Stockage des photos non configuré.';
      }
      throw 'Envoi de la photo impossible.';
    } catch (e) {
      debugPrint('Avatar upload failed: $e');
      throw 'Envoi de la photo impossible.';
    }
  }
}
