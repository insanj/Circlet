//
//  Circlet.xm
//  Circlet
//
//  Created by Julian Weiss on 1/5/14.
//  Copyright (c) 2014 insanj. All rights reserved.
//

#import "CRHeaders.h"
#import "CRNotificationListener.h"

#define DEGREES_TO_RADIANS(degrees) ((M_PI * degrees)/180.0f)

/**************************** StatusBar Image Replacment ****************************/

static UIImage *ALCRGetCircleForSignalStrength(CGFloat number, CGFloat max, CGFloat radius, UIColor *color){
	NSLog(@"-------- number: %f, max: %f, div: %f", number, max, number/max);
	CGRect circle = CGRectMake(10.0 - radius, 10.0 - radius, radius * 2.0, radius * 2.0);

	UIGraphicsBeginImageContextWithOptions(CGSizeMake(20.0, 20.0), NO, 2.0);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
	CGContextSetShouldAntialias(context, YES);
	CGContextSetFillColorWithColor(context, color.CGColor);
	CGContextSetStrokeColorWithColor(context, color.CGColor);
	CGContextStrokeEllipseInRect(context, circle);
	
	if(number == max)
		CGContextFillEllipseInRect(context, circle);
	else
		CGContextAddArc(context, CGRectGetMidX(circle), CGRectGetMidY(circle), radius, DEGREES_TO_RADIANS(270.0 - (180.0 * number / max)), DEGREES_TO_RADIANS(270.0 + (180.0 * number / max)), 1);

    CGContextDrawPath(context, kCGPathFill);
	UIImage *ret = UIGraphicsGetImageFromCurrentImageContext();
	CGContextRelease(context);
	return ret;
}

static void ALCRReleaseCircle(UIImage *circle){
	return;
}

/**************************** CRAVDelegate (used from LS) ****************************/

@interface CRAlertViewDelegate : NSObject <UIAlertViewDelegate>
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
@end

@implementation CRAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if(buttonIndex)
		[(SpringBoard *)[UIApplication sharedApplication] applicationOpenURL:[NSURL URLWithString:@"prefs:root=Circlet"] publicURLsOnly:NO];
}
@end


%group Shared

/**************************** Shared, SB and LS Hooks ****************************/

%hook SBUIController
static BOOL kCRUnlocked;

-(void)_deviceLockStateChanged:(NSNotification *)changed{
	%orig();

	NSNumber *state = changed.userInfo[@"kSBNotificationKeyState"];
	if(!state.boolValue)
		kCRUnlocked = YES;
}
%end

%hook SBUIAnimationController
CRAlertViewDelegate *circletAVDelegate;

-(void)endAnimation{
	%orig();

	if(kCRUnlocked && ![[NSUserDefaults standardUserDefaults] boolForKey:@"CRDidRun"]){
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"CRDidRun"];
		
		circletAVDelegate = [[CRAlertViewDelegate alloc] init];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Circlet" message:@"Welcome to Circlet. Set up your first circles by tapping Begin, or configure them later in Settings. Thanks for the dollar, I promise not to disappoint." delegate:circletAVDelegate cancelButtonTitle:@"Later" otherButtonTitles:@"Begin", nil];
		[alert show];
		[alert release];
		//[circletAVDelegate release];
	}
}
%end

%hook UIStatusBarSignalStrengthItemView

-(_UILegibilityImageSet *)contentsImage{
	CRNotificationListener *listener = [CRNotificationListener sharedListener];
	BOOL shouldOverride = [listener enabledForClassname:@"UIStatusBarSignalStrengthItemView"];
	[listener debugLog:[NSString stringWithFormat:@"Heard call to -contentsImage, looks like we %@ override.",shouldOverride?@"should":@"shouldn't"]];

	if(shouldOverride){
		CGFloat w, a;
		[[[self foregroundStyle] textColorForStyle:[self legibilityStyle]] getWhite:&w alpha:&a];
		int bars = MSHookIvar<int>(self, "_signalStrengthBars");

		UIImage *white = ALCRGetCircleForSignalStrength(bars, 5, listener.signalRadius, listener.signalWhiteColor);
		UIImage *black = ALCRGetCircleForSignalStrength(bars, 5, listener.signalRadius, listener.signalBlackColor);

		ALCRReleaseCircle(white);
		ALCRReleaseCircle(black);
		return (w >= 0.5)?[%c(_UILegibilityImageSet) imageFromImage:white withShadowImage:black]:[%c(_UILegibilityImageSet) imageFromImage:black withShadowImage:white];
	}

	return %orig();
}

%end

%hook UIStatusBarDataNetworkItemView

