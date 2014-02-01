//
//  Circlet.xm
//  Circlet
//
//  Created by Julian Weiss on 1/5/14.
//  Copyright (c) 2014 insanj. All rights reserved.
//

#import "Circlet.h"

#define CRPathFrom(a) [@"/Library/PreferenceBundles/CRPrefs.bundle/Assets/" stringByAppendingString:a]
#define DEGREES_TO_RADIANS(degrees) ((M_PI * degrees)/180)
#define RADIUS 5

/**************************** StatusBar Image Replacment  ****************************/

static UIImage *ALCRGetBlackCircleForSignalStrength(int number, int max){
	UIGraphicsBeginImageContext(CGSizeMake(20, 20));
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetShouldAntialias(context, YES);
	CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
	CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
	CGContextStrokeEllipseInRect(context, CGRectMake(10-RADIUS, 10-RADIUS, RADIUS*2, RADIUS*2));
	CGPoint center = CGPointMake(10, 10);
	
	if(number==max)
		CGContextFillEllipseInRect(context, CGRectMake(10-RADIUS, 10-RADIUS, RADIUS*2, RADIUS*2));
	else
		CGContextAddArc(context, center.x, center.y, RADIUS, DEGREES_TO_RADIANS(270-(180*number/max)), DEGREES_TO_RADIANS(270+(180*number/max)), 1);

    CGContextDrawPath(context, kCGPathFill);
	UIImage *ret = UIGraphicsGetImageFromCurrentImageContext();
	CGContextRelease(context);
	return ret;
}

static UIImage *ALCRGetWhiteCircleForSignalStrength(int number, int max){
	UIGraphicsBeginImageContext(CGSizeMake(20, 20));
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetShouldAntialias(context, YES);
	CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
	CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
	CGContextStrokeEllipseInRect(context, CGRectMake(10-RADIUS, 10-RADIUS, RADIUS*2, RADIUS*2));
	
	CGPoint center = CGPointMake(10, 10);
	if(number==max)
		CGContextFillEllipseInRect(context, CGRectMake(10-RADIUS, 10-RADIUS, RADIUS*2, RADIUS*2));
	else
		CGContextAddArc(context, center.x, center.y, RADIUS, DEGREES_TO_RADIANS(270-(180*number/max)), DEGREES_TO_RADIANS(270+(180*number/max)), 1);
	
    CGContextDrawPath(context, kCGPathFill);
	UIImage *ret = UIGraphicsGetImageFromCurrentImageContext();
	CGContextRelease(context);
	return ret;
}

static void ALCRReleaseCircle(UIImage *circle){
	return; //Not sure what UIGraphicsGetImageFromCurrentImageContext's return's retain count is - appears to be 0(?)
}

/**************************** CRAVDelegate (used from LS) ****************************/

@interface CRAlertViewDelegate : NSObject <UIAlertViewDelegate>
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
@end

@implementation CRAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if(buttonIndex != 0)
		[(SpringBoard *)[UIApplication sharedApplication] applicationOpenURL:[NSURL URLWithString:@"prefs:root=Circlet"] publicURLsOnly:NO];
}
@end

/**************************** Shared, SB and LS Hooks ****************************/

%group Shared

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
		[[[UIAlertView alloc] initWithTitle:@"Circlet" message:@"Welcome to Circlet. Set up your first circles by tapping Begin, or configure them later in Settings. Thanks for the dollar, I promise not to disappoint." delegate:circletAVDelegate cancelButtonTitle:@"Later" otherButtonTitles:@"Begin", nil] show];
	}
}
%end

%hook UIStatusBarSignalStrengthItemView

-(_UILegibilityImageSet *)contentsImage{
	CGFloat w, a;
	[[[self foregroundStyle] textColorForStyle:[self legibilityStyle]] getWhite:&w alpha:&a];
	int bars = MSHookIvar<int>(self, "_signalStrengthBars") - 1;

	UIImage *white = ALCRGetWhiteCircleForSignalStrength(bars, 5);
	UIImage *black = ALCRGetBlackCircleForSignalStrength(bars, 5);

	ALCRReleaseCircle(white);
	ALCRReleaseCircle(black);
	return (w >= 0.5f)?[%c(_UILegibilityImageSet) imageFromImage:white withShadowImage:black]:[%c(_UILegibilityImageSet) imageFromImage:black withShadowImage:white];
}

%end

%hook UIStatusBarDataNetworkItemView

