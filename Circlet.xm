//
//  Circlet.xm
//  Circlet
//
//  Created by Julian Weiss on 1/5/14.
//  Copyright (c) 2014 insanj. All rights reserved.
//

#import "CRHeaders.h"
#import "UIImage+Circlet.h"

#define CRSETTINGS [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.insanj.circlet.plist"]
#define CRVALUE(key) [[NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.insanj.circlet.plist"] objectForKey:key]
#define CRDEFAULTRADIUS 5.0

typedef NS_ENUM(NSUInteger, CircletPosition) {
    CircletPositionSignal = 0,
    CircletPositionWifi, // == 1
    CircletPositionData, // == 2
    CircletPositionBattery, // == 3
    CircletPositionCharging, // == 4
};

/**************************** Static C Functions ****************************/


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
		case CircletPositionBattery:
		case CircletPositionCharging:
			value = CRVALUE(@"batterySize");
			break;
	}

	return value ? [value floatValue]: CRDEFAULTRADIUS;
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
		case CircletPositionBattery:
		case CircletPositionCharging:
			value = CRVALUE(@"batteryStyle");
			invert = CRVALUE(@"batteryInvert");
			break;
	}

	CircletStyle style = value ? [value integerValue] : CircletStyleFill;
	if ([invert boolValue]) {
		style += 3;
	}

	return style;
}

// Returns color value based on arbitrary case number (used by following function)
static UIColor * circletColorForCase(BOOL light, int number) {
	int caseNumber = (light && number == 0) ? 17 : (!light && number == 0) ? 2 : number;

	switch (caseNumber) {
		case 1:
			return UIColorFromRGB(0x7FDBFF);
		case 2:
			return UIColorFromRGB(0x111111);	// default black
		case 3:
			return UIColorFromRGB(0x0074D9);
		case 4:
			return [UIColor clearColor];
		case 5:
			return UIColorFromRGB(0xF012BE);
		case 6:
			return UIColorFromRGB(0xAAAAAA);
		case 7:
			return UIColorFromRGB(0x2ECC40);
		case 8:
			return UIColorFromRGB(0x01FF70);
		case 9:
			return UIColorFromRGB(0x85144B);
		case 10:
			return UIColorFromRGB(0x001F3F);
		case 11:
			return UIColorFromRGB(0x3D9970);
		case 12:
			return UIColorFromRGB(0xFF851B);
		case 13:
			return UIColorFromRGB(0xB10DC9);
		case 14:
			return UIColorFromRGB(0xFF4136);
		case 15:
			return UIColorFromRGB(0xDDDDDD);
		case 16:
			return UIColorFromRGB(0x39CCCC);
		case 17:								// default white
			return UIColorFromRGB(0xFFFFFF);
		case 18:
			return UIColorFromRGB(0xFFDC00);
	}

	return light ? [UIColor whiteColor] : [UIColor blackColor];
}

// Retrieves saved color value based on position given
static UIColor * circletColorForPosition(BOOL light, CircletPosition posit){
	NSNumber *value;
	if (light) {
		switch (posit) {
			default:
			case CircletPositionSignal:
				value = CRVALUE(@"signalLightColor");
				break;
			case CircletPositionWifi:
				value = CRVALUE(@"wifiLightColor");
				break;
			case CircletPositionData:
				value = CRVALUE(@"dataLightColor");
				break;
			case CircletPositionBattery:
				value = CRVALUE(@"batteryLightColor");
				break;
			case CircletPositionCharging:
				value = CRVALUE(@"chargingLightColor");
				break;
		}
	}

	else {
		switch (posit) {
			case CircletPositionSignal:
				value = CRVALUE(@"signalDarkColor");
				break;
			case CircletPositionWifi:
				value = CRVALUE(@"wifiDarkColor");
				break;
			case CircletPositionData:
				value = CRVALUE(@"dataDarkColor");
				break;
			case CircletPositionBattery:
				value = CRVALUE(@"batteryDarkColor");
				break;
			case CircletPositionCharging:
				value = CRVALUE(@"chargingDarkColor");
				break;
		}
	}

	return circletColorForCase(light, [value intValue]);
}

