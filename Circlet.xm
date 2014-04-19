//
//  Circlet.xm
//  Circlet
//
//  Created by Julian Weiss on 1/5/14.
//  Copyright (c) 2014 insanj. All rights reserved.
//

#import "CRHeaders.h"

#define DEGREES_TO_RADIANS(degrees) ((M_PI * degrees)/180.0f)
#define CRSettings [NSDictionary dictionaryWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.insanj.circlet.plist"]]

static void CRLog(NSString *string) {
	NSDictionary *settings = CRSettings;
	if (settings[@"debugEnabled"] != nil && [settings[@"debugEnabled"] boolValue])
		NSLog(@"[Circlet] \e[1;31m%@\e[m ", string);
}

/**************************** StatusBar Image Replacment ****************************/

static UIImage * ALCRGetCircleForSignalStrength(CGFloat number, CGFloat max, CGFloat radius, UIColor *color) {
	CRLog([NSString stringWithFormat:@"Generating circle with strength %f for max %f (fill amount: %f), radius %f, and color %@.", number, max, number/max, radius, color]);
	CGRect circle = CGRectMake(10.0 - radius, 10.0 - radius, radius * 2.0, radius * 2.0);

	UIGraphicsBeginImageContextWithOptions(CGSizeMake(20.0, 20.0), NO, 2.0);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
	CGContextSetShouldAntialias(context, YES);
	CGContextSetFillColorWithColor(context, color.CGColor);
	CGContextSetStrokeColorWithColor(context, color.CGColor);
	CGContextStrokeEllipseInRect(context, circle);

	if (number == max)
		CGContextFillEllipseInRect(context, circle);
	else
		CGContextAddArc(context, CGRectGetMidX(circle), CGRectGetMidY(circle), radius, DEGREES_TO_RADIANS(270.0 - (180.0 * number / max)), DEGREES_TO_RADIANS(270.0 + (180.0 * number / max)), 1);

    CGContextDrawPath(context, kCGPathFill);
	UIImage *ret = UIGraphicsGetImageFromCurrentImageContext();
	CGContextRelease(context);
	return ret;
}

static void ALCRReleaseCircle(UIImage *circle) {
	return;
}

/**************************** Preferences Usage ****************************/

static CGFloat CRGetRadiusFromCircleNumber(int circle) {
	NSDictionary *settings = CRSettings;
	NSString *key;
	switch(circle){
		case 0:
			key = @"signalSize";
			break;
		case 1:
			key = @"wifiSize";
			break;
		case 2:
			key = @"batterySize";
			break;
	}


	return (settings[key] == nil) ? 5.0 : [settings[key] floatValue];
}

static UIColor * CRGetColorFromCaseNumber(BOOL white, int number) {
	int caseNumber = (white && number == 0) ? 17 : (!white && number == 0) ? 2 : number;

	switch(caseNumber){
		case 1:
			return UIColorFromRGB(0x7FDBFF);
		case 2:
			return UIColorFromRGB(0x111111);	//default black
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
		case 17:								//default white
			return UIColorFromRGB(0xFFFFFF);
		case 18:
			return UIColorFromRGB(0xFFDC00);
	}

	return white ? [UIColor whiteColor] : [UIColor blackColor];
}

static UIColor * CRGetColorFromCircleNumber(BOOL white, int circle){
	NSString *key;
	if (white) {
		switch (circle) {
			case 0:
				key = @"signalLightColor";
				break;
			case 1:
				key = @"wifiLightColor";
				break;
			case 2:
				key = @"dataLightColor";
				break;
			case 3:
				key = @"batteryLightColor";
				break;
			case 4:
				key = @"chargingLightColor";
				break;
		}
	}

	else {
		switch (circle) {
			case 0:
				key = @"signalDarkColor";
				break;
			case 1:
				key = @"wifiDarkColor";
				break;
			case 2:
				key = @"dataDarkColor";
				break;
			case 3:
				key = @"batteryDarkColor";
				break;
			case 4:
				key = @"chargingDarkColor";
				break;
		}
	}

	return CRGetColorFromCaseNumber(white, [CRSettings[@"wifiLightColor"] intValue]);
}

static BOOL CREnabledForClassname(NSString *className) {
	NSDictionary *settings = CRSettings;
	BOOL signalEnabled = settings[@"signalEnabled"] == nil || [settings[@"signalEnabled"] boolValue];
	BOOL wifiEnabled = settings[@"wifiEnabled"] != nil && [settings[@"wifiEnabled"] boolValue];
	BOOL batteryEnabled = settings[@"batteryEnabled"] != nil && [settings[@"batteryEnabled"] boolValue];

	return (CRSettings != nil) && (([className isEqualToString:@"UIStatusBarSignalStrengthItemView"] && signalEnabled) || ([className isEqualToString:@"UIStatusBarDataNetworkItemView"] && wifiEnabled) || ([className isEqualToString:@"UIStatusBarBatteryItemView"] && batteryEnabled));
}

