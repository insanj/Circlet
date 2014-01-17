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

static CGFloat signalDiameter, wifiDiameter, batteryDiameter;
static CGFloat signalWidth;

/******************** SpringBoard (foreground) Methods ********************/

@interface SpringBoard (Circlet)
+(CRNotificationListener *)CRSharedListener;
+(UIImage *)imageFromCircle:(CRView *)circle;
@end

%hook SpringBoard
%new +(CRNotificationListener *)CRSharedListener{ 
 	return [CRNotificationListener sharedInstance];
}

%new +(UIImage *)imageFromCircle:(CRView *)circle{
	UIGraphicsBeginImageContextWithOptions(circle.bounds.size, NO, 0.f);
    [circle.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
%end

/**************************** Signal Strength ****************************/

%hook UIStatusBarSignalStrengthItemView

// Return a converted CRView (to UIImage) in both black and white, to replace the contentsImage 
-(_UILegibilityImageSet *)contentsImage{
	CRNotificationListener *listener = [%c(SpringBoard) CRSharedListener];
	if(listener.signalEnabled){
		[listener debugLog:@"Dealing with old signal view's symbol management"];

		CRView *signalCircle = listener.signalCircle;
		signalDiameter = [%orig() image].size.height - listener.signalPadding;
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
			image = [%c(SpringBoard) imageFromCircle:[signalCircle versionWithColor:listener.signalWhiteColor]];
			shadow = [%c(SpringBoard) imageFromCircle:[signalCircle versionWithColor:listener.signalBlackColor]];
		}

		else{
			image = [%c(SpringBoard) imageFromCircle:[signalCircle versionWithColor:listener.signalBlackColor]];
			shadow = [%c(SpringBoard) imageFromCircle:[signalCircle versionWithColor:listener.signalWhiteColor]];
		}

		[listener debugLog:[NSString stringWithFormat:@"Created Signal Circle view with radius:%f, state:%f, lightColor:%@, and darkColor:%@ (for current white:%f)", radius, signalState, image, shadow, w]];
		return [%c(_UILegibilityImageSet) imageFromImage:image withShadowImage:shadow];
	}

	return %orig();
}

%end

/**************************** Wifi/Data Strength  ****************************/

%hook UIStatusBarDataNetworkItemView

-(_UILegibilityImageSet *)contentsImage{
	CRNotificationListener *listener = [%c(SpringBoard) CRSharedListener];
	if(listener.wifiEnabled){
		[listener debugLog:@"Dealing with old data view's symbol management"];

		CRView *wifiCircle = listener.wifiCircle;
		wifiDiameter = [%orig() image].size.height - listener.wifiPadding;
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
			image = [%c(SpringBoard) imageFromCircle:[wifiCircle versionWithColor:white]];
			shadow = [%c(SpringBoard) imageFromCircle:[wifiCircle versionWithColor:black]];
		}

		else{
			image = [%c(SpringBoard) imageFromCircle:[wifiCircle versionWithColor:black]];
			shadow = [%c(SpringBoard) imageFromCircle:[wifiCircle versionWithColor:white]];
		}

		[listener debugLog:[NSString stringWithFormat:@"Created Data Circle view with radius:%f, type:%i, strength:%i, lightColor:%@, and darkColor:%@ (for current white:%f)", radius, networkType, wifiState, image, shadow, w]];

		return [%c(_UILegibilityImageSet) imageFromImage:image withShadowImage:shadow];
	}

	return %orig();
}

%end

/**************************** Battery Strength  ****************************/

//%hook UIStatusBarNotChargingItemView?!

%hook UIStatusBarBatteryItemView

-(_UILegibilityImageSet *)contentsImage{
	CRNotificationListener *listener = [%c(SpringBoard) CRSharedListener];
	if(listener.batteryEnabled){
		[listener debugLog:@"Dealing with old battery view's symbol management"];

		CRView *batteryCircle = listener.batteryCircle;
		batteryDiameter = [%orig() image].size.height - listener.batteryPadding;
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
			image = [%c(SpringBoard) imageFromCircle:[batteryCircle versionWithColor:white]];
			shadow = [%c(SpringBoard) imageFromCircle:[batteryCircle versionWithColor:black]];
		}

		else{
			image = [%c(SpringBoard) imageFromCircle:[batteryCircle versionWithColor:black]];
			shadow = [%c(SpringBoard) imageFromCircle:[batteryCircle versionWithColor:white]];
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
	CRNotificationListener *listener = [%c(SpringBoard) CRSharedListener];

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