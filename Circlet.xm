//
//  Circlet.xm
//  Circlet
//
//  Created by Julian Weiss on 1/5/14.
//  Copyright (c) 2014 insanj. All rights reserved.
//

#import "CRHeaders.h"
#import "CRNotificationListener.h"
#import "CRView.h"

// Global variables and functions for preference usage
static CRNotificationListener *listener;
static CRView *signalCircle, *wifiCircle, *batteryCircle;
static CGFloat signalDiameter, wifiDiameter, batteryDiameter;
static CGFloat signalWidth;

/**************************** Global Functions ****************************/

// Retrieve saved information from a new CRNotificationListener
static void CCGenerateListener(){
	NSLog(@"---- gnerate!");
	listener = [[CRNotificationListener alloc] init];
	[listener reloadPrefs];

	signalCircle = [[CRView alloc] initWithRadius:listener.signalPadding];
	wifiCircle = [[CRView alloc] initWithRadius:listener.wifiPadding];
	batteryCircle = [[CRView alloc] initWithRadius:listener.batteryPadding];
}

// Generate a UIImage from given CRView using GraphicsImageContext (should be quite accurate)
static UIImage * imageFromCircle(CRView * arg1){
	UIGraphicsBeginImageContextWithOptions(arg1.bounds.size, NO, 0.f);
    [arg1.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

%ctor{
	CCGenerateListener();
}

%subclass CCPreferencesManager : NSObject
-(id)init{
	if((self = [[%c(NSObject) alloc] init])){
		NSLog(@"---- to!");
	}

	return self;
}

%new -(void)generateListener{
	NSLog(@"------ geee");
	CCGenerateListener();
}
%end


/**************************** Signal Strength ****************************/

%hook UIStatusBarSignalStrengthItemView

// Return a converted CRView (to UIImage) in both black and white, to replace the contentsImage 
-(_UILegibilityImageSet *)contentsImage{
	if(listener.signalEnabled){
		[listener debugLog:@"Dealing with old signal view's symbol management"];

		signalDiameter = [%orig image].size.height - listener.signalPadding;
		CGFloat radius = (signalDiameter / 2.f);
		if(signalCircle.radius != radius)
			[signalCircle setRadius:radius];

		CGFloat signalState = MSHookIvar<int>(self, "_signalStrengthBars");
		[listener debugLog:[NSString stringWithFormat:@"SignalStrength Bars:%f", signalState]];
		[signalCircle setState:signalState withMax:5.0];

		UIColor *textColor = [[self foregroundStyle] textColorForStyle:[self legibilityStyle]];

		CGFloat w, a;
		[textColor getWhite:&w alpha:&a];

		UIImage *image, *shadow;
		if(w > 0.5f){ // white color
			image = imageFromCircle([signalCircle versionWithColor:listener.signalWhiteColor]);
			shadow = imageFromCircle([signalCircle versionWithColor:listener.signalBlackColor]);
		}

		else{
			image = imageFromCircle([signalCircle versionWithColor:listener.signalBlackColor]);
			shadow = imageFromCircle([signalCircle versionWithColor:listener.signalWhiteColor]);
		}

		[listener debugLog:[NSString stringWithFormat:@"Created Signal Circle view with radius:%f, state:%f, lightColor:%@, and darkColor:%@ (for current white:%f)", radius, signalState, image, shadow, w]];
		return [%c(_UILegibilityImageSet) imageFromImage:image withShadowImage:shadow];
	}

	return %orig();
}
%end

/**************************** Wifi/Data Strength  ****************************/


@interface UIStatusBarDataNetworkItemView (Circlet)
-(_UILegibilityImageSet *)replacementImageFor:(_UILegibilityImageSet *)orig;
@end

%hook UIStatusBarDataNetworkItemView

%new -(_UILegibilityImageSet *)replacementImageFor:(_UILegibilityImageSet *)orig{
	[listener debugLog:@"Dealing with old data view's symbol management"];

	wifiDiameter = [orig image].size.height - listener.wifiPadding;
	CGFloat radius = (wifiDiameter / 2.f);
	if(wifiCircle.radius != radius)
		[wifiCircle setRadius:radius];

	int networkType = MSHookIvar<int>(self, "_dataNetworkType");
	int wifiState = MSHookIvar<int>(self, "_wifiStrengthBars");
	[listener debugLog:[NSString stringWithFormat:@"WifiStrength Bars:%i", wifiState]];
	if(networkType == 5)
		[wifiCircle setState:wifiState withMax:3];
	else
		[wifiCircle setState:1 withMax:1];

	UIColor *textColor = [[self foregroundStyle] textColorForStyle:[self legibilityStyle]];

	CGFloat w, a;
	[textColor getWhite:&w alpha:&a];

	UIImage *image, *shadow;
	UIColor *white = (networkType == 5)?listener.wifiWhiteColor:listener.dataWhiteColor;
	UIColor *black = (networkType == 5)?listener.wifiBlackColor:listener.dataBlackColor;

	if(w > 0.5f){ // white color
		image = imageFromCircle([wifiCircle versionWithColor:white]);
		shadow = imageFromCircle([wifiCircle versionWithColor:black]);
	}

	else{
		image = imageFromCircle([wifiCircle versionWithColor:black]);
		shadow = imageFromCircle([wifiCircle versionWithColor:white]);
	}

	[listener debugLog:[NSString stringWithFormat:@"Created Data Circle view with radius:%f, type:%i, strength:%i, lightColor:%@, and darkColor:%@ (for current white:%f)", radius, networkType, wifiState, image, shadow, w]];

	return [%c(_UILegibilityImageSet) imageFromImage:image withShadowImage:shadow];
}

-(_UILegibilityImageSet *)contentsImage{
	if(listener.wifiEnabled)
		return [self replacementImageFor:%orig()];

	return %orig();
}
%end

/**************************** Battery Strength  ****************************/

//%hook UIStatusBarNotChargingItemView?!

%hook UIStatusBarBatteryItemView

-(_UILegibilityImageSet *)contentsImage{
	if(listener.batteryEnabled){
		[listener debugLog:@"Dealing with old battery view's symbol management"];

		batteryDiameter = [%orig image].size.height - listener.batteryPadding;
		CGFloat radius = (batteryDiameter / 2.f);
		if(batteryCircle.radius != radius)
			[batteryCircle setRadius:radius];

		CGFloat capacity = MSHookIvar<int>(self, "_capacity");
		[batteryCircle setState:capacity withMax:100];

		UIColor *textColor = [[self foregroundStyle] textColorForStyle:[self legibilityStyle]];

		CGFloat w, a;
		[textColor getWhite:&w alpha:&a];

		int state = MSHookIvar<int>(self, "_state");
		UIImage *image, *shadow;
		UIColor *white = (state != 0)?listener.chargingWhiteColor:listener.batteryWhiteColor;
		UIColor *black = (state != 0)?listener.chargingBlackColor:listener.batteryBlackColor;

		if(w > 0.5f){ // white color
			image = imageFromCircle([batteryCircle versionWithColor:white]);
			shadow = imageFromCircle([batteryCircle versionWithColor:black]);
		}

		else{
			image = imageFromCircle([batteryCircle versionWithColor:black]);
			shadow = imageFromCircle([batteryCircle versionWithColor:white]);
		}

		[listener debugLog:[NSString stringWithFormat:@"Created Battery Circle view with radius:%f, capacity:%f, state:%i, lightColor:%@, and darkColor:%@ (for current white:%f)", radius, capacity, state, image, shadow, w]];
		return [%c(_UILegibilityImageSet) imageFromImage:image withShadowImage:shadow];
	}

	return %orig();
}
%end

/**************************** Item View Spacing  ****************************/

%hook UIStatusBarLayoutManager

-(CGRect)_frameForItemView:(UIStatusBarItemView *)arg1 startPosition:(float)arg2{
	if([arg1 isKindOfClass:%c(UIStatusBarSignalStrengthItemView)]){
		if(listener.signalEnabled){
			signalWidth = signalDiameter;
			[listener debugLog:[NSString stringWithFormat:@"Changing the spacing for statusbar item: %@ (from %@)", arg1, NSStringFromCGRect(%orig())]];
			return CGRectMake(%orig().origin.x, ceilf(listener.signalPadding / 2.25f), signalDiameter, signalDiameter);
		}
		
		signalWidth = %orig().size.width;
	}

	else if([arg1 isKindOfClass:%c(UIStatusBarServiceItemView)])
		signalWidth += %orig().size.width + 5.f;

	else if([arg1 isKindOfClass:%c(UIStatusBarDataNetworkItemView)] && listener.wifiEnabled){
		[listener debugLog:[NSString stringWithFormat:@"Changing the spacing for statusbar item: %@ from (%@)", arg1, NSStringFromCGRect(%orig())]];
		return CGRectMake(ceilf(signalWidth + wifiDiameter + 1.f), ceilf(listener.wifiPadding / 2.25f), wifiDiameter, wifiDiameter);
	}

	else if([arg1 isKindOfClass:%c(UIStatusBarBatteryItemView)] && listener.batteryEnabled){
		[listener debugLog:[NSString stringWithFormat:@"Changing the spacing for statusbar item: %@ from (%@)", arg1, NSStringFromCGRect(%orig())]];

		CGRect batteryFrame = CGRectMake(%orig().origin.x, ceilf(listener.batteryPadding / 2.25f), batteryDiameter, batteryDiameter);
		
		int state = MSHookIvar<int>(arg1, "_state");
		if(state != 0)
			[[[arg1 subviews] lastObject] setHidden:YES];

		return batteryFrame;
	}

	return %orig();
}
%end