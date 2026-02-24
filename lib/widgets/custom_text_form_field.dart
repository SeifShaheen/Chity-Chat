import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../utils/validators.dart';

enum InputType { text, email, password, number, phone }

class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    super.key,
    this.obscureText = false,
    this.inputType = InputType.text,
    this.hintText = '',
    this.labelText,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.controller,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.padding,
    this.textColor = AppColors.textDark,
    this.hintColor = AppColors.textDarkSecondary,
    this.borderColor = AppColors.inputBorder,
    this.focusedBorderColor = AppColors.inputFocusedBorder,
    this.fillColor = AppColors.inputBackground,
    this.isFilled = true,
  });

  final bool obscureText;
  final InputType inputType;
  final String hintText;
  final String? labelText;
  final String? Function(String?)? validator;
  final void Function(String?)? onChanged;
  final void Function(String?)? onSaved;
  final TextEditingController? controller;
  final int maxLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final EdgeInsetsGeometry? padding;
  final Color textColor;
  final Color hintColor;
  final Color borderColor;
  final Color focusedBorderColor;
  final Color fillColor;
  final bool isFilled;

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late bool _obscureText;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ??
          const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.smallPadding,
          ),
      child: TextFormField(
        controller: _controller,
        obscureText: _obscureText,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        maxLines: widget.maxLines,
        maxLength: widget.maxLength,
        keyboardType: _getKeyboardType(),
        textInputAction: _getTextInputAction(),
        onChanged: widget.onChanged,
        onSaved: widget.onSaved,
        validator: widget.validator ?? _getDefaultValidator(),
        style: TextStyle(color: widget.textColor),
        decoration: InputDecoration(
          hintText: widget.hintText,
          labelText: widget.labelText,
          prefixIcon: widget.prefixIcon,
          suffixIcon: _buildSuffixIcon(),
          filled: widget.isFilled,
          fillColor: widget.fillColor,
          hintStyle: TextStyle(color: widget.hintColor),
          labelStyle: TextStyle(color: widget.hintColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            borderSide: BorderSide(color: widget.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            borderSide: BorderSide(color: widget.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            borderSide: BorderSide(color: widget.focusedBorderColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            borderSide: BorderSide(color: widget.borderColor.withOpacity(0.5)),
          ),
        ),
      ),
    );
  }

  TextInputType _getKeyboardType() {
    switch (widget.inputType) {
      case InputType.email:
        return TextInputType.emailAddress;
      case InputType.number:
        return TextInputType.number;
      case InputType.phone:
        return TextInputType.phone;
      default:
        return TextInputType.text;
    }
  }

  TextInputAction _getTextInputAction() {
    switch (widget.inputType) {
      case InputType.email:
        return TextInputAction.next;
      case InputType.password:
        return TextInputAction.done;
      default:
        return TextInputAction.next;
    }
  }

  String? Function(String?)? _getDefaultValidator() {
    switch (widget.inputType) {
      case InputType.email:
        return Validators.validateEmail;
      case InputType.password:
        return Validators.validatePassword;
      default:
        return (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        };
    }
  }

  Widget? _buildSuffixIcon() {
    if (widget.inputType == InputType.password) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility : Icons.visibility_off,
          color: widget.hintColor,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }
    return widget.suffixIcon;
  }
}
