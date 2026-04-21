import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/utils/device/device_utility.dart';

import '../../../utils/constants/sizes.dart';

class OAppBar extends StatelessWidget implements PreferredSizeWidget {
  const OAppBar(
      {super.key,
      this.title,
      this.actions,
      this.leadingIcon,
      this.leadingOnPressed,
      this.showBackArrow = false, 
      this.subTitle});

  final Widget? title;
  final Widget? subTitle;
  final bool showBackArrow;
  final IconData? leadingIcon;
  final List<Widget>? actions;
  final VoidCallback? leadingOnPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: OSizes.defaultPadding),
      child: AppBar(
          automaticallyImplyLeading: false,
          leading: showBackArrow
              ? IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Iconsax.arrow_left))
              : leadingIcon != null
                  ? IconButton(
                      onPressed: leadingOnPressed, icon: Icon(leadingIcon))
                  : null,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title ?? SizedBox(),
              subTitle ?? SizedBox(),
            ],
          ),
          actions: actions,

      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(ODeviceUtils.getAppBarHeight());
}