/**************************** CRAVDelegate (used from LS) ****************************/

@interface CRAlertViewDelegate : NSObject <UIAlertViewDelegate>
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
@end

@implementation CRAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex != [alertView cancelButtonIndex]) {
		if ([alertView.title isEqualToString:@"Warning"]) {
			[(SpringBoard *)[%c(SpringBoard) sharedApplication] _relaunchSpringBoardNow];
		}

		else {
			if([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/PreferenceOrganizer.dylib"] || [[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/PreferenceOrganizer2.dylib"]) {
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Cydia&path=Circlet"];
			}

			else {
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Circlet"];
			}
		}
	}
}
@end

/**************************** Shared, SB and LS Hooks ****************************/

%group Shared

%hook UIStatusBarSignalStrengthItemView

- (_UILegibilityImageSet *)contentsImage {

	BOOL shouldOverride = CREnabledForClassname(@"UIStatusBarSignalStrengthItemView");
	CRLog([NSString stringWithFormat:@"Heard call to signalStrength -contentsImage, looks like we %@ override.",shouldOverride?@"should":@"shouldn't"]);

	if (shouldOverride) {
		CGFloat w, a;
		[[[self foregroundStyle] textColorForStyle:[self legibilityStyle]] getWhite:&w alpha:&a];

		int bars = MSHookIvar<int>(self, "_signalStrengthBars");
		CGFloat radius = CRGetRadiusFromCircleNumber(0);

		UIImage *white = ALCRGetCircleForSignalStrength(bars, 5, radius, CRGetColorFromCircleNumber(YES, 0));
		UIImage *black = ALCRGetCircleForSignalStrength(bars, 5, radius, CRGetColorFromCircleNumber(NO, 0));

		ALCRReleaseCircle(white);
		ALCRReleaseCircle(black);
		return (w >= 0.5)?[%c(_UILegibilityImageSet) imageFromImage:white withShadowImage:black]:[%c(_UILegibilityImageSet) imageFromImage:black withShadowImage:white];
	}

	return %orig();
}

%end

%hook UIStatusBarDataNetworkItemView

- (_UILegibilityImageSet *)contentsImage {

	BOOL shouldOverride = CREnabledForClassname(@"UIStatusBarDataNetworkItemView");
	CRLog([NSString stringWithFormat:@"Heard call to dataNetwork -contentsImage, looks like we %@ override.",shouldOverride?@"should":@"shouldn't"]);

	if (shouldOverride) {
		CGFloat w, a;
		[[[self foregroundStyle] textColorForStyle:[self legibilityStyle]] getWhite:&w alpha:&a];

		int networkType = MSHookIvar<int>(self, "_dataNetworkType");
		int wifiState = MSHookIvar<int>(self, "_wifiStrengthBars");
		CGFloat radius = CRGetRadiusFromCircleNumber(1);

		UIImage *white, *black;
		if (networkType == 5) {
			white = ALCRGetCircleForSignalStrength(wifiState, 3, radius, CRGetColorFromCircleNumber(YES, 1));
			black = ALCRGetCircleForSignalStrength(wifiState, 3, radius, CRGetColorFromCircleNumber(NO, 1));
		}

		else {
			white = ALCRGetCircleForSignalStrength(3, 3, radius, CRGetColorFromCircleNumber(YES, 2));
			black = ALCRGetCircleForSignalStrength(3, 3, radius, CRGetColorFromCircleNumber(NO, 2));
		}

		_UILegibilityImageSet *ret = (w > 0.5)?[%c(_UILegibilityImageSet) imageFromImage:white withShadowImage:black]:[%c(_UILegibilityImageSet) imageFromImage:black withShadowImage:white];

		ALCRReleaseCircle(white);
		ALCRReleaseCircle(black);
		return ret;
	}

	return %orig();
}

%end

%hook UIStatusBarBatteryItemView

