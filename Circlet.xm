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
static CRView *signalCircle, *wifiCircle;
static CGFloat signalDiameter, wifiDiameter;

static BOOL initialized;
static CGFloat signalWidth;

%ctor{
	if(!initialized){
		initialized = YES;
		@autoreleasepool{
			listener = [[CRNotificationListener alloc] init];
			[listener reloadPrefs];

			signalCircle = [[CRView alloc] initWithRadius:listener.signalPadding];
			wifiCircle = [[CRView alloc] initWithRadius:listener.wifiPadding];
		}
	}
}

// Generate a UIImage from given CRView using GraphicsImageContext (should be quite accurate)
static UIImage * imageFromCircle(CRView * arg1){
	UIGraphicsBeginImageContextWithOptions(arg1.bounds.size, NO, 0.f);
    [arg1.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


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

		[listener debugLog:[NSString stringWithFormat:@"Created Circle view with radius:%f, state:%f, lightColor:%@, and darkColor:%@ (for current white:%f)", radius, signalState, image, shadow, w]];
		return [%c(_UILegibilityImageSet) imageFromImage:image withShadowImage:shadow];
	}

	return %orig();
}
%end

@interface UIStatusBarDataNetworkItemView (Circlet)
-(_UILegibilityImageSet *)replacementImageFor:(_UILegibilityImageSet *)orig;
@end

%hook UIStatusBarDataNetworkItemView

%new -(_UILegibilityImageSet *)replacementImageFor:(_UILegibilityImageSet *)orig{
	[listener debugLog:@"Dealing with old signal view's symbol management"];

	wifiDiameter = [orig image].size.height - listener.wifiPadding;
	CGFloat radius = (wifiDiameter / 2.f);
	if(wifiCircle.radius != radius)
		[wifiCircle setRadius:radius];

	int wifiState = MSHookIvar<int>(self, "_wifiStrengthBars");
	[listener debugLog:[NSString stringWithFormat:@"WifiStrength Bars:%i", wifiState]];
	[wifiCircle setState:wifiState withMax:3];

	UIColor *textColor = [[self foregroundStyle] textColorForStyle:[self legibilityStyle]];

	CGFloat w, a;
	[textColor getWhite:&w alpha:&a];

	UIImage *image, *shadow;
	int networkType = MSHookIvar<int>(self, "_dataNetworkType");
	[listener debugLog:[NSString stringWithFormat:@"Network type: %i", networkType]];

	if(w > 0.5f){ // white color
		image = imageFromCircle([wifiCircle versionWithColor:((networkType == 5)?listener.wifiWhiteColor : listener.dataWhiteColor)]);
		shadow = imageFromCircle([wifiCircle versionWithColor:((networkType == 5)?listener.wifiBlackColor : listener.dataBlackColor)]);
	}

	else{
		image = imageFromCircle([wifiCircle versionWithColor:((networkType == 5)?listener.wifiBlackColor : listener.dataBlackColor)]);
		shadow = imageFromCircle([wifiCircle versionWithColor:((networkType == 5)?listener.wifiWhiteColor : listener.dataWhiteColor)]);
	}

	return [%c(_UILegibilityImageSet) imageFromImage:image withShadowImage:shadow];
}

-(_UILegibilityImageSet *)contentsImage{
	if(listener.wifiEnabled)
		return [self replacementImageFor:%orig()];

	return %orig();
}
%end


%hook UIStatusBarLayoutManager

-(CGRect)_frameForItemView:(UIStatusBarItemView *)arg1 startPosition:(float)arg2{
	if([arg1 isKindOfClass:%c(UIStatusBarSignalStrengthItemView)]){
		if(listener.signalEnabled){
			signalWidth = signalDiameter;
			[listener debugLog:[NSString stringWithFormat:@"Changing the spacing for statusbar item: %@ (from %@)", arg1, NSStringFromCGRect(%orig())]];
			return CGRectMake(%orig().origin.x, ceilf(listener.signalPadding / 2.45f), signalDiameter, signalDiameter);
		}
		
		signalWidth = %orig().size.width;
	}

	else if([arg1 isKindOfClass:%c(UIStatusBarServiceItemView)])
		signalWidth += %orig().size.width + 5.f;

	else if([arg1 isKindOfClass:%c(UIStatusBarDataNetworkItemView)] && listener.wifiEnabled){
		[listener debugLog:[NSString stringWithFormat:@"Changing the spacing for statusbar item: %@ from (%@)", arg1, NSStringFromCGRect(%orig())]];
		return CGRectMake(ceilf(signalWidth + wifiDiameter + 1.f), ceilf(listener.wifiPadding / 2.45f), wifiDiameter, wifiDiameter);
	}

	return %orig();
}
%end