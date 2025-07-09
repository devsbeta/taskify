import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/data/repositories/Setting/setting_repo.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../utils/widgets/back_arrow.dart';
import '../widgets/html_widget.dart';



class PrivacyPolicyScreen extends StatefulWidget {
  final String title;

  const PrivacyPolicyScreen({super.key, required this.title});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  String? privacypolicy; // Use String? for nullable
  String? value; // Use String? for nullable
  bool isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    _getPrivacyPolicy();
  }

  Future<void> _getPrivacyPolicy() async {
    var result = await SettingRepo().privacyPolicy();
    setState(() {
      privacypolicy = result['settings']['privacy_policy'];
      ;
      isLoading = false; // Set loading to false after data is fetched
    });

  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Theme.of(context).colorScheme.backGroundColor,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // SizedBox(height: 20.h),
                  BackArrow(
                    isPen: false,
                    iSBackArrow: true,
                    fromDash: false,
                    title: AppLocalizations.of(context)!.privacypolicy,
                  ),
                  SizedBox(height: 20.h),
                  // Content for the privacy policy
                  if (!isLoading)
                    htmlWidget(privacypolicy!,context,),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
          if (isLoading)
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
