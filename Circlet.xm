//
//  Circlet.xm
//  Circlet
//
//  Created by Julian Weiss on 1/5/14.
//  Copyright (c) 2014 insanj. All rights reserved.
//

#import "CRHeaders.h"
#import "UIImage+Circlet.h"
#import "CRPrefsManager.h"

// Tiny algorithm to cheat the Textual style of some of its overbearing outline thickness
#define LESSENED_THICKNESS(sty) ((sty == CircletStyleTextual || sty == CircletStyleTextualInverse) ? 1.0 / 8.0 : 0.0);

static CRPrefsManager *preferencesManager;

static CRPrefsManager * sharedPreferencesManager () {
	return ((preferencesManager = [CRPrefsManager sharedManager]));
}

typedef NS_ENUM(NSUInteger, CircletPosition) {
    CircletPositionSignal = 0,
    CircletPositionWifi,
    CircletPositionData,
    CircletPositionTimeMinute,
	CircletPositionTimeHour,
    CircletPositionBattery,
    CircletPositionCharging,
    CircletPositionLowBattery,
};

/***************************************************************************************/
/***************************** Static C-irclet Functions *******************************/
/***************************************************************************************/

// Retrieves saved radius value (or default radius, CRDEFAULTRADIUS)
static CGFloat circletRadiusFromPosition(CircletPosition posit) {
	NSNumber *value;
	switch (posit) {
		default:
		case CircletPositionSignal:
			value = [sharedPreferencesManager() numberForKey:@"signalSize"];
			break;
		case CircletPositionWifi:
			value = [sharedPreferencesManager() numberForKey:@"wifiSize"];
			break;
		case CircletPositionData:
			value = [sharedPreferencesManager() numberForKey:@"dataSize"];
			break;
		case CircletPositionTimeMinute:
		case CircletPositionTimeHour:
			value = [sharedPreferencesManager() numberForKey:@"timeSize"];
			return value ? [value floatValue] * 2.0 : CRDEFAULTRADIUS * 2.0;
		case CircletPositionBattery:
		case CircletPositionCharging:
		case CircletPositionLowBattery:
			value = [sharedPreferencesManager() numberForKey:@"batterySize"];
			break;
	}

	return value ? [value floatValue] : CRDEFAULTRADIUS;
}

static CGFloat circletWidthFromPosition(CircletPosition posit) {
	NSNumber *value;
	CGFloat diameter;

	switch (posit) {
		case CircletPositionSignal:
			value = [sharedPreferencesManager() numberForKey:@"signalSize"];
			diameter = value ? [value floatValue] * 2.0 : CRDEFAULTRADIUS * 2.0;
			return diameter + (diameter / 10.0);
		case CircletPositionWifi: 
			value = [sharedPreferencesManager() numberForKey:@"wifiSize"];
			break;
		case CircletPositionData:
			value = [sharedPreferencesManager() numberForKey:@"dataSize"];
			break;
		case CircletPositionTimeMinute:
		case CircletPositionTimeHour:
			value = [sharedPreferencesManager() numberForKey:@"timeSize"];
			diameter = [value floatValue] * 2.0;
			return (diameter * 2.0) + (diameter / 10.0);
		case CircletPositionBattery:
		case CircletPositionCharging:
		case CircletPositionLowBattery:
			value = [sharedPreferencesManager() numberForKey:@"batterySize"];
	}

	diameter = [value floatValue] * 2.0;
	return diameter + (diameter / 10.0);
}

static CircletStyle circletStyleFromPosition(CircletPosition posit) {
	NSNumber *value;
	BOOL invert;

	switch (posit) {
		default:
		case CircletPositionSignal:
			value = [sharedPreferencesManager() numberForKey:@"signalStyle"];
			invert = [sharedPreferencesManager() boolForKey:@"signalInvert"];
			break;
		case CircletPositionWifi:
			value = [sharedPreferencesManager() numberForKey:@"wifiStyle"];
			invert = [sharedPreferencesManager() boolForKey:@"wifiInvert"];
			break;
		case CircletPositionData:
			value = [sharedPreferencesManager() numberForKey:@"dataStyle"];
			invert = [sharedPreferencesManager() boolForKey:@"dataInvert"];
			break;
		case CircletPositionTimeMinute:
		case CircletPositionTimeHour:
			value = [sharedPreferencesManager() numberForKey:@"timeStyle"];
			invert = [sharedPreferencesManager() boolForKey:@"timeInvert"];
			break;
		case CircletPositionBattery:
		case CircletPositionCharging:
		case CircletPositionLowBattery:
			value = [sharedPreferencesManager() numberForKey:@"batteryStyle"];
			invert = [sharedPreferencesManager() boolForKey:@"batteryInvert"];
			break;
	}

	CircletStyle style = value ? [value integerValue] : CircletStyleFill;
	if (invert) {
		style += 4;
	}

	return style;
}

