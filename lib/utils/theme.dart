
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:regula_doc_scanner_app/utils/style.dart';


import 'color.dart';

ThemeData appTheme = ThemeData(
  useMaterial3: true,
scaffoldBackgroundColor: boxColor,
colorScheme: ColorScheme(
brightness: Brightness.light,
primary: primaryColor,        // Primary color
onPrimary: Colors.white,           // Text on primary
secondary: secondaryColor,      // Secondary
onSecondary: accentColor,     // Background color
// onBackground: Color(0xff0D0D12),   // Text on background
surface: Color(0xffF5F5F5),        // Cards, sheets, etc.
onSurface: Color(0xff0D0D12),      // Text on surface
error: Colors.red,
onError: Colors.white,
tertiary: hintColor,       // Accent/hint
onTertiary: Colors.white,
),

    scrollbarTheme:  ScrollbarThemeData(
      mainAxisMargin: 5.w,
      crossAxisMargin: 3.w,
      minThumbLength: 100.h,
      trackBorderColor: WidgetStateProperty.all(borderColor),
      interactive:true,
      trackVisibility: WidgetStateProperty.all(true),
      thumbVisibility:  WidgetStateProperty.all(true),
      thumbColor: WidgetStateProperty.all(checkBoxColor), // Bar color
      trackColor: WidgetStateProperty.all(settingsBgColor),
      radius: Radius.circular(3.r),
      thickness: WidgetStateProperty.all(5.w),
    ),
    // primarySwatch: Colors.blue,
    // brightness: Brightness.light,
    // primaryColor: primaryColor,
    // accentColor: accentColor,
    // scaffoldBackgroundColor: scaffoldBackgroundColor,
    // disabledColor: disableColor,
    // hintColor: hintColor,
    // primaryColorLight: primaryColor,
    // fontFamily: 'DMSans',
    // cursorColor: hintColor,
    // buttonColor: primaryColor,
    // dividerColor: dividedColor,
    // bottomAppBarColor: Colors.white,
    // backgroundColor: Colors.white,
    // canvasColor: Colors.white,
    // focusColor: Colors.white,
    // hoverColor: Colors.white,
    pageTransitionsTheme: PageTransitionsTheme(builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
    }),
    // buttonTheme: ButtonThemeData(),
    // outlinedButtonTheme: OutlinedButtonThemeData(
    //   style: ButtonStyle(
    //     // padding: WidgetStateProperty.resolveWith(
    //     //         (states) => EdgeInsets.symmetric(horizontal: 13, vertical: 3)),
    //     foregroundColor:
    //     WidgetStateProperty.resolveWith((states) => textColor(states)),
    //     textStyle: WidgetStateProperty.resolveWith(outlinedButtonTextStyle),
    //     backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
    //     shape: MaterialStateProperty.resolveWith(outlinedBorder),
    //     elevation: MaterialStateProperty.resolveWith(elevation),
    //     side:
    //     MaterialStateProperty.resolveWith((states) => borderColor(states)),
    //   ),
    // ),

    // textButtonTheme: TextButtonThemeData(
    //   style: ButtonStyle(
    //     padding: MaterialStateProperty.resolveWith(
    //             (states) => EdgeInsets.symmetric(horizontal: 13, vertical: 3)),
    //     foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
    //     textStyle: MaterialStateProperty.resolveWith(textButtonTextStyle),
    //     backgroundColor: MaterialStateProperty.resolveWith(backgroundColor),
    //     shape: MaterialStateProperty.resolveWith(outlinedBorder),
    //     elevation: MaterialStateProperty.resolveWith(elevation),
    //   ),
    // ),
    // outlinedButtonTheme: ,
    textTheme: TextTheme(
      headlineSmall: semiBoldText, //24 size 30 height

///Medium
titleSmall: mediumText,
      //14 & 20 height
labelMedium: mediumText.copyWith(
        fontSize: 12.sp,
        //height: 16.sp,
        color: hintColor2,
      ),
titleLarge:mediumText.copyWith(
  fontSize: 20.sp,
  //height: 24.sp,

),
titleMedium: mediumText.copyWith(
        fontSize: 16.sp,
       // height: 24.sp,
        color: accentColor,
      ),

///regular
bodyMedium: regularText, //14 & 20 height
bodySmall: regularText.copyWith(fontSize: 12.sp,
        // height: 16.sp,
),
),

    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
         shape: WidgetStateProperty.resolveWith((states) => RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),),
            padding:
            WidgetStateProperty.resolveWith((states) => EdgeInsets.zero),

           // elevation: WidgetStateProperty.resolveWith(elevation),
            // foregroundColor: MaterialStateProperty.resolveWith(backgroundColor),
            shadowColor: WidgetStateProperty.resolveWith((states) => Colors.transparent,),

            foregroundColor: WidgetStateProperty.resolveWith((states) { // Text color
              return states.contains(WidgetState.disabled)
                  ? Colors.grey
                  : buttonTextColor;
            }),
            backgroundColor: WidgetStateProperty.resolveWith(backgroundButtonColor),
            textStyle: WidgetStateProperty.resolveWith(textStyle)
        )
    ),


);

TextStyle? textStyle(Set<WidgetState> state) {
  if (state.contains(WidgetState.disabled)) {
    return mediumText.copyWith(
      color:buttonTextColor,
    );
  }
  //print("Text: $state");
  return mediumText.copyWith(
    color: buttonTextColor,
  );
}


Color? backgroundButtonColor(Set<WidgetState> state) {
  if (state.contains(WidgetState.disabled)) {
    return hintColor;
  }
  return Colors.transparent;
}


// ButtonThemeData buttonThemeData = ButtonThemeData(
//     elevation: MaterialStateProperty.resolveWith(elevation),
//     buttonColor: MaterialStateProperty.resolveWith(backgroundColor),
//     textStyle: MaterialStateProperty.resolveWith(textStyle))
// )
//
// const Set<MaterialState> states = <MaterialState>{
//   MaterialState.pressed,
//   MaterialState.hovered,
//   MaterialState.selected
// };
//
OutlinedBorder? outlinedBorder(state) {
  if (state == WidgetState.disabled) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.r),
    );
  } else {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.r),
    );
  }
}
//
// double? elevation(state) {
//   if (state == MaterialState.disabled) {
//     return 0.0;
//   }
//
//   if (states.contains(state)) {
//     return 0.0;
//   }
// }


//
// TextStyle? textButtonTextStyle(Set<MaterialState> state) {
//   print("Text: $state");
//   return mediumText.copyWith(color: Colors.white, fontSize: 11);
// }
//
// TextStyle? outlinedButtonTextStyle(Set<MaterialState> state) {
//   if (state.contains(MaterialState.disabled)) {
//     return mediumText.copyWith(color: disableColor, fontSize: 11);
//   } else
//     return mediumText.copyWith(color: primaryColor, fontSize: 11);
// }
//
// Color? shadowColor(Set<MaterialState> state) {
//   return Colors.transparent;
// }
//
Color? textColor(Set<WidgetState> state) {
  if (state.contains(WidgetState.disabled)) {
    return hintColor;
  } else {
    return backgroundButtonColor(state);
  }
}
//
// BorderSide? borderColor(Set<MaterialState> state) {
//   if (state.contains(MaterialState.disabled)) {
//     return BorderSide(color: disableColor);
//   } else
//     return BorderSide(color: primaryColor);
// }