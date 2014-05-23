//
//  Circlet.xm
//  Circlet
//
//  Created by Julian Weiss on 1/5/14.
//  Copyright (c) 2014 insanj. All rights reserved.
//

#import "CRHeaders.h"
#import "UIImage+Circlet.h"

typedef NS_ENUM(NSUInteger, CircletPosition) {
    CircletPositionSignal = 0,
    CircletPositionWifi, // == 1
    CircletPositionData, // == 2
    CircletPositionTimeOuter, // == 3
	CircletPositionTimeInner, // == 4
    CircletPositionBattery, // == 5
    CircletPositionCharging, // == 6
    CircletPositionLowBattery, // == 7
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
			value = CRVALUE(@"signalSize");
			break;
		case CircletPositionWifi:
		case CircletPositionData:
			value = CRVALUE(@"wifiSize");
			break;
		case CircletPositionTimeOuter:
		case CircletPositionTimeInner:
			value = CRVALUE(@"timeSize");
			return value ? [value floatValue] * 2.0 : CRDEFAULTRADIUS * 2.0;
		case CircletPositionBattery:
		case CircletPositionCharging:
		case CircletPositionLowBattery:
			value = CRVALUE(@"batterySize");
			break;
	}

	return value ? [value floatValue] : CRDEFAULTRADIUS;
}

static CGFloat circletWidthFromPosition(CircletPosition posit) {
	NSNumber *value;
	if (posit == CircletPositionSignal) {
		NSNumber *value = CRVALUE(@"signalSize");
		CGFloat diameter = value ? [value floatValue] * 2.0 : CRDEFAULTRADIUS * 2.0;
		return diameter + (diameter / 10.0);
	}

	else if (posit == CircletPositionWifi || posit == CircletPositionData) {
		value = CRVALUE(@"wifiSize");
	}

	else if (posit == CircletPositionTimeOuter || posit == CircletPositionTimeInner) {
		value = CRVALUE(@"timeSize");
		CGFloat diameter = [value floatValue] * 2.0;
		return (diameter * 2.0) + (diameter / 10.0);
	}
	
	else {
		value = CRVALUE(@"batterySize");
	}

	CGFloat diameter = [value floatValue] * 2.0;
	return diameter + (diameter / 10.0);
}

static CircletStyle circletStyleFromPosition(CircletPosition posit) {
	NSNumber *value, *invert;
	switch (posit) {
		default:
		case CircletPositionSignal:
			value = CRVALUE(@"signalStyle");
			invert = CRVALUE(@"signalInvert");
			break;
		case CircletPositionWifi:
		case CircletPositionData:
			value = CRVALUE(@"wifiStyle");
			invert = CRVALUE(@"wifiInvert");
			break;
		case CircletPositionTimeOuter:
		case CircletPositionTimeInner:
			value = CRVALUE(@"timeStyle");
			invert = CRVALUE(@"timeInvert");
			break;
		case CircletPositionBattery:
		case CircletPositionCharging:
		case CircletPositionLowBattery:
			value = CRVALUE(@"batteryStyle");
			invert = CRVALUE(@"batteryInvert");
			break;
	}

	CircletStyle style = value ? [value integerValue] : CircletStyleFill;
	if (invert && [invert boolValue]) {
		style += 4;
	}

	return style;
}