// Returns color value based on preferences saved value. Boolean parameter
// is only for default fallbacks, if the key is not found in preferences.
static UIColor * circletColorForKey(BOOL light, NSString *key) {
	NSString *value = [sharedPreferencesManager() stringForKey:key];
	NSDictionary *titleToColor = CRTITLETOCOLOR;
	UIColor *valueInDict = titleToColor[value];

	if (value && !valueInDict) {
		NSString *colorString = [sharedPreferencesManager() stringForKey:[key stringByAppendingString:@"Custom"]];
		CIColor *customColor = [CIColor colorWithString:colorString];
		return [UIColor colorWithRed:customColor.red green:customColor.green blue:customColor.blue alpha:customColor.alpha];
	}

	else if (!value || !valueInDict) {
		if ([key rangeOfString:@"lowBattery"].location != NSNotFound) {
			return titleToColor[@"Red"];
		}

		else if ([key rangeOfString:@"charging"].location != NSNotFound) {
			return titleToColor[@"Green"];
		}

		return light ? titleToColor[@"White"] : titleToColor[@"Black"];
	}

	return valueInDict;
}

// Retrieves proper color value key for preferences, based on position and light-ness given
static UIColor * circletColorForPosition(BOOL light, CircletPosition posit){
	NSString *positionPrefix;
	switch (posit) {
		default:
		case CircletPositionSignal:
			positionPrefix = @"signal";
			break;
		case CircletPositionWifi:
			positionPrefix = @"wifi";
			break;
		case CircletPositionData:
			positionPrefix = @"data";
			break;
		case CircletPositionTimeMinute:
			positionPrefix = @"timeMinute";
			break;
		case CircletPositionTimeHour:
			positionPrefix = @"timeHour";
			break;
		case CircletPositionBattery:
			positionPrefix = @"battery";
			break;
		case CircletPositionCharging:
			positionPrefix = @"charging";
			break;
		case CircletPositionLowBattery:
			positionPrefix = @"lowBattery";
			break;
	}

	NSString *key = [NSString stringWithFormat:@"%@%@Color", positionPrefix, light ? @"Light" : @"Dark"];
	return circletColorForKey(light, key);
}

// Returns whether or not the class is enabled in settings
static BOOL circletEnabledForClassname(NSString *className) {
	if ([className isEqualToString:@"UIStatusBarSignalStrengthItemView"]) {
		NSNumber *value = [sharedPreferencesManager() numberForKey:@"signalEnabled"];
		return !value || [value boolValue];	// because of negation property
	}

	else if ([className isEqualToString:@"UIStatusBarServiceItemView"]) {
		return [sharedPreferencesManager() boolForKey:@"carrierEnabled"];
	}

	else if ([className isEqualToString:@"UIStatusBarDataNetworkItemView"]) {
		if (WIFI_CONNECTED) {
			return [sharedPreferencesManager() boolForKey:@"wifiEnabled"];
		}

		else {
			return [sharedPreferencesManager() boolForKey:@"dataEnabled"];
		}
	}

	else if ([className isEqualToString:@"UIStatusBarTimeItemView"]) {
		return [sharedPreferencesManager() boolForKey:@"timeEnabled"];
	}

	else if ([className isEqualToString:@"UIStatusBarBatteryItemView"]) {
		return [sharedPreferencesManager() boolForKey:@"batteryEnabled"];
	}

	return NO;
}

static UIImage * circletBlankImage() { /* WithScale(CGFloat scale) { */
	UIGraphicsBeginImageContextWithOptions(CGSizeMake(1.0, 1.0), NO, [UIScreen mainScreen].scale);
	UIImage *tiny = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return tiny;
}

