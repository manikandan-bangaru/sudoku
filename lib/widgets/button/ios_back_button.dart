import 'package:flutter/material.dart';
import '/utils/game_routes.dart';
import '/utils/game_sizes.dart';
import '/widgets/app_bar_action_button.dart';

class IosBackButton extends StatelessWidget {
  const IosBackButton({super.key, this.onPressed, this.iconSize});

  final VoidCallback? onPressed;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return AppBarActionButton(
      icon: Icons.arrow_back_ios_new,
      onPressed: () => GameRoutes.back(),
      iconSize: iconSize ?? GameSizes.getHeight(0.025),
    );
  }
}