// Returns color value based on preferences saved value
static UIColor * circletColorForKey(BOOL light, NSString *key) {
	NSString *value = CRVALUE(key);
	NSDictionary *titleToColor = CRTITLETOCOLOR;
	UIColor *valueInDict = titleToColor[value];

	if (value && !valueInDict) {
		CRLOG(@"CUSTOM COLOR: %@", value);
		NSString *colorString = CRVALUE([key stringByAppendingString:@"Custom"]);
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

// Retrieves saved color value based on position given
static UIColor * circletColorForPosition(BOOL light, CircletPosition posit){
	NSString *key;
	if (light) {
		switch (posit) {
			default:
			case CircletPositionSignal:
				key = @"signalLightColor";
				break;
			case CircletPositionWifi:
				key = @"wifiLightColor";
				break;
			case CircletPositionData:
				key = @"dataLightColor";
				break;
			case CircletPositionTimeOuter:
				key = @"timeOuterLightColor";
				break;
			case CircletPositionTimeInner:
				key = @"timeInnerLightColor";
				break;
			case CircletPositionBattery:
				key = @"batteryLightColor";
				break;
			case CircletPositionCharging:
				key = @"chargingLightColor";
				break;
			case CircletPositionLowBattery:
				key = @"lowBatteryLightColor";
				break;
		}
	}

	else {
		switch (posit) {
			case CircletPositionSignal:
				key = @"signalDarkColor";
				break;
			case CircletPositionWifi:
				key = @"wifiDarkColor";
				break;
			case CircletPositionData:
				key = @"dataDarkColor";
				break;
			case CircletPositionTimeOuter:
				key = @"timeOuterDarkColor";
				break;
			case CircletPositionTimeInner:
				key = @"timeInnerDarkColor";
				break;
			case CircletPositionBattery:
				key = @"batteryDarkColor";
				break;
			case CircletPositionCharging:
				key = @"chargingDarkColor";
				break;
			case CircletPositionLowBattery:
				key = @"lowBatteryDarkColor";
				break;
		}
	}

	return circletColorForKey(light, key);
}

// Returns whether or not the class is enabled in settings
static BOOL circletEnabledForClassname(NSString *className) {
	if ([className isEqualToString:@"UIStatusBarSignalStrengthItemView"]) {
		NSNumber *value = CRVALUE(@"signalEnabled");
		return !value || [value boolValue];	// because of negation property
	}

	else if ([className isEqualToString:@"UIStatusBarServiceItemView"]) {
		return [CRVALUE(@"carrierEnabled") boolValue];
	}

	else if ([className isEqualToString:@"UIStatusBarDataNetworkItemView"]) {
		return [CRVALUE(@"wifiEnabled") boolValue];
	}

	else if ([className isEqualToString:@"UIStatusBarTimeItemView"]) {
		return [CRVALUE(@"timeEnabled") boolValue];
	}

	else if ([className isEqualToString:@"UIStatusBarBatteryItemView"]) {
		return [CRVALUE(@"batteryEnabled") boolValue];
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

	NSNumber *outline = CRVALUE(@"signalOutline");
	BOOL showOutline = !outline || [outline boolValue];

	if (showOutline) {
		return [UIImage circletWithColor:circletColorForPosition(white, CircletPositionSignal) radius:radius percentage:percentage style:style];
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
	int networkType = MSHookIvar<int>(self, "_dataNetworkType");
	int wifiState = MSHookIvar<int>(self, "_wifiStrengthBars");
	CGFloat radius = circletRadiusFromPosition(CircletPositionWifi);
	CircletStyle style = circletStyleFromPosition(CircletPositionWifi);
	CGFloat percentage = wifiState / 3.0;
	
	NSNumber *outline = CRVALUE(@"wifiOutline");
	BOOL showOutline = !outline || [outline boolValue];
	BOOL textualStyle = (style == CircletStyleTextual), inverseTextualStyle = (style == CircletStyleTextualInverse);

	UIImage *image;
	if (networkType != 5) {
		CTRadioAccessTechnology *radioTechnology = [[CTRadioAccessTechnology alloc] init];
		NSString *radioType = [radioTechnology.radioAccessTechnology stringByReplacingOccurrencesOfString:@"CTRadioAccessTechnology" withString:@""];
		[radioTechnology release];

		NSString* representativeString;
		if (style == CircletStyleTextual) {
			representativeString = @"t";
		}

		else if (style == CircletStyleTextualInverse) {
			representativeString = @"i";
		}

		if ([radioType rangeOfString:@"Edge"].location != NSNotFound) {
			representativeString = @"E";
			percentage = 0.5;
		}

		else if ([radioType rangeOfString:@"HSDPA"].location != NSNotFound) {
			representativeString = @"G";
			percentage = 0.75;
		}

		else if ([radioType rangeOfString:@"LTE"].location != NSNotFound) {
			representativeString = @"L";
			percentage = 1.0;
		}

		else {
			representativeString = @"o";
			percentage = 0.25;
		}

		if (textualStyle || inverseTextualStyle) {
			if (showOutline) {
				image = [UIImage circletWithColor:circletColorForPosition(white, CircletPositionData) radius:radius string:representativeString invert:inverseTextualStyle];
			}

			else {
				image = [UIImage circletWithColor:circletColorForPosition(white, CircletPositionData) radius:radius string:representativeString invert:inverseTextualStyle thickness:0.0];
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
		if (textualStyle || inverseTextualStyle) {
			percentage *= 3;
		}

		if (showOutline) {
			image = [UIImage circletWithColor:circletColorForPosition(white, CircletPositionWifi) radius:radius percentage:percentage style:style];
		}

		else {
			image = [UIImage circletWithColor:circletColorForPosition(white, CircletPositionWifi) radius:radius percentage:percentage style:style thickness:0.0];
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

	NSString *savedText = CRVALUE(@"carrierText");
	NSString *clipped = [savedText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

	// If the saved carrier text is a valid, non-empty string
	if (savedText && clipped.length > 0) {
		return [UIImage circletWithColor:light radius:CRDEFAULTRADIUS string:clipped invert:YES];
	}

	// If the saved carrier text is an empty string
	else if (savedText && clipped.length == 0 && savedText.length > 0) {
		return circletBlankImage();
	}

	// If there is no valid saved carrier text
	else {
		NSString *serviceString = MSHookIvar<NSString *>(self, "_serviceString");
		NSString *serviceSingleString = serviceString && serviceString.length > 0 ? [serviceString substringToIndex:1] : @"C";
	 
		return [UIImage circletWithColor:light radius:CRDEFAULTRADIUS string:serviceSingleString invert:YES];
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

%new - (UIImage *)circletContentsImageForWhite:(BOOL)white {
	CGFloat radius = circletRadiusFromPosition(CircletPositionTimeOuter);
	NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];
	CGFloat hour = fmod([components hour], 12.0) / 12.0;
	CGFloat minute = [components minute] / 60.0;
		
	CircletStyle style = circletStyleFromPosition(CircletPositionTimeOuter);
	if (style == CircletStyleTextual || style == CircletStyleTextualInverse) {
		hour *= 12.0;
		minute *= 60.0;
	}

	NSNumber *outline = CRVALUE(@"timeOutline");
	BOOL showOutline = !outline || [outline boolValue];

	if (showOutline) {
		return [UIImage circletWithInnerColor:circletColorForPosition(white, CircletPositionTimeInner) outerColor:circletColorForPosition(white, CircletPositionTimeOuter) radius:radius innerPercentage:hour outerPercentage:minute style:style];
	}

	else {
		return [UIImage circletWithInnerColor:circletColorForPosition(white, CircletPositionTimeInner) outerColor:circletColorForPosition(white, CircletPositionTimeOuter) radius:radius innerPercentage:hour outerPercentage:minute style:style thickness:0.0];
	}
}

- (_UILegibilityImageSet *)contentsImage {
	BOOL shouldOverride = circletEnabledForClassname(@"UIStatusBarTimeItemView");
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
	BOOL shouldOverride = circletEnabledForClassname(@"UIStatusBarTimeItemView");
	CRLOG(@"%@", shouldOverride ? @"override" : @"ignore");
	return shouldOverride ? [self circletContentsImageForWhite:YES] : %orig();
}

%end

%hook UIStatusBarBatteryItemView

- (id)_accessoryImage {	
	BOOL shouldOverride = circletEnabledForClassname(@"UIStatusBarBatteryItemView");
	CRLOG(@"%@", shouldOverride ? @"override" : @"ignore");

	NSNumber *showBolt = CRVALUE(@"showBolt");

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
	CGFloat percentage = level / 100.0;
	if (style == CircletStyleTextual || style == CircletStyleTextualInverse) {
		percentage *= 100;
	}

	UIImage *image;
	UIColor *imageColor;
	if (state != 0) {
		imageColor = circletColorForPosition(white, CircletPositionCharging);
	}

	else if (percentage <= 0.20) {
		imageColor = circletColorForPosition(white, CircletPositionLowBattery);
	}

	else {
		imageColor = circletColorForPosition(white, CircletPositionBattery);
	}

	NSNumber *outline = CRVALUE(@"batteryOutline");
	BOOL showOutline = !outline || [outline boolValue];

	if (showOutline) {
		image = [UIImage circletWithColor:imageColor radius:radius percentage:percentage style:style];
	}

	else {
		image = [UIImage circletWithColor:imageColor radius:radius percentage:percentage style:style thickness:0.0];
	}

	NSNumber *showBolt = CRVALUE(@"showBolt");

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
	BOOL shouldOverride = circletEnabledForClassname(@"UIStatusBarTimeItemView");
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
			NSString *savedText = CRVALUE(@"carrierText");
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
			frame = CGRectMake(frame.origin.x, frame.origin.y, circletWidthFromPosition(CircletPositionWifi), frame.size.height);
		}

		else if ([className isEqualToString:@"UIStatusBarTimeItemView"]) {
			frame = CGRectMake(frame.origin.x, frame.origin.y, circletWidthFromPosition(CircletPositionTimeOuter), frame.size.height);
		}

		else if ([className isEqualToString:@"UIStatusBarBatteryItemView"]) {
			NSNumber *showBolt = CRVALUE(@"showBolt");

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
	if (self = [super init]){
		// This class manages the memory management itself
		[self retain];
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

	NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithDictionary:CRSETTINGS];
	if (kCRUnlocked && !settings[@"didRun"]) {
		CRLOG(@"Detected novel (modern) run, creating new plist...");
		[settings setObject:@(YES) forKey:@"didRun"];
		[settings writeToFile:CRPATH atomically:YES];

		circletAVDelegate = [[CRAlertViewDelegate alloc] init];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Circlet" message:@"Welcome to Circlet. Set up your first circles by tapping Begin, or configure them later in Settings. Thanks for the dollar, I promise not to disappoint." delegate:circletAVDelegate cancelButtonTitle:@"Later" otherButtonTitles:@"Begin", nil];
		[alert show];
		[alert release];
		[circletAVDelegate release];
	}

	[settings release];
}

%end

%end // %group Modern

%group Ancient

%hook SBUIController

- (void)finishedUnscattering{
	%orig();

	NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithDictionary:CRSETTINGS];
	if(!settings[@"didRun"]){
		CRLOG(@"Detected novel (ancient) run, creating new plist...");
		[settings setObject:@(YES) forKey:@"didRun"];
		[settings writeToFile:CRPATH atomically:YES];

		circletAVDelegate = [[CRAlertViewDelegate alloc] init];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Circlet" message:@"Welcome to Circlet. Set up your first circles by tapping Begin, or configure them later in Settings. Thanks for the dollar, I promise not to disappoint." delegate:circletAVDelegate cancelButtonTitle:@"Later" otherButtonTitles:@"Begin", nil];
		[alert show];
		[alert release];
		[circletAVDelegate release];
	}

	[settings release];
}

%end

%end // %group Ancient

/***************************************************************************************/
/****************************** Pulling it all togctor   *******************************/
/***************************************************************************************/

%ctor {
	NSDictionary *settings = CRSETTINGS;
	if (!settings || !settings[@"didRun"]) {
		CRLOG(@"Clearing antiquated settings...");
		[@{} writeToFile:CRPATH atomically:YES];
	}

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
}