// All iOS 7 and iOS 6 hooks
%group Shared

/***************************************************************************************/
/***************************** UIStatusBarItemView Hooks  ******************************/
/***************************************************************************************/

@interface UIStatusBarItemView (Circlet)
- (UIImage *)circletContentsImageForWhite:(BOOL)white;
- (UIImage *)circletContentsImageForWhite:(BOOL)white string:(NSString *)timeString;
@end

%hook UIStatusBarSignalStrengthItemView

%new - (UIImage *)circletContentsImageForWhite:(BOOL)white {
	int bars = MSHookIvar<int>(self, "_signalStrengthBars");
	CGFloat radius = circletRadiusFromPosition(CircletPositionSignal);
	CGFloat percentage = bars / 5.0;
	CircletStyle style = circletStyleFromPosition(CircletPositionSignal);

	if (style == CircletStyleTextual || style == CircletStyleTextualInverse) {
		percentage *= 5.0;
	}

	NSNumber *outline = [sharedPreferencesManager() numberForKey:@"signalOutline"];
	BOOL showOutline = !outline || [outline boolValue];

	CGFloat lessenedThickness = radius * LESSENED_THICKNESS(style);

	if (showOutline) {
		if (lessenedThickness > 0.0) {
			return [UIImage circletWithColor:circletColorForPosition(white, CircletPositionSignal) radius:radius percentage:percentage style:style thickness:lessenedThickness];
		}

		else {
			return [UIImage circletWithColor:circletColorForPosition(white, CircletPositionSignal) radius:radius percentage:percentage style:style];
		}
	}

	else {
		return [UIImage circletWithColor:circletColorForPosition(white, CircletPositionSignal) radius:radius percentage:percentage style:style thickness:0.0];
	}
}

- (_UILegibilityImageSet *)contentsImage {
	BOOL shouldOverride = circletEnabledForClassname(@"UIStatusBarSignalStrengthItemView");
	CRLOG(@"%@", shouldOverride ? @"override" : @"ignore");

	if (shouldOverride) {
		CGFloat w, a;
		[[[self foregroundStyle] textColorForStyle:[self legibilityStyle]] getWhite:&w alpha:&a];
		
		UIImage *image = [self circletContentsImageForWhite:(w >= 0.5)];
		return [%c(_UILegibilityImageSet) imageFromImage:image withShadowImage:image];
	}

	return %orig();
}

- (UIImage *)contentsImageForStyle:(int)arg1 {
	BOOL shouldOverride = circletEnabledForClassname(@"UIStatusBarSignalStrengthItemView");
	CRLOG(@"%@", shouldOverride ? @"override" : @"ignore");

	return shouldOverride ? [self circletContentsImageForWhite:YES] : %orig();
}

%end

%hook UIStatusBarDataNetworkItemView

