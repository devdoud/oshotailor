import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
import 'package:osho/utils/theme/osho_tokens.dart';

class OFullScreenLoader {
  /// Open a full-screen loading dialog with the given text.
  static void openLoadingDialog(String text) {
    Get.dialog(
      PopScope(
        canPop: false, // Disable Popping with the back button
        child: Container(
          color: OshoTokens.of(Get.context!).bg,
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              const SizedBox(height: 250),
              // Use the new Modern Spinner instead of Lottie animation
              const OLoader(size: 40),
              const SizedBox(height: 24),
              Text(
                text,
                style: Theme.of(Get.context!).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Stop the currently open loading dialog.
  /// This method doesn't return anything
  static void stopLoading() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }

}