-(_UILegibilityImageSet *)contentsImage{
	CRNotificationListener *listener = [CRNotificationListener sharedListener];
	if([listener enabledForClassname:@"UIStatusBarDataNetworkItemView"]){
		CGFloat w, a;
		[[[self foregroundStyle] textColorForStyle:[self legibilityStyle]] getWhite:&w alpha:&a];
		int networkType = MSHookIvar<int>(self, "_dataNetworkType");
		int wifiState = MSHookIvar<int>(self, "_wifiStrengthBars");
		
		UIImage *white, *black;
		if(networkType == 5){
			white = ALCRGetCircleForSignalStrength(wifiState, 3, listener.wifiRadius, listener.wifiWhiteColor);
			black = ALCRGetCircleForSignalStrength(wifiState, 3, listener.wifiRadius, listener.wifiBlackColor);
		}

		else{
			white = ALCRGetCircleForSignalStrength(3, 3, listener.wifiRadius, listener.dataWhiteColor);
			black = ALCRGetCircleForSignalStrength(3, 3, listener.wifiRadius, listener.dataBlackColor);
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

-(_UILegibilityImageSet *)contentsImage{
	CRNotificationListener *listener = [CRNotificationListener sharedListener];
	if([listener enabledForClassname:@"UIStatusBarBatteryItemView"]){
		CGFloat w, a;
		[[[self foregroundStyle] textColorForStyle:[self legibilityStyle]] getWhite:&w alpha:&a];
		int level = MSHookIvar<int>(self, "_capacity");
		
		UIImage *white = ALCRGetCircleForSignalStrength(level, 100, listener.batteryRadius, listener.batteryWhiteColor);
		UIImage *black = ALCRGetCircleForSignalStrength(level, 100, listener.batteryRadius, listener.batteryBlackColor);
			
		_UILegibilityImageSet *ret = (w > 0.5)?[%c(_UILegibilityImageSet) imageFromImage:white withShadowImage:black]:[%c(_UILegibilityImageSet) imageFromImage:black withShadowImage:white];
		
		ALCRReleaseCircle(white);
		ALCRReleaseCircle(black);
		return ret;
	}

	return %orig();
}

%end

%end

/**************************** Foreground Layout  ****************************/

%group SpringBoard

%hook UIStatusBarLayoutManager

-(CGRect)_frameForItemView:(UIStatusBarItemView *)arg1 startPosition:(float)arg2{
	CGRect orig = %orig(arg1, arg2);

	if([arg1 isKindOfClass:%c(UIStatusBarSignalStrengthItemView)] && [[CRNotificationListener sharedListener] enabledForClassname:@"UIStatusBarSignalStrengthItemView"])
			return CGRectMake(orig.origin.x, orig.origin.y, [CRNotificationListener sharedListener].signalRadius * 2.0, orig.size.height);

	else if([arg1 isKindOfClass:%c(UIStatusBarDataNetworkItemView)] && [[CRNotificationListener sharedListener] enabledForClassname:@"UIStatusBarDataNetworkItemView"])
		return CGRectMake(orig.origin.x + 1.0, orig.origin.y, [CRNotificationListener sharedListener].wifiRadius * 2.0, orig.size.height);
	
	else if([arg1 isKindOfClass:%c(UIStatusBarBatteryItemView)] && [[CRNotificationListener sharedListener] enabledForClassname:@"UIStatusBarBatteryItemView"]){
		int state = MSHookIvar<int>(arg1, "_state");
		if(state != 0)
			[[[arg1 subviews] lastObject] setHidden:YES];

		return CGRectMake(orig.origin.x, orig.origin.y, [CRNotificationListener sharedListener].batteryRadius * 2.0, orig.size.height);
	}

	return orig;
}

%end

%end

%group NotSpringBoard

%hook UIStatusBarLayoutManager
CGFloat cg_dataPoint;

-(CGRect)_frameForItemView:(UIStatusBarItemView *)arg1 startPosition:(float)arg2{
	CGRect orig = %orig(arg1, arg2);

	if([arg1 isKindOfClass:%c(UIStatusBarSignalStrengthItemView)]){
		if([[CRNotificationListener sharedListener] enabledForClassname:@"UIStatusBarSignalStrengthItemView"]){
			CGFloat radius = [CRNotificationListener sharedListener].signalRadius;
			cg_dataPoint = orig.origin.x + (radius * 2.0);
			return CGRectMake(orig.origin.x - 4.0, orig.origin.y, radius * 2.0, orig.size.height);
		}

		cg_dataPoint = orig.origin.x + orig.size.width;
	}

	else if([arg1 isKindOfClass:%c(UIStatusBarServiceItemView)])
		cg_dataPoint += orig.size.width;

	else if([arg1 isKindOfClass:%c(UIStatusBarDataNetworkItemView)] && [[CRNotificationListener sharedListener] enabledForClassname:@"UIStatusBarDataNetworkItemView"]){
		CGFloat radius = [CRNotificationListener sharedListener].wifiRadius;
		return CGRectMake(cg_dataPoint, orig.origin.y, radius * 2.0, orig.size.height);
	}
	
	else if([arg1 isKindOfClass:%c(UIStatusBarBatteryItemView)] && [[CRNotificationListener sharedListener] enabledForClassname:@"UIStatusBarBatteryItemView"]){
		int state = MSHookIvar<int>(arg1, "_state");
		if(state != 0)
			[[[arg1 subviews] lastObject] setHidden:YES];

		return CGRectMake(orig.origin.x + 3.0, orig.origin.y, [CRNotificationListener sharedListener].batteryRadius * 2.0, orig.size.height);
	}

	return orig;
}

%end

%end

%ctor{
	%init(Shared);
	if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"])
		%init(SpringBoard);
	else
		%init(NotSpringBoard);
}