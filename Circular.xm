//
//  Circular.xm
//  CellCircle
//
//  Created by Julian Weiss on 1/5/14.
//  Copyright (c) 2014 insanj. All rights reserved.
//

#import "CRHeaders.h"
#import "CRView.h"

// Global variables and functions for preference usage

static BOOL debug = YES, signalDisabled;
static CGFloat signalDiameter, signalPadding = 12.f;

#ifdef debug
	#define debugLog(string, ...) NSLog(@"[Circular] \e[1;31m%@\e[m ",[NSString stringWithFormat:string, ## __VA_ARGS__])
#else
	#define debugLog(string, ...)
#endif

static void toggleSignal(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object,CFDictionaryRef userInfo){
	NSLog(@"---- userinfo:%@", userInfo);
	NSDictionary *settings =  [NSDictionary dictionaryWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.insanj.circular.plist"]];
	signalDisabled = [settings[@"signalDisabled"] boolValue];
}

static void toggleDebug(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object,CFDictionaryRef userInfo){
	NSDictionary *settings =  [NSDictionary dictionaryWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.insanj.circular.plist"]];
	debug = settings[@"debugEnabled"] == nil || [settings[@"debugEnabled"] boolValue];
}

// Signal circle

@interface UIStatusBarSignalStrengthItemView (Circular)
-(void)setCircle:(CRView *)arg1;
-(UIImage *)imageFromCircle:(CRView *)arg1;
@end

%hook UIStatusBarSignalStrengthItemView
static int signalState;
static CRView *signalCircle;

-(id)init{
	UIStatusBarSignalStrengthItemView *original = %orig;
	[original setCircle:[[CRView alloc] initWithRadius:8.f]];
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &toggleSignal, CFSTR("com.insanj.circular.signalDisabled"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &toggleDebug, CFSTR("com.insanj.circular.debugEnabled"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);


	return %orig();
}


%new -(void)setCircle:(CRView *)arg1{
	signalCircle = arg1;
}

// Generate a UIImage from given CRView using GraphicsImageContext (should be quite accurate)
%new -(UIImage *)imageFromCircle:(CRView *)arg1{
	UIGraphicsBeginImageContextWithOptions(arg1.bounds.size, NO, 0.f);
    [arg1.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

// Return a converted CRView (to UIImage) in both black and white, to replace the contentsImage 
-(_UILegibilityImageSet *)contentsImage{
	if(!signalDisabled){
		debugLog(@"Dealing with old signal view's symbol management");

		signalDiameter = [%orig image].size.height - signalPadding;
		CGFloat radius = (signalDiameter / 2.f);
		if(signalCircle.radius != radius)
			[signalCircle setRadius:radius];

		signalState = MSHookIvar<int>(self, "_signalStrengthBars");
		[signalCircle setState:signalState];

		UIColor *textColor = [[self foregroundStyle] textColorForStyle:[self legibilityStyle]];
		UIImage *image = [self imageFromCircle:[signalCircle versionWithColor:textColor]];
		UIImage *shadow = [self imageFromCircle:[signalCircle versionWithInverse:textColor]];

		return [%c(_UILegibilityImageSet) imageFromImage:image withShadowImage:shadow];
	}

	return %orig();
}

%end

%hook UIStatusBarLayoutManager

// Make sure the spacing in the layoutmanager is the circle's preferred, not original
-(CGRect)_frameForItemView:(UIStatusBarItemView *)arg1 startPosition:(float)arg2{
	if([arg1 isKindOfClass:%c(UIStatusBarSignalStrengthItemView)] && !signalDisabled){
		debugLog(@"Changing the spacing for statusbaritem: %@", arg1);
		return CGRectMake(%orig().origin.x, signalPadding / 2.f, signalDiameter, signalDiameter);
	}

	return %orig;
}
%end