%new - (UIImage *)circletContentsImageForWhite:(BOOL)white {
	CGFloat radius;
	CircletStyle style;
	
	BOOL showOutline;
	CGFloat lessenedThickness;

	int networkType = MSHookIvar<int>(self, "_dataNetworkType");
	CGFloat percentage;

	UIImage *image;
	if (networkType != 5) {
		radius = circletRadiusFromPosition(CircletPositionData);
		style = circletStyleFromPosition(CircletPositionData);
	
		NSNumber *outline = [sharedPreferencesManager() numberForKey:@"dataOutline"];
		showOutline = !outline || [outline boolValue];
	
		lessenedThickness = radius * LESSENED_THICKNESS(style);

		CTRadioAccessTechnology *radioTechnology = [[CTRadioAccessTechnology alloc] init];
		NSString *radioType = [radioTechnology.radioAccessTechnology stringByReplacingOccurrencesOfString:@"CTRadioAccessTechnology" withString:@""];
		[radioTechnology release];

		NSString *representativeString;
		if ([radioType isEqualToString:@"GPRS"]) {
			representativeString = @"o";
			percentage = 0.0;
		}

		if ([radioType isEqualToString:@"Edge"]) {
			representativeString = @"E";
			percentage = 0.25;
		}

		else if ([radioType isEqualToString:@"WCDMA"]) {
			representativeString = @"3G";
			percentage = 0.5;
		}

		else if ([@[@"HSDPA", @"HSUPA", @"CDMA1x", @"CDMAEVDORev0", @"CDMAEVDORevA", @"CDMAEVDORevB", @"HRPD"] containsObject:radioType]) {
			representativeString = @"4G";
			percentage = 0.75;
		}

		else if ([radioType rangeOfString:@"LTE"].location != NSNotFound) {
			representativeString = @"L";
			percentage = 1.0;
		}

		else {
			representativeString= @"!";
			percentage = 0.0;
		}

		if (lessenedThickness > 0.0) {
			if (showOutline) {
				image = [UIImage circletWithColor:circletColorForPosition(white, CircletPositionData) radius:radius string:representativeString invert:(style == CircletStyleTextualInverse) thickness:lessenedThickness];
			}

			else {
				image = [UIImage circletWithColor:circletColorForPosition(white, CircletPositionData) radius:radius string:representativeString invert:(style == CircletStyleTextualInverse) thickness:0.0];
			}
		}

		else {
			if (showOutline) {
				image = [UIImage circletWithColor:circletColorForPosition(white, CircletPositionData) radius:radius percentage:percentage style:style];
			}

			else {
				image = [UIImage circletWithColor:circletColorForPosition(white, CircletPositionData) radius:radius percentage:percentage style:style thickness:0.0];
			}
		}
	}

	else {
		radius = circletRadiusFromPosition(CircletPositionWifi);
		style = circletStyleFromPosition(CircletPositionWifi);
	
		NSNumber *outline = [sharedPreferencesManager() numberForKey:@"wifiOutline"];
		showOutline = !outline || [outline boolValue];
	
		lessenedThickness = radius * LESSENED_THICKNESS(style);

		int wifiState = MSHookIvar<int>(self, "_wifiStrengthBars");

		// Don't forget -- lessenedThickness is equivalent to a boolean "is textual." Here, we exploit
		// that privilege to intelligently employ the -::string alternative Circlet category method.
		if (lessenedThickness > 0.0) {
			percentage = wifiState;

			if (showOutline) {
				image = [UIImage circletWithColor:circletColorForPosition(white, CircletPositionWifi) radius:radius string:[@(percentage) stringValue] invert:(style == CircletStyleTextualInverse) thickness:lessenedThickness];
			}

			else {
				image = [UIImage circletWithColor:circletColorForPosition(white, CircletPositionWifi) radius:radius percentage:percentage style:style thickness:0.0];
			}
		}

		else {
			percentage = ((CGFloat)wifiState) / 3.0;

			if (showOutline) {
				image = [UIImage circletWithColor:circletColorForPosition(white, CircletPositionWifi) radius:radius percentage:percentage style:style];
			}

			else {
				image = [UIImage circletWithColor:circletColorForPosition(white, CircletPositionWifi) radius:radius percentage:percentage style:style thickness:0.0];
			}
		}
	}

	return image;
}

- (_UILegibilityImageSet *)contentsImage {
	BOOL shouldOverride = circletEnabledForClassname(@"UIStatusBarDataNetworkItemView");
	CRLOG(@"%@", shouldOverride ? @"override" : @"ignore");

	if (shouldOverride) {
		CGFloat w, a;
		[[[self foregroundStyle] textColorForStyle:[self legibilityStyle]] getWhite:&w alpha:&a];
		
		UIImage *image = [self circletContentsImageForWhite:(w >= 0.5)];
		return [%c(_UILegibilityImageSet) imageFromImage:image withShadowImage:image];
	}

	return %orig();
}

- (CGFloat)extraLeftPadding {
	BOOL shouldOverride = circletEnabledForClassname(@"UIStatusBarDataNetworkItemView");
	CRLOG(@"%@", shouldOverride ? @"override" : @"ignore");

	return shouldOverride ? 0.0 : %orig();
}

- (UIImage *)contentsImageForStyle:(int)arg1 {
	BOOL shouldOverride = circletEnabledForClassname(@"UIStatusBarDataNetworkItemView");
	CRLOG(@"%@", shouldOverride ? @"override" : @"ignore");

	return shouldOverride ? [self circletContentsImageForWhite:YES] : %orig();
}

%end

%hook UIStatusBarServiceItemView

