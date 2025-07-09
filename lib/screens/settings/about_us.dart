import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/data/repositories/Setting/setting_repo.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../utils/widgets/back_arrow.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widgets/html_widget.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  String? aboutUs; // Use String? for nullable
  bool isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    _getAboutUs();
  }

  Future<void> _getAboutUs() async {
    var result = await SettingRepo().aboutUs();
    setState(() {
      aboutUs = result['settings']['about_us'];
      isLoading = false; // Set loading to false after data is fetched
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.backGroundColor,

      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  BackArrow(
                    iSBackArrow: true,
                    fromDash: false,
                    title: AppLocalizations.of(context)!.aboutus,
                  ),
                  SizedBox(height: 20.h),
                  if (!isLoading)
                    htmlWidget(aboutUs!,context),// Show content only if not loading
                    // HtmlWidget(
                    //   aboutUs!,
                    //   textStyle: TextStyle(
                    //     fontWeight: FontWeight.w400,
                    //     fontSize: 14.sp,
                    //     color: Theme.of(context).colorScheme.textClrChange, // Text color
                    //   ),
                    //   customStylesBuilder: (element) {
                    //     return {
                    //       'background-color': 'transparent', // Ensures no background color
                    //     };
                    //   },
                    // ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
          if (isLoading) // Show loader if loading
            Center(
              child: const SpinKitFadingCircle(
                color: AppColors.primary,
                size: 40.0,
              ),
            ),
        ],
      ),
    );
  }
}
