import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taskify/config/colors.dart';
import 'package:taskify/utils/widgets/custom_text.dart';

import '../../../bloc/setting/settings_bloc.dart';

class CustomTextField extends StatefulWidget {
  final String? subtitle;
  final String title; // Required title text
  final String hinttext; // Required title text
  final bool isRequired; // Flag indicating if the field is required
  final bool? isPassword; // Flag indicating if the field is required
  final TextEditingController
      controller; // Text editing controller for the field
  final TextInputType
      keyboardType; // Type of keyboard to show (e.g., TextInputType.text)// Validation function for the field
  final void Function(String?) onSaved; // Callback when the field is saved
  final void Function(String?)? onchange; // Callback when the field is saved
  final void Function(String)?
      onFieldSubmitted; // Callback when the field is submitted
  final bool isLightTheme; // Flag for light/dark theme// Flag for light/dark theme
  final bool? readonly; // Flag for light/dark theme
  final bool? currency; // Flag for light/dark theme
  final double height;
  final List<TextInputFormatter>? inputFormatters; // Flag for light/dark theme

  CustomTextField({
    super.key,
    required this.title,
    this.subtitle,
    this.currency,
    this.isPassword = false,
    this.readonly = false,
    required this.hinttext,
    this.isRequired = false,
    this.inputFormatters,
    double? height, // Accept a nullable height
    required this.controller,
    this.keyboardType = TextInputType.text,
    required this.onSaved,

    this.onchange,
    this.onFieldSubmitted,
    required this.isLightTheme,
  }) : height = height ?? 40.h; // Assign default value in the initializer


  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _showPassword = true;
  String? currency;
  @override
  Widget build(BuildContext context) {
    currency = context.read<SettingsBloc>().currencySymbol;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: widget.title,
                color: Theme.of(context).colorScheme.textClrChange,
                size: 16.sp,
                fontWeight: FontWeight.w700,
              ),
              if (widget.currency == true && currency != null)
                Text(
                  " ($currency) ",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.textClrChange,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),


              if (widget.isRequired)
                const Text(
                  " *",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              if (widget.subtitle != null)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 5.w), // Add spacing if needed
                    child: CustomText(
                      text: widget.subtitle!,
                      color: AppColors.greyColor,
                      size: 12.sp,
                      fontWeight: FontWeight.w500,
                      maxLines: null, // Allow unlimited lines
                    ),
                  ),
                ),


            ],
          ),
        ),
        SizedBox(
          height: 5.h,
        ),
        widget.height > 40.h
            ? IntrinsicHeight(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(

                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    obscureText:
                        widget.isPassword == true ? _showPassword : false,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                      color: Theme.of(context).colorScheme.textClrChange,
                    ),
                    controller: widget.controller,
                    keyboardType: widget.keyboardType,
                    maxLines: null, // Allow multiple lines based on content
                    minLines: 1, // Start with 1 line
                    onSaved: widget.onSaved,
                    onChanged: widget.onchange,
                    inputFormatters: widget.inputFormatters,
                    readOnly: widget.readonly == true,
                    onFieldSubmitted: widget.onFieldSubmitted,
                    decoration: InputDecoration(
                      hintText: widget.hinttext,
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14.sp,
                        color: AppColors.greyForgetColor,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: widget.height > 40.h
                            ? 10.h
                            : 5.h, // More padding for multiline, less for single-line

                        horizontal: 10.w,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              )
            : Container(
                height:
                    40.h, // Default to 40.h if height is not passed
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(

                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  // ✅ Ensures the TextField is centered within the Container
                  child: TextFormField(
                    obscureText:
                        widget.isPassword == true ? _showPassword : false,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                      color: Theme.of(context).colorScheme.textClrChange,
                    ),
                    controller: widget.controller,
                    keyboardType: widget.keyboardType,
                    maxLines: 1,
                    textAlignVertical: TextAlignVertical
                        .center, // ✅ Ensures vertical alignment
                    onSaved: widget.onSaved,
                    onChanged: widget.onchange,
                    inputFormatters: widget.inputFormatters,
                    readOnly: widget.readonly == true,
                    onFieldSubmitted: widget.onFieldSubmitted,
                    decoration: InputDecoration(
                      suffixIcon: widget.isPassword == true
                          ? InkWell(
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              onTap: () {
                                setState(() {
                                  _showPassword = !_showPassword;
                                });
                              },
                              child: Padding(
                                padding: EdgeInsetsDirectional.only(end: 10.w),
                                child: Icon(
                                  _showPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .fontColor
                                      .withValues(alpha: 0.4),
                                  size: 22.sp,
                                ),
                              ),
                            )
                          : null,
                      hintText: widget.hinttext,
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14.sp,
                        color: AppColors.greyForgetColor,
                      ),
                      contentPadding:  widget.isPassword == true ?EdgeInsets.symmetric(
                        vertical: (40.h) / 4, // ✅ Ensures balanced padding
                        horizontal: 10.w,
                      ):EdgeInsets.symmetric(
                        vertical: (40.h) / 4, // ✅ Ensures balanced padding
                        horizontal: 10.w,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              )
      ],
    );
  }
}
