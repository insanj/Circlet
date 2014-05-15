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

// All iOS 7 and iOS 6 hooks
%group Shared

/***************************************************************************************/
/***************************** UIStatusBarItemView Hooks  ******************************/
/***************************************************************************************/

%hook UIStatusBarSignalStrengthItemView

- (_UILegibilityImageSet *)contentsImage {
	BOOL shouldOverride = circletEnabledForClassname(@"UIStatusBarSignalStrengthItemView");
	CRLOG(@"%@", shouldOverride ? @"override" : @"ignore");

	if (shouldOverride) {
		CGFloat w, a;
		[[[self foregroundStyle] textColorForStyle:[self legibilityStyle]] getWhite:&w alpha:&a];

		int bars = MSHookIvar<int>(self, "_signalStrengthBars");
		CGFloat radius = circletRadiusFromPosition(CircletPositionSignal);
		CGFloat percentage = bars / 5.0;
		CircletStyle style = circletStyleFromPosition(CircletPositionSignal);
		if (style == CircletStyleTextual || style == CircletStyleTextualInverse) {
			percentage *= 5.0;
		}

		UIImage *white = [UIImage circletWithColor:circletColorForPosition(YES, CircletPositionSignal) radius:radius percentage:percentage style:style];
		UIImage *black = [UIImage circletWithColor:circletColorForPosition(NO, CircletPositionSignal) radius:radius percentage:percentage style:style];

		return (w >= 0.5) ? [%c(_UILegibilityImageSet) imageFromImage:white withShadowImage:black] : [%c(_UILegibilityImageSet) imageFromImage:black withShadowImage:white];
	}

	return %orig();
}

%end

%hook UIStatusBarDataNetworkItemView

- (_UILegibilityImageSet *)contentsImage {
	BOOL shouldOverride = circletEnabledForClassname(@"UIStatusBarDataNetworkItemView");
	CRLOG(@"%@", shouldOverride ? @"override" : @"ignore");

	if (shouldOverride) {
		CGFloat w, a;
		[[[self foregroundStyle] textColorForStyle:[self legibilityStyle]] getWhite:&w alpha:&a];

		int networkType = MSHookIvar<int>(self, "_dataNetworkType");
		int wifiState = MSHookIvar<int>(self, "_wifiStrengthBars");
		CGFloat radius = circletRadiusFromPosition(CircletPositionWifi);
		CircletStyle style = circletStyleFromPosition(CircletPositionWifi);
		CGFloat percentage = wifiState / 3.0;

		CRLOG(@"networkType:%i, wifiState:%i, percentage:%f", networkType, wifiState, percentage);
		UIImage *white, *black;

		if (networkType != 5) {
			CTRadioAccessTechnology *radioTechnology = [[CTRadioAccessTechnology alloc] init];
			NSString *radioType = [radioTechnology.radioAccessTechnology stringByReplacingOccurrencesOfString:@"CTRadioAccessTechnology" withString:@""];
			[radioTechnology release];

			char representativeChar;
			if (style == CircletStyleTextual) {
				representativeChar = 't';
			}

			else if (style == CircletStyleTextualInverse) {
				representativeChar = 'i';
			}

			if ([radioType rangeOfString:@"EDGE"].location != NSNotFound) {
				representativeChar = 'E';
				percentage = 0.5;
			}

			else if ([radioType rangeOfString:@"HSDPA"].location != NSNotFound) {
				representativeChar = 'G';
				percentage = 0.75;
			}

			else if ([radioType rangeOfString:@"LTE"].location != NSNotFound) {
				representativeChar = 'L';
				percentage = 1.0;
			}

			else {
				representativeChar = 'o';
				percentage = 0.25;
			}

			CRLOG(@"data network type: %@, percentage: %f", radioType, percentage);

			if (style == CircletStyleTextual) {
				white = [UIImage circletWithColor:circletColorForPosition(YES, CircletPositionData) radius:radius char:representativeChar invert:NO];
				black = [UIImage circletWithColor:circletColorForPosition(NO, CircletPositionData) radius:radius char:representativeChar invert:NO];
			}

			else if (style == CircletStyleTextualInverse) {
				white = [UIImage circletWithColor:circletColorForPosition(YES, CircletPositionData) radius:radius char:representativeChar invert:YES];
				black = [UIImage circletWithColor:circletColorForPosition(NO, CircletPositionData) radius:radius char:representativeChar invert:YES];
			}

			else {
				white = [UIImage circletWithColor:circletColorForPosition(YES, CircletPositionData) radius:radius percentage:percentage style:style];
				black = [UIImage circletWithColor:circletColorForPosition(NO, CircletPositionData) radius:radius percentage:percentage style:style];
			}
		}

		else {
			if (style == CircletStyleTextual || style == CircletStyleTextualInverse) {
				percentage *= 3;
			}

			white = [UIImage circletWithColor:circletColorForPosition(YES, CircletPositionWifi) radius:radius percentage:percentage style:style];
			black = [UIImage circletWithColor:circletColorForPosition(NO, CircletPositionWifi) radius:radius percentage:percentage style:style];
		}

		return (w > 0.5) ? [%c(_UILegibilityImageSet) imageFromImage:white withShadowImage:black]:[%c(_UILegibilityImageSet) imageFromImage:black withShadowImage:white];
	}

	return %orig();
}

%end

// UIStatusBarServiceItemView

%hook UIStatusBarTimeItemView