-(_UILegibilityImageSet *)contentsImage{
	CGFloat w, a;
	[[[self foregroundStyle] textColorForStyle:[self legibilityStyle]] getWhite:&w alpha:&a];
	int networkType = MSHookIvar<int>(self, "_dataNetworkType");
	int wifiState = MSHookIvar<int>(self, "_wifiStrengthBars") - 1;
	
	UIImage *white, *black;
	if(networkType == 5){
		white = ALCRGetWhiteCircleForSignalStrength(wifiState, 3);
		black = ALCRGetBlackCircleForSignalStrength(wifiState, 3);
	}

	else{
		white = ALCRGetWhiteCircleForSignalStrength(3, 3);
		black = ALCRGetBlackCircleForSignalStrength(3, 3);
	}

	_UILegibilityImageSet *ret = (w > 0.5f)?[%c(_UILegibilityImageSet) imageFromImage:white withShadowImage:black]:[%c(_UILegibilityImageSet) imageFromImage:black withShadowImage:white];

	ALCRReleaseCircle(white);
	ALCRReleaseCircle(black);
	return ret;
}

%end

%hook UIStatusBarBatteryItemView

-(_UILegibilityImageSet *)contentsImage{
	CGFloat w, a;
	[[[self foregroundStyle] textColorForStyle:[self legibilityStyle]] getWhite:&w alpha:&a];
	int level = ceilf((MSHookIvar<int>(self, "_capacity")) * 0.19f);
	int state = MSHookIvar<int>(self, "_state");
	
	UIImage *white, *black;
	if(state != 0){
		white = ALCRGetWhiteCircleForSignalStrength(level+19, 20);
		black = ALCRGetBlackCircleForSignalStrength(level+19, 20);
	}

	else{
		white = ALCRGetWhiteCircleForSignalStrength(level, 20);
		black = ALCRGetBlackCircleForSignalStrength(level, 20);
	}
		
	_UILegibilityImageSet *ret = (a > 0.5f)?[%c(_UILegibilityImageSet) imageFromImage:white withShadowImage:black]:[%c(_UILegibilityImageSet) imageFromImage:black withShadowImage:white];
	
	ALCRReleaseCircle(white);
	ALCRReleaseCircle(black);
	return ret;
}

%end

%end

/**************************** Background Layout Hook  ****************************/

%group NonSpringBoard

%hook UIStatusBarLayoutManager

-(CGRect)_frameForItemView:(UIStatusBarItemView *)arg1 startPosition:(float)arg2{
	CGRect orig = %orig(arg1, arg2);
	if([arg1 isKindOfClass:%c(UIStatusBarSignalStrengthItemView)])
		return CGRectMake(orig.origin.x, orig.origin.y, RADIUS*2+4, orig.size.height);
	
	else if([arg1 isKindOfClass:%c(UIStatusBarDataNetworkItemView)])
		return CGRectMake(orig.origin.x, orig.origin.y, RADIUS*2+4, orig.size.height);
	
	else if([arg1 isKindOfClass:%c(UIStatusBarBatteryItemView)]){
		int state = MSHookIvar<int>(arg1, "_state");
		if(state) [[[arg1 subviews] lastObject] setHidden:YES];
	}

	return orig;
}

%end

%end

/**************************** Foreground Layout Hooks  ****************************/

%group SpringBoard

%hook UIStatusBarLayoutManager

-(CGRect)_frameForItemView:(UIStatusBarItemView *)arg1 startPosition:(float)arg2{
	CGRect orig = %orig(arg1, arg2);
	if([arg1 isKindOfClass:%c(UIStatusBarSignalStrengthItemView)]) 
		return CGRectMake(orig.origin.x, orig.origin.y, RADIUS*2, orig.size.height);

	/*else if([className isEqualToString:@"UIStatusBarServiceItemView"])
		signalWidth += %orig().size.width;
	*/

	else if([arg1 isKindOfClass:%c(UIStatusBarDataNetworkItemView)])
		return CGRectMake(orig.origin.x, orig.origin.y, RADIUS*2, orig.size.height);
	
	else if([arg1 isKindOfClass:%c(UIStatusBarBatteryItemView)]){
		int state = MSHookIvar<int>(arg1, "_state");
		if(state != 0)
			[[[arg1 subviews] lastObject] setHidden:YES];
	}

	return orig;
}

%end

%end

%ctor{
	if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"])
		%init(SpringBoard);
	else
		%init(NonSpringBoard);
	%init(Shared);
}