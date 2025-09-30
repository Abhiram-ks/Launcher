import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashBloc(local: AuthLocalDatasource())..add(SplashRequest()),
      child: BlocListener<SplashBloc, SplashState>(
        listener: (context, splashState) {
          splashStateHandle(context, splashState);
        },
        child: Scaffold(
          backgroundColor: AppPalette.blueColor,
          body: ColoredBox(
            color: AppPalette.blueColor,
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                AppImages.logoWhite,
                                fit: BoxFit.contain,
                                height: 70,
                                width: 70,
                              ),
                              ConstantWidgets.hight10(context),
                              Text(
                                "True Auth",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: AppPalette.whiteColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 12,
                            width: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              backgroundColor: AppPalette.greyColor,
                              color: AppPalette.whiteColor,
                            ),
                          ),
                          ConstantWidgets.width20(context),
                          Text(
                            "Loading",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppPalette.whiteColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      ConstantWidgets.hight30(context),
                      Text(
                        "Safely protect your valuable assets",
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppPalette.whiteColor,
                        ),
                      ), ConstantWidgets.hight30(context),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
