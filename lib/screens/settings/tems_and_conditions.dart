import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:taskify/data/repositories/Setting/setting_repo.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../utils/widgets/back_arrow.dart';
import '../widgets/html_widget.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  State<TermsAndConditionsScreen> createState() =>
      _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  String? termsAndConditions; // Use String? for nullable
  bool isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    _getTermsAndConditions();
  }

  Future<void> _getTermsAndConditions() async {
    var result = await SettingRepo().termsAndConditions();
    setState(() {
      termsAndConditions = result['settings']['terms_conditions'];
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
                    title:
                    AppLocalizations.of(context)!.termsandconditions,
                  ),
                  SizedBox(height: 20.h),
                  if (!isLoading) // Show content only if not loading
                    htmlWidget(termsAndConditions!,context),
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
