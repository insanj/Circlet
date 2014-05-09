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
			break;
		case CircletPositionBattery:
		case CircletPositionCharging:
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
	}
	
	else {
		value =  CRVALUE(@"batterySize");
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
			value = CRVALUE(@"batteryStyle");
			invert = CRVALUE(@"batteryInvert");
			break;
	}

	CircletStyle style = value ? [value integerValue] : CircletStyleFill;
	if (invert && [invert boolValue]) {
		style += 3;
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

	if (!value || !valueInDict) {
		return light ? [UIColor whiteColor] : [UIColor colorWithRed:17.0/255.0 green:17.0/255.0 blue:17.0/255.0 alpha:1.0];
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
		CGFloat percentage = wifiState / 3.0;
		CircletStyle style = circletStyleFromPosition(CircletPositionWifi);

		CRLOG(@"networkType:%i, wifiState:%i, percentage:%f", networkType, wifiState, percentage);
		UIImage *white, *black;
		if (networkType != 5) {
			white = [UIImage circletWithColor:circletColorForPosition(YES, CircletPositionData) radius:radius percentage:1.0 style:style];
			black = [UIImage circletWithColor:circletColorForPosition(NO, CircletPositionData) radius:radius percentage:1.0 style:style];
		}

		else {
			white = [UIImage circletWithColor:circletColorForPosition(YES, CircletPositionWifi) radius:radius percentage:percentage style:style];
			black = [UIImage circletWithColor:circletColorForPosition(NO, CircletPositionWifi) radius:radius percentage:percentage style:style];
		}

		return (w > 0.5) ? [%c(_UILegibilityImageSet) imageFromImage:white withShadowImage:black]:[%c(_UILegibilityImageSet) imageFromImage:black withShadowImage:white];
	}

	return %orig();
}

%end

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
	if (shouldOverride) {
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
		CGFloat percentage = level / 100.0;
		CircletStyle style = circletStyleFromPosition(CircletPositionBattery);

		UIImage *white, *black;
		if (needsBolt) {
			white = [UIImage circletWithColor:circletColorForPosition(YES, CircletPositionCharging) radius:radius percentage:percentage style:style];
			black = [UIImage circletWithColor:circletColorForPosition(NO, CircletPositionCharging) radius:radius percentage:percentage style:style];
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

- (CGRect)_frameForItemView:(UIStatusBarItemView *)arg1 startPosition:(float)arg2 {
	CGRect frame = %orig(arg1, arg2);
	CRLOG(@"%@", NSStringFromCGRect(frame));

	if ([arg1 isKindOfClass:%c(UIStatusBarSignalStrengthItemView)] && circletEnabledForClassname(@"UIStatusBarSignalStrengthItemView")) {
		return CGRectMake(frame.origin.x, frame.origin.y, circletWidthFromPosition(CircletPositionSignal), frame.size.height);
	}

	else if ([arg1 isKindOfClass:%c(UIStatusBarDataNetworkItemView)] && circletEnabledForClassname(@"UIStatusBarDataNetworkItemView")) {
		return CGRectMake(frame.origin.x, frame.origin.y, circletWidthFromPosition(CircletPositionWifi), frame.size.height);
	}

	else if ([arg1 isKindOfClass:%c(UIStatusBarTimeItemView)] && circletEnabledForClassname(@"UIStatusBarTimeItemView")) {
		return CGRectMake(frame.origin.x, frame.origin.y, circletWidthFromPosition(CircletPositionTimeOuter), frame.size.height);
	}

	else if ([arg1 isKindOfClass:%c(UIStatusBarBatteryItemView)] && circletEnabledForClassname(@"UIStatusBarBatteryItemView")) {
		return CGRectMake(frame.origin.x, frame.origin.y, circletWidthFromPosition(CircletPositionBattery), frame.size.height);
	}

	return frame;
}

%end


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
		CRLOG(@"Detected novel run, creating new plist...");
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

/***************************************************************************************/
/****************************** Pulling it all togctor   *******************************/
/***************************************************************************************/

%ctor {
	NSDictionary *settings = CRSETTINGS;
	if (!settings || !settings[@"didRun"]) {
		CRLOG(@"Clearing antiquated old settings...");
		[@{} writeToFile:CRPATH atomically:YES];
	}

	[[NSDistributedNotificationCenter defaultCenter] addObserverForName:@"CRRefreshStatusBar" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification){
		CRLOG(@"Fixing up statusBar now...");


		UIStatusBar *statusBar = (UIStatusBar *)[[UIApplication sharedApplication] statusBar];
		[statusBar crossfadeTime:NO duration:0.0];		
		[statusBar setShowsOnlyCenterItems:YES];
		[statusBar setShowsOnlyCenterItems:NO];

		CGFloat animationTime = 0.6;
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, animationTime * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
			[statusBar crossfadeTime:YES duration:animationTime];
		});
	}];
}
