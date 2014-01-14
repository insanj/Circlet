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

static BOOL debug, signalEnabled;
static CGFloat signalDiameter, signalPadding = 12.f;
static CRView *signalCircle;

#ifdef debug
	#define debugLog(string, ...) NSLog(@"[Circular] \e[1;31m%@\e[m ",[NSString stringWithFormat:string, ## __VA_ARGS__])
#else
	#define debugLog(string, ...)
#endif

void setupAllPrefs(){
	debugLog(@"----- setup!");
	NSDictionary *settings =  [NSDictionary dictionaryWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.insanj.circular.plist"]];
	signalEnabled = settings[@"signalEnabled"] == nil || [settings[@"signalEnabled"] boolValue];
	debug = settings[@"debugEnabled"] == nil || [settings[@"debugEnabled"] boolValue];
}

//CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object,CFDictionaryRef userInfo
void CRSignalEnabled(){
	debugLog(@"Detected change of signal switch in preferences");
	//NSLog(@"---- userinfo:%@", userInfo);
	NSDictionary *settings =  [NSDictionary dictionaryWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.insanj.circular.plist"]];
	signalEnabled = settings[@"signalEnabled"] == nil || [settings[@"signalEnabled"] boolValue];
}

void CRDebugEnabled(){
	debugLog(@"Detected change of debug logs in preferences");
	NSDictionary *settings =  [NSDictionary dictionaryWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.insanj.circular.plist"]];
	debug = settings[@"debugEnabled"] == nil || [settings[@"debugEnabled"] boolValue];
}


%ctor {
	signalCircle = [[CRView alloc] initWithRadius:8.f];

	setupAllPrefs();

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)CRSignalEnabled, CFSTR("com.insanj.circular/signalEnabled"), NULL, 0);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)CRDebugEnabled, CFSTR("com.insanj.circular/debugEnabled"), NULL, 0);
}


// Signal circle

@interface UIStatusBarSignalStrengthItemView (Circular)
-(void)setCircle:(CRView *)arg1;
-(UIImage *)imageFromCircle:(CRView *)arg1;
@end

%hook UIStatusBarSignalStrengthItemView
static int signalState;

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
	if(signalEnabled){
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
	if([arg1 isKindOfClass:%c(UIStatusBarSignalStrengthItemView)] && signalEnabled){
		debugLog(@"Changing the spacing for statusbaritem: %@", arg1);
		return CGRectMake(%orig().origin.x, signalPadding / 2.f, signalDiameter, signalDiameter);
	}

	return %orig();
}
%end