// Returns whether or not the class is enabled in settings
static BOOL circletEnabledForClassname(NSString *className) {
	NSDictionary *settings = CRSETTINGS;
	if (!settings) {
		return NO;
	}

	else if ([className isEqualToString:@"UIStatusBarSignalStrengthItemView"]) {
		NSNumber *value = CRVALUE(@"signalEnabled");
		return !value || [value boolValue];	// because of negation property
	}

	else if ([className isEqualToString:@"UIStatusBarDataNetworkItemView"]) {
		return [CRVALUE(@"wifiEnabled") boolValue];
	}

	else if ([className isEqualToString:@"UIStatusBarBatteryItemView"]) {
		return [CRVALUE(@"batteryEnabled") boolValue];
	}

	return NO;
}

/**************************** CRAVDelegate (used from LS) ****************************/

@interface CRAlertViewDelegate : NSObject <UIAlertViewDelegate>
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
@end

@implementation CRAlertViewDelegate


- (id)init {
	if (self = [super init]){
		//This class manages the memory management itself
		[self retain];
	}
	return self;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == [alertView cancelButtonIndex]) {
		return;
	}

	else if ([alertView.title isEqualToString:@"Warning"]) {
		[(SpringBoard *)[%c(SpringBoard) sharedApplication] _relaunchSpringBoardNow];
	}

	else {
		if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/PreferenceOrganizer.dylib"] || [[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/PreferenceOrganizer2.dylib"]) {
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Cydia&path=Circlet"]];
		}

		else {
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Circlet"]];
		}
	}
	//Die already
	[self release];
}

@end

/**************************** Shared, SB and LS Hooks ****************************/