- (_UILegibilityImageSet *)contentsImage {

	BOOL shouldOverride = CREnabledForClassname(@"UIStatusBarBatteryItemView");
	CRLog([NSString stringWithFormat:@"Heard call to batteryItem -contentsImage, looks like we %@ override.",shouldOverride?@"should":@"shouldn't"]);

	if (shouldOverride) {
		CGFloat w, a;
		[[[self foregroundStyle] textColorForStyle:[self legibilityStyle]] getWhite:&w alpha:&a];

		int level = MSHookIvar<int>(self, "_capacity");
		int state = MSHookIvar<int>(self, "_state");
		CGFloat radius = CRGetRadiusFromCircleNumber(2);

		UIImage *white, *black;
		if (state != 0) {
			white = ALCRGetCircleForSignalStrength(level, 100, radius, CRGetColorFromCircleNumber(YES, 4));
			black = ALCRGetCircleForSignalStrength(level, 100, radius, CRGetColorFromCircleNumber(NO, 4));
		}

		else {
			white = ALCRGetCircleForSignalStrength(level, 100, radius, CRGetColorFromCircleNumber(YES, 3));
			black = ALCRGetCircleForSignalStrength(level, 100, radius, CRGetColorFromCircleNumber(NO, 3));
		}

		_UILegibilityImageSet *ret = (w > 0.5)?[%c(_UILegibilityImageSet) imageFromImage:white withShadowImage:black]:[%c(_UILegibilityImageSet) imageFromImage:black withShadowImage:white];

		ALCRReleaseCircle(white);
		ALCRReleaseCircle(black);
		return ret;
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
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Circlet" message:@"Welcome to Circlet. Set up your first circles by tapping Begin, or configure them later in Settings. Thanks for two dollars, I promise not to disappoint." delegate:circletAVDelegate cancelButtonTitle:@"Later" otherButtonTitles:@"Begin", nil];
		[alert show];
		[alert release];
	}
}

%end

%hook UIStatusBarLayoutManager

- (CGRect)_frameForItemView:(UIStatusBarItemView *)arg1 startPosition:(float)arg2 {
	CGRect orig = %orig(arg1, arg2);

	if ([arg1 isKindOfClass:%c(UIStatusBarSignalStrengthItemView)] && CREnabledForClassname(@"UIStatusBarSignalStrengthItemView"))
			return CGRectMake(orig.origin.x, orig.origin.y, CRGetRadiusFromCircleNumber(0) * 2.0, orig.size.height);

	else if ([arg1 isKindOfClass:%c(UIStatusBarDataNetworkItemView)] && CREnabledForClassname(@"UIStatusBarDataNetworkItemView"))
		return CGRectMake(orig.origin.x + 1.0, orig.origin.y, CRGetRadiusFromCircleNumber(1) * 2.0, orig.size.height);

	else if ([arg1 isKindOfClass:%c(UIStatusBarBatteryItemView)] && CREnabledForClassname(@"UIStatusBarBatteryItemView")) {
		int state = MSHookIvar<int>(arg1, "_state");
		if(state != 0)
			[[[arg1 subviews] lastObject] setHidden:YES];

		return CGRectMake(orig.origin.x, orig.origin.y, CRGetRadiusFromCircleNumber(2) * 2.0, orig.size.height);
	}

	return orig;
}

%end

%end // %group SpringBoard

%group NotSpringBoard

%hook UIStatusBarLayoutManager
CGFloat cg_dataPoint;

- (CGRect)_frameForItemView:(UIStatusBarItemView *)arg1 startPosition:(float)arg2 {
	CGRect orig = %orig(arg1, arg2);

	if ([arg1 isKindOfClass:%c(UIStatusBarSignalStrengthItemView)]) {
		if (CREnabledForClassname(@"UIStatusBarSignalStrengthItemView")) {
			CGFloat radius = CRGetRadiusFromCircleNumber(0);
			cg_dataPoint = orig.origin.x + (radius * 2.0);
			return CGRectMake(orig.origin.x - 4.0, orig.origin.y, radius * 2.0, orig.size.height);
		}

		cg_dataPoint = orig.origin.x + orig.size.width;
	}

	else if ([arg1 isKindOfClass:%c(UIStatusBarServiceItemView)])
		cg_dataPoint += orig.size.width;

	else if ([arg1 isKindOfClass:%c(UIStatusBarDataNetworkItemView)] && CREnabledForClassname(@"UIStatusBarDataNetworkItemView")) {
		CGFloat radius = CRGetRadiusFromCircleNumber(1);
		return CGRectMake(cg_dataPoint, orig.origin.y, radius * 2.0, orig.size.height);
	}

	else if ([arg1 isKindOfClass:%c(UIStatusBarBatteryItemView)] && CREnabledForClassname(@"UIStatusBarBatteryItemView")) {
		int state = MSHookIvar<int>(arg1, "_state");
		if(state != 0)
			[[[arg1 subviews] lastObject] setHidden:YES];

		CGFloat radius = CRGetRadiusFromCircleNumber(2);
		return CGRectMake(orig.origin.x + 3.0, orig.origin.y, radius * 2.0, orig.size.height);
	}

	return orig;
}

%end

%end

%ctor {
	%init(Shared);

	if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"]) {
		%init(SpringBoard);

		[[NSDistributedNotificationCenter defaultCenter] addObserverForName:@"CRPromptRespring" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification){
			CRLog(@"Popping alertView to check for respring confirmation now...");
			circletAVDelegate = [[CRAlertViewDelegate alloc] init];

			UIAlertView *respringPrompt = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Applying Circlet's settings will respring your device, are you sure you want to do so now?" delegate:circletAVDelegate cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
			[respringPrompt show];
			[respringPrompt release];
		}];
	}

	else {
		%init(NotSpringBoard);
	}
}