- (_UILegibilityImageSet *)contentsImage {
	BOOL shouldOverride = circletEnabledForClassname(@"UIStatusBarTimeItemView");
	CRLOG(@"%@", shouldOverride ? @"override" : @"ignore");

	if (shouldOverride) {
		CGFloat w, a;
		[[[self foregroundStyle] textColorForStyle:[self legibilityStyle]] getWhite:&w alpha:&a];
		
		CGFloat radius = circletRadiusFromPosition(CircletPositionTimeOuter);
		NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];
		CGFloat hour = fmod([components hour], 12.0) / 12.0;
		CGFloat minute = [components minute] / 60.0;
		
		CircletStyle style = circletStyleFromPosition(CircletPositionTimeOuter);
		if (style == CircletStyleTextual || style == CircletStyleTextualInverse) {
			hour *= 12.0;
			minute *= 60.0;
		}

		UIImage *white = [UIImage circletWithInnerColor:circletColorForPosition(YES, CircletPositionTimeInner) outerColor:circletColorForPosition(YES, CircletPositionTimeOuter) radius:radius innerPercentage:hour outerPercentage:minute style:style];
		UIImage *black = [UIImage circletWithInnerColor:circletColorForPosition(NO, CircletPositionTimeInner) outerColor:circletColorForPosition(NO, CircletPositionTimeOuter) radius:radius innerPercentage:hour outerPercentage:minute style:style];

		return (w >= 0.5) ? [%c(_UILegibilityImageSet) imageFromImage:white withShadowImage:black] : [%c(_UILegibilityImageSet) imageFromImage:black withShadowImage:white];
	}

	return %orig();
}

%end

%hook UIStatusBarBatteryItemView

- (id)_accessoryImage {
	CRLOG(@"%@", %orig);
	
	BOOL shouldOverride = circletEnabledForClassname(@"UIStatusBarBatteryItemView");
	NSNumber *showBolt = CRVALUE(@"showBolt");

	if (shouldOverride && (!showBolt || ![showBolt boolValue])) {
		UIImage *image = %orig();
		UIGraphicsBeginImageContextWithOptions(CGSizeMake(1.0, 1.0), NO, image.scale);
		UIImage *tiny = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();

		return tiny;
	}

	return %orig();
}

- (_UILegibilityImageSet *)contentsImage {
	BOOL shouldOverride = circletEnabledForClassname(@"UIStatusBarBatteryItemView");
	CRLOG(@"%@", shouldOverride ? @"override" : @"ignore");

	if (shouldOverride) {
		CGFloat w, a;
		[[[self foregroundStyle] textColorForStyle:[self legibilityStyle]] getWhite:&w alpha:&a];

		int level = MSHookIvar<int>(self, "_capacity");
		BOOL needsBolt = [self _needsAccessoryImage];
		CGFloat radius = circletRadiusFromPosition(CircletPositionBattery);

		CircletStyle style = circletStyleFromPosition(CircletPositionBattery);
		CGFloat percentage = level / 100.0;
		if (style == CircletStyleTextual || style == CircletStyleTextualInverse) {
			percentage *= 100;
		}

		UIImage *white, *black;
		if (needsBolt) {
			white = [UIImage circletWithColor:circletColorForPosition(YES, CircletPositionCharging) radius:radius percentage:percentage style:style];
			black = [UIImage circletWithColor:circletColorForPosition(NO, CircletPositionCharging) radius:radius percentage:percentage style:style];
		}

		else if (percentage <= 0.20) {
			white = [UIImage circletWithColor:circletColorForPosition(YES, CircletPositionLowBattery) radius:radius percentage:percentage style:style];
			black = [UIImage circletWithColor:circletColorForPosition(NO, CircletPositionLowBattery) radius:radius percentage:percentage style:style];
		}

		else {
			white = [UIImage circletWithColor:circletColorForPosition(YES, CircletPositionBattery) radius:radius percentage:percentage style:style];
			black = [UIImage circletWithColor:circletColorForPosition(NO, CircletPositionBattery) radius:radius percentage:percentage style:style];
		}

		return (w > 0.5) ? [%c(_UILegibilityImageSet) imageFromImage:white withShadowImage:black] : [%c(_UILegibilityImageSet) imageFromImage:black withShadowImage:white];
	}

	return %orig();
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

		else if ([className isEqualToString:@"UIStatusBarDataNetworkItemView"]) {
			frame = CGRectMake(frame.origin.x, frame.origin.y, circletWidthFromPosition(CircletPositionWifi), frame.size.height);
		}

		else if ([className isEqualToString:@"UIStatusBarTimeItemView"]) {
			frame = CGRectMake(frame.origin.x, frame.origin.y, circletWidthFromPosition(CircletPositionTimeOuter), frame.size.height);
		}

		else if ([className isEqualToString:@"UIStatusBarBatteryItemView"]) {
			UIImage *boltImage = MODERN_IOS ? (UIImage *) [arg1 _accessoryImage] : nil;
			CGFloat boltWidth = boltImage ? boltImage.size.width : 0.0;
			// ionno deal with this
			frame = CGRectMake(frame.origin.x, frame.origin.y, circletWidthFromPosition(CircletPositionBattery) + boltWidth, frame.size.height);
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
		if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/PreferenceOrganizer.dylib"] || [[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/PreferenceOrganizer2.dylib"]) {
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
		CRLOG(@"Clearing antiquated old settings...");
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