%group Shared

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

		UIImage *white, *black;
		if (networkType == 5) {
			white = [UIImage circletWithColor:circletColorForPosition(YES, CircletPositionData) radius:radius percentage:percentage style:style];
			black = [UIImage circletWithColor:circletColorForPosition(NO, CircletPositionData) radius:radius percentage:percentage style:style];
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

%hook UIStatusBarBatteryItemView

- (_UILegibilityImageSet *)contentsImage {
	BOOL shouldOverride = circletEnabledForClassname(@"UIStatusBarBatteryItemView");
	CRLOG(@"%@", shouldOverride ? @"override" : @"ignore");

	if (shouldOverride) {
		CGFloat w, a;
		[[[self foregroundStyle] textColorForStyle:[self legibilityStyle]] getWhite:&w alpha:&a];

		int level = MSHookIvar<int>(self, "_capacity");
		int state = MSHookIvar<int>(self, "_state");
		CGFloat radius = circletRadiusFromPosition(CircletPositionBattery);
		CGFloat percentage = level / 100.0;
		CircletStyle style = circletStyleFromPosition(CircletPositionBattery);

		UIImage *white, *black;
		if (state != 0) {
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

%end // %group NotSpringBoard

/**************************** Foreground Layout  ****************************/

%group SpringBoard


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

	if (kCRUnlocked && ![[NSUserDefaults standardUserDefaults] boolForKey:@"CRDidRun"]) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"CRDidRun"];

		circletAVDelegate = [[CRAlertViewDelegate alloc] init];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Circlet" message:@"Welcome to Circlet. Set up your first circles by tapping Begin, or configure them later in Settings. Thanks for dollar, I promise not to disappoint." delegate:circletAVDelegate cancelButtonTitle:@"Later" otherButtonTitles:@"Begin", nil];
		[alert show];
		[alert release];
		[circletAVDelegate release];
	}
}

%end

// TODO: Fix stupid issue where everything is shifted to right (probably my fault)
// and just intelligently frame based on (maybe) original / 5.0 (or similar).
%hook UIStatusBarLayoutManager

- (CGRect)_frameForItemView:(UIStatusBarItemView *)arg1 startPosition:(float)arg2 {
	CGRect frame = %orig(arg1, arg2);
	CRLOG(@"%@", NSStringFromCGRect(frame));

	if ([arg1 isKindOfClass:%c(UIStatusBarSignalStrengthItemView)] && circletEnabledForClassname(@"UIStatusBarSignalStrengthItemView")) {
		return CGRectMake(frame.origin.x, frame.origin.y, circletRadiusFromPosition(CircletPositionSignal) * 2.0, frame.size.height);
	}

	else if ([arg1 isKindOfClass:%c(UIStatusBarDataNetworkItemView)] && circletEnabledForClassname(@"UIStatusBarDataNetworkItemView")) {
		return CGRectMake(frame.origin.x + 1.0, frame.origin.y, circletRadiusFromPosition(CircletPositionWifi) * 2.0, frame.size.height);
	}

	else if ([arg1 isKindOfClass:%c(UIStatusBarBatteryItemView)] && circletEnabledForClassname(@"UIStatusBarBatteryItemView")) {
		int state = MSHookIvar<int>(arg1, "_state");
		if (state != 0) {
			[[[arg1 subviews] lastObject] setHidden:YES];
		}

		return CGRectMake(frame.origin.x, frame.origin.y, circletRadiusFromPosition(CircletPositionBattery) * 2.0, frame.size.height);
	}

	return frame;
}

%end

%end // %group SpringBoard

%group NotSpringBoard

%hook UIStatusBarLayoutManager
static CGFloat cg_dataPoint;

- (CGRect)_frameForItemView:(UIStatusBarItemView *)arg1 startPosition:(float)arg2 {
	CGRect frame = %orig(arg1, arg2);
	CRLOG(@"%@", NSStringFromCGRect(frame));

	if ([arg1 isKindOfClass:%c(UIStatusBarSignalStrengthItemView)]) {
		if (circletEnabledForClassname(@"UIStatusBarSignalStrengthItemView")) {
			CGFloat radius = circletRadiusFromPosition(CircletPositionSignal);
			cg_dataPoint = frame.origin.x + (radius * 2.0);
			return CGRectMake(frame.origin.x - 4.0, frame.origin.y, radius * 2.0, frame.size.height);
		}

		cg_dataPoint = frame.origin.x + frame.size.width;
	}

	else if ([arg1 isKindOfClass:%c(UIStatusBarServiceItemView)]) {
		cg_dataPoint += frame.size.width;
	}

	else if ([arg1 isKindOfClass:%c(UIStatusBarDataNetworkItemView)] && circletEnabledForClassname(@"UIStatusBarDataNetworkItemView")) {
		CGFloat radius = circletRadiusFromPosition(CircletPositionWifi);
		return CGRectMake(cg_dataPoint, frame.origin.y, radius * 2.0, frame.size.height);
	}

	else if ([arg1 isKindOfClass:%c(UIStatusBarBatteryItemView)] && circletEnabledForClassname(@"UIStatusBarBatteryItemView")) {
		int state = MSHookIvar<int>(arg1, "_state");
		if(state != 0) {
			[[[arg1 subviews] lastObject] setHidden:YES];
		}

		CGFloat radius = circletRadiusFromPosition(CircletPositionBattery);
		return CGRectMake(frame.origin.x + 3.0, frame.origin.y, radius * 2.0, frame.size.height);
	}

	return frame;
}

%end

%end // %group Shared

%ctor {
	%init(Shared);

	if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"]) {
		CRLOG(@"Loaded into SpringBoard process, initializing group and adding observer...");
		%init(SpringBoard);

		[[NSDistributedNotificationCenter defaultCenter] addObserverForName:@"CRPromptRespring" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification){
			CRLOG(@"Popping alertView to check for respring confirmation now...");
			circletAVDelegate = [[CRAlertViewDelegate alloc] init];

			UIAlertView *respringPrompt = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Applying Circlet's settings will respring your device, are you sure you would like to do so now?" delegate:circletAVDelegate cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
			[respringPrompt show];
			[respringPrompt release];
			[circletAVDelegate release];
		}];
	}

	else {
		CRLOG(@"Loaded into non-SpringBoard process, initializing group...");
		%init(NotSpringBoard);
	}
}
