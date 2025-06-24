import 'package:flutter/material.dart';
import '../styles/app_styles.dart';

class AuthWidgets {
  // Styled TextFormField for authentication
  static Widget styledTextFormField({
    required TextEditingController controller,
    required String labelText,
    IconData? prefixIcon,
    bool obscureText = false,
    TextInputType? keyboardType,
    int? maxLength,
    String? Function(String?)? validator,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLength: maxLength,
      validator: validator,
      onTap: onTap,
      style: const TextStyle(color: AppStyles.white),
      decoration: AppStyles.getAuthInputDecoration(
        labelText: labelText,
        prefixIcon: prefixIcon,
      ),
    );
  }

  // Loading Button
  static Widget loadingButton({
    required VoidCallback? onPressed,
    required String text,
    bool isLoading = false,
    ButtonStyle? style,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: style ?? AppStyles.getPrimaryButtonStyle(),
        child: isLoading
            ? const CircularProgressIndicator()
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  // Transparent Container
  static Widget transparentContainer({
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.all(AppStyles.defaultPadding),
      decoration: AppStyles.getTransparentContainerDecoration(),
      child: child,
    );
  }

  // Quick Login Button
  static Widget quickLoginButton({
    required VoidCallback onPressed,
    required String label,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.account_circle),
      label: Text(label),
      style: AppStyles.getSecondaryButtonStyle(),
    );
  }

  // Spacing Widgets
  static const Widget defaultSpacing = SizedBox(height: AppStyles.defaultSpacing);
  static const Widget largeSpacing = SizedBox(height: AppStyles.largeSpacing);
  static const Widget defaultPadding = Padding(
    padding: EdgeInsets.all(AppStyles.defaultPadding),
  );
} 