%new - (UIImage *)circletContentsImageForWhite:(BOOL)white {
	UIColor *light, *dark;
	if (white) {
		light = [UIColor whiteColor];
		dark = [UIColor blackColor];
	}

	else {
		light = [UIColor blackColor];
		dark = [UIColor whiteColor];
	}

	NSString *savedText = [sharedPreferencesManager() stringForKey:@"carrierText"];
	NSString *clipped = [savedText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

	CGFloat radius = CRDEFAULTRADIUS;
	CGFloat lessenedThickness = radius * LESSENED_THICKNESS(CircletStyleTextualInverse);

	// If the saved carrier text is a valid, non-empty string
	if (savedText && clipped.length > 0) {
		return [UIImage circletWithColor:light radius:radius string:clipped invert:YES thickness:lessenedThickness];
	}

	// If the saved carrier text is an empty string
	else if (savedText && clipped.length == 0 && savedText.length > 0) {
		return circletBlankImage();
	}

	// If there is no valid saved carrier text
	else {
		NSString *serviceString = MSHookIvar<NSString *>(self, "_serviceString");
		NSString *serviceSingleString = serviceString && serviceString.length > 0 ? [serviceString substringToIndex:1] : @"C";
	 
		return [UIImage circletWithColor:light radius:radius string:serviceSingleString invert:YES thickness:lessenedThickness];
	}
}

- (_UILegibilityImageSet *)contentsImage {
	BOOL shouldOverride = circletEnabledForClassname(@"UIStatusBarServiceItemView");
	CRLOG(@"%@", shouldOverride ? @"override" : @"ignore");

	if (shouldOverride) {
		CGFloat w, a;
		[[[self foregroundStyle] textColorForStyle:[self legibilityStyle]] getWhite:&w alpha:&a];
		
		UIImage *image = [self circletContentsImageForWhite:(w >= 0.5)];
		return [%c(_UILegibilityImageSet) imageFromImage:image withShadowImage:image];
	}

	return %orig();
}

- (CGFloat)standardPadding {
	BOOL shouldOverride = circletEnabledForClassname(@"UIStatusBarServiceItemView") && [self circletContentsImageForWhite:YES].size.width <= 1.0;
	CRLOG(@"%@", shouldOverride ? @"override" : @"ignore");

	return shouldOverride ? 0.0 : %orig();
}

- (UIImage *)contentsImageForStyle:(int)arg1 {
	BOOL shouldOverride = circletEnabledForClassname(@"UIStatusBarServiceItemView");
	CRLOG(@"%@", shouldOverride ? @"override" : @"ignore");

	return shouldOverride ? [self circletContentsImageForWhite:YES] : %orig();
}

%end

%hook UIStatusBarTimeItemView

%new - (UIImage *)circletContentsImageForWhite:(BOOL)white string:(NSString *)timeString {
	CGFloat radius = circletRadiusFromPosition(CircletPositionTimeMinute);
	NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];
	
	CircletStyle style = circletStyleFromPosition(CircletPositionTimeMinute);
	NSNumber *outline = [sharedPreferencesManager() numberForKey:@"timeOutline"];
	BOOL showOutline = !outline || [outline boolValue];

	CGFloat lessenedThickness = radius * LESSENED_THICKNESS(style);
	lessenedThickness /= 3.0;

	if (lessenedThickness > 0.0) {
		NSArray *split = [timeString componentsSeparatedByString:@":"];
		NSString *hour = split[0];
		NSString *minute = [split[1] componentsSeparatedByString:@" "][0];

		if (showOutline) {
			CRLOG(@"calling for an outlined textual time double circlet, left color based on hour position and white (%@): %@, right color: %@", white ? @"YES" : @"NO", circletColorForPosition(white, CircletPositionTimeHour), circletColorForPosition(white, CircletPositionTimeMinute));
			return [UIImage doubleCircletWithLeftColor:circletColorForPosition(white, CircletPositionTimeHour) rightColor:circletColorForPosition(white, CircletPositionTimeMinute) radius:radius leftString:hour rightString:minute style:style thickness:lessenedThickness];
		}

		else {
			return [UIImage doubleCircletWithLeftColor:circletColorForPosition(white, CircletPositionTimeHour) rightColor:circletColorForPosition(white, CircletPositionTimeMinute) radius:radius leftString:hour rightString:minute style:style thickness:0.0];
		}
	}

	CGFloat hour = fmod([components hour], 12.0) / 12.0;
	CGFloat minute = [components minute] / 60.0;

	if (showOutline) {
		return [UIImage doubleCircletWithLeftColor:circletColorForPosition(white, CircletPositionTimeHour) rightColor:circletColorForPosition(white, CircletPositionTimeMinute) radius:radius leftPercentage:hour rightPercentage:minute style:style];
	} 

	else {
		return [UIImage doubleCircletWithLeftColor:circletColorForPosition(white, CircletPositionTimeHour) rightColor:circletColorForPosition(white, CircletPositionTimeMinute) radius:radius leftPercentage:hour rightPercentage:minute style:style thickness:0.0];
	}
}

- (_UILegibilityImageSet *)contentsImage {
	BOOL shouldOverride = circletEnabledForClassname(@"UIStatusBarTimeItemView");
	NSString *trimmedTimeString = [MSHookIvar<NSString *>(self, "_timeString") stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	CRLOG(@"%@, %@", shouldOverride ? @"override" : @"ignore", trimmedTimeString);

	if (shouldOverride && trimmedTimeString.length > 0) {
		CGFloat w, a;
		[[[self foregroundStyle] textColorForStyle:[self legibilityStyle]] getWhite:&w alpha:&a];

		UIImage *image = [self circletContentsImageForWhite:(w >= 0.5) string:trimmedTimeString];
		return [%c(_UILegibilityImageSet) imageFromImage:image withShadowImage:image];
	}

	return %orig();
}

- (UIImage *)contentsImageForStyle:(int)arg1 {
	BOOL shouldOverride = circletEnabledForClassname(@"UIStatusBarTimeItemView");
	NSString *trimmedTimeString = [MSHookIvar<NSString *>(self, "_timeString") stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

	CRLOG(@"%@, %@", shouldOverride ? @"override" : @"ignore", trimmedTimeString);
	return shouldOverride ? [self circletContentsImageForWhite:YES string:trimmedTimeString] : %orig();
}

%end

%hook UIStatusBarBatteryItemView

- (id)_accessoryImage {	
	BOOL shouldOverride = circletEnabledForClassname(@"UIStatusBarBatteryItemView");
	CRLOG(@"%@", shouldOverride ? @"override" : @"ignore");

	NSNumber *showBolt = [sharedPreferencesManager() numberForKey:@"showBolt"];

	if (shouldOverride && (!showBolt || ![showBolt boolValue])) {
		return circletBlankImage();
	}

	return %orig();
}

%new - (UIImage *)circletContentsImageForWhite:(BOOL)white {
	int level = MSHookIvar<int>(self, "_capacity");
	int state = MSHookIvar<int>(self, "_state");
	// not supported on iOS 6: BOOL needsBolt = [self _needsAccessoryImage];
	CGFloat radius = circletRadiusFromPosition(CircletPositionBattery);
	CircletStyle style = circletStyleFromPosition(CircletPositionBattery);
	CGFloat lessenedThickness = radius * LESSENED_THICKNESS(style);

	CGFloat percentage = level / 100.0;
	if (lessenedThickness > 0.0) {
		percentage *= 100;
	}

	UIImage *image;
	UIColor *imageColor;
	if (state != 0) {
		imageColor = circletColorForPosition(white, CircletPositionCharging);
	}

	else if (level <= 20) {
		imageColor = circletColorForPosition(white, CircletPositionLowBattery);
	}

	else {
		imageColor = circletColorForPosition(white, CircletPositionBattery);
	}

	NSNumber *outline = [sharedPreferencesManager() numberForKey:@"batteryOutline"];
	BOOL showOutline = !outline || [outline boolValue];

	if (showOutline) {
		if (lessenedThickness > 0.0) {
			image = [UIImage circletWithColor:imageColor radius:radius percentage:percentage style:style thickness:lessenedThickness];
		}

		else {
			image = [UIImage circletWithColor:imageColor radius:radius percentage:percentage style:style];
		}
	}

	else {
		image = [UIImage circletWithColor:imageColor radius:radius percentage:percentage style:style thickness:0.0];
	}

	NSNumber *showBolt = [sharedPreferencesManager() numberForKey:@"showBolt"];

	if (showBolt && [showBolt boolValue] && state != 0) {
		CGRect expanded = (CGRect){CGPointZero, image.size};
		expanded.size.width += CRBOLTLEEWAY;

		UIGraphicsBeginImageContextWithOptions(expanded.size, NO, [UIScreen mainScreen].scale);
		[image drawAtPoint:CGPointZero];
		UIImage *doubledImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();

		return doubledImage;
	}

	return image;
}

- (_UILegibilityImageSet *)contentsImage {
	BOOL shouldOverride = circletEnabledForClassname(@"UIStatusBarBatteryItemView");
	CRLOG(@"%@", shouldOverride ? @"override" : @"ignore");

	if (shouldOverride) {
		CGFloat w, a;
		[[[self foregroundStyle] textColorForStyle:[self legibilityStyle]] getWhite:&w alpha:&a];
		
		UIImage *image = [self circletContentsImageForWhite:(w >= 0.5)];
		return [%c(_UILegibilityImageSet) imageFromImage:image withShadowImage:image];
	}

	return %orig();
}

- (UIImage *)contentsImageForStyle:(int)arg1 {
	BOOL shouldOverride = circletEnabledForClassname(@"UIStatusBarBatteryItemView");
	CRLOG(@"%@", shouldOverride ? @"override" : @"ignore");
	return shouldOverride ? [self circletContentsImageForWhite:YES] : %orig();
}

%end

/***************************************************************************************/
/********************************* Foreground Layout  **********************************/
/***************************************************************************************/

%hook UIStatusBarLayoutManager

- (CGRect)_frameForItemView:(id)arg1 startPosition:(float)arg2 {
	CGRect frame = %orig(arg1, arg2);
	NSString *className = NSStringFromClass([arg1 class]);

	if (circletEnabledForClassname(className)) {
		if ([className isEqualToString:@"UIStatusBarSignalStrengthItemView"]) {
			frame = CGRectMake(frame.origin.x, frame.origin.y, circletWidthFromPosition(CircletPositionSignal), frame.size.height);
		}

		else if ([className isEqualToString:@"UIStatusBarServiceItemView"]) {
			NSString *savedText = [sharedPreferencesManager() stringForKey:@"carrierText"];
			NSString *clipped = [savedText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

			if (savedText && clipped.length == 0 && savedText.length > 0) {
				frame = CGRectMake(frame.origin.x, frame.origin.y, 0.0, 0.0);
			}

			else {
				CGFloat diameter = CRDEFAULTRADIUS * 2.0;
				frame = CGRectMake(frame.origin.x, frame.origin.y, diameter + (diameter / 10.0), frame.size.height);
			}
		}

		else if ([className isEqualToString:@"UIStatusBarDataNetworkItemView"]) {
			if (WIFI_CONNECTED) {
				frame = CGRectMake(frame.origin.x, frame.origin.y, circletWidthFromPosition(CircletPositionWifi), frame.size.height);
			}

			else {
				frame = CGRectMake(frame.origin.x, frame.origin.y, circletWidthFromPosition(CircletPositionData), frame.size.height);
			}
		}

		else if ([className isEqualToString:@"UIStatusBarTimeItemView"]) {
			frame = CGRectMake(frame.origin.x, frame.origin.y, circletWidthFromPosition(CircletPositionTimeMinute), frame.size.height);
		}

		else if ([className isEqualToString:@"UIStatusBarBatteryItemView"]) {
			NSNumber *showBolt = [sharedPreferencesManager() numberForKey:@"showBolt"];

			// Should only have that preference set if on iOS 7 (not in other plist)...
			if (showBolt && [showBolt boolValue] && MSHookIvar<int>(arg1, "_state") != 0) {
				frame = CGRectMake(frame.origin.x, frame.origin.y, circletWidthFromPosition(CircletPositionBattery) + CRBOLTLEEWAY, frame.size.height);
			}

			else {
				frame = CGRectMake(frame.origin.x, frame.origin.y, circletWidthFromPosition(CircletPositionBattery), frame.size.height);
			}
		}
	}

	CRLOG(@"%@ for %@", NSStringFromCGRect(frame), className);
	return frame;
}

%end

%end // %group Shared

/**************************************************************************************/
/************************ CRAVDelegate (used from first run) ****************************/
/***************************************************************************************/

@interface CRAlertViewDelegate : NSObject <UIAlertViewDelegate>
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
@end

@implementation CRAlertViewDelegate

- (id)init {
	self = [super init];

	if (self) {
		[self retain]; // This class manages the memory management itself
	}

	return self;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == [alertView cancelButtonIndex]) {
		return;
	}

	else {
		if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/PreferenceOrganizer.dylib"]) {
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Cydia&path=Circlet"]];
		}

		else {
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Circlet"]];
		}
	}

	// Die already
	[self release];
}

@end

/***************************************************************************************/
/********************************* First Run Prompts  **********************************/
/***************************************************************************************/

%group Modern

static CRAlertViewDelegate *circletAVDelegate;
static BOOL kCRUnlocked;

%hook SBUIController

- (void)_deviceLockStateChanged:(NSNotification *)changed {
	%orig();

	NSNumber *state = changed.userInfo[@"kSBNotificationKeyState"];
	if (!state.boolValue) {
		kCRUnlocked = YES;
	}
}

%end

%hook SBUIAnimationController

- (void)endAnimation {
	%orig();

	if (kCRUnlocked && ![sharedPreferencesManager() objectForKey:@"didRun"]) {
		CRLOG(@"Detected novel (modern) run...");
		[sharedPreferencesManager() setObject:@(YES) forKey:@"didRun"];

		circletAVDelegate = [[CRAlertViewDelegate alloc] init];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Circlet" message:@"Welcome to Circlet. Set up your first circles by tapping Begin, or configure them later in Settings. Thanks for the dollar, I promise not to disappoint." delegate:circletAVDelegate cancelButtonTitle:@"Later" otherButtonTitles:@"Begin", nil];
		[alert show];
		[alert release];
		[circletAVDelegate release];
	}
}

%end

%end // %group Modern

%group Ancient

%hook SBUIController

- (void)finishedUnscattering{
	%orig();

	if (kCRUnlocked && ![sharedPreferencesManager() objectForKey:@"didRun"]) {
		CRLOG(@"Detected novel (ancient) run...");
		[sharedPreferencesManager() setObject:@(YES) forKey:@"didRun"];

		circletAVDelegate = [[CRAlertViewDelegate alloc] init];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Circlet" message:@"Welcome to Circlet. Set up your first circles by tapping Begin, or configure them later in Settings. Thanks for the dollar, I promise not to disappoint." delegate:circletAVDelegate cancelButtonTitle:@"Later" otherButtonTitles:@"Begin", nil];
		[alert show];
		[alert release];
		[circletAVDelegate release];
	}
}

%end

%end // %group Ancient

/***************************************************************************************/
/****************************** Pulling it all togctor   *******************************/
/***************************************************************************************/

%ctor {
	%init(Shared);
	if (MODERN_IOS) {
		%init(Modern);
	}

	else {
		%init(Ancient);
	}

	[[NSDistributedNotificationCenter defaultCenter] addObserverForName:@"CRRefreshStatusBar" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification){
		CRLOG(@"Fixing up statusBar now...");

		UIStatusBar *statusBar = (UIStatusBar *)[[UIApplication sharedApplication] statusBar];
		[statusBar setShowsOnlyCenterItems:YES];
		[statusBar setShowsOnlyCenterItems:NO];
	}];

	[[NSDistributedNotificationCenter defaultCenter] addObserverForName:@"CRRefreshTime" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification){
		CGFloat animationDuration = 0.6;

		UIStatusBar *statusBar = (UIStatusBar *)[[UIApplication sharedApplication] statusBar];
		[statusBar crossfadeTime:NO duration:animationDuration];
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, animationDuration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
			[statusBar crossfadeTime:YES duration:animationDuration];
		});
	}];

	[[NSDistributedNotificationCenter defaultCenter] addObserverForName:@"CLGTFO" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification){
		NSString *sender = notification.userInfo[@"sender"];

		if ([sender isEqualToString:@"SpringBoard"]) {
			CRLOG(@"GTFO! %@", sender);
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=General"]];
		}
	}];

}
