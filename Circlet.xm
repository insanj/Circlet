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

/******************** SpringBoard (foreground) Methods ********************/

@interface SpringBoard (Circlet)
-(UIImage *)imageFromCircle:(CRView *)circle;
-(NSArray *)generateCurrentImages:(CRNotificationListener *)listener;
-(_UILegibilityImageSet *)signalImage:(CRNotificationListener *)listener;
-(_UILegibilityImageSet *)wifiImage:(CRNotificationListener *)listener;
-(_UILegibilityImageSet *)batteryImage:(CRNotificationListener *)listener;
@end

%hook SpringBoard
-(id)init{
	NSLog(@"----- init!");

	void (^CRLoadBlock)(NSNotification *notification) = ^void(NSNotification *notification){
		CRNotificationListener *listener = [CRNotificationListener sharedInstance];
		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"CRSharedListener" object:nil userInfo:@{@"CRListener" : listener], @"CRCurrentImages" : [self generateCurrentImagesFrom:listener]}];
	};

	[[NSDistributedNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:CRLoadBlock];
	[[NSDistributedNotificationCenter defaultCenter] addObserverForName:@"CRSendImages" object:nil queue:[NSOperationQueue mainQueue] usingBlock:CRLoadBlock];


	return %orig();
}

%new -(UIImage *)imageFromCircle:(CRView *)circle{
	UIGraphicsBeginImageContextWithOptions(circle.bounds.size, NO, 0.f);
    [circle.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

%new -(NSDictionary *)generateCurrentImages:(CRNotificationListener *)listener{
	CRNotificationListener *listener = [CRNotificationListener sharedInstance];
	return @{@"UIStatusBarSignalStrengthItemView" : [self signalImage:listener], @"UIStatusBarDataNetworkItemView" : [self wifiImage:listener], @"UIStatusBarBatteryItemView" : [self batteryImage:listener]];
}

%new -(_UILegibilityImageSet *)signalImage:(CRNotificationListener *)listener{
	[listener debugLog:[NSString stringWithFormat:@"Generating signal image from shared preferences listener: %@", listener]];

	CRView *signalCircle = listener.signalCircle;
	CGFloat radius = ([%orig() image].size.height - listener.signalPadding) / 2.f;
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
		image = [self imageFromCircle:[signalCircle versionWithColor:listener.signalWhiteColor]];
		shadow = [self imageFromCircle:[signalCircle versionWithColor:listener.signalBlackColor]];
	}

	else{
		image = [self imageFromCircle:[signalCircle versionWithColor:listener.signalBlackColor]];
		shadow = [self imageFromCircle:[signalCircle versionWithColor:listener.signalWhiteColor]];
	}

	[listener debugLog:[NSString stringWithFormat:@"Created Signal Circle view with radius:%f, state:%f, lightColor:%@, and darkColor:%@ (for current white:%f)", radius, signalState, image, shadow, w]];
	return [%c(_UILegibilityImageSet) imageFromImage:image withShadowImage:shadow];
}

%new -(_UILegibilityImageSet *)wifiImage:(CRNotificationListener *)listener{
	[listener debugLog:[NSString stringWithFormat:@"Generating wifi image from shared preferences listener: %@", listener]];

	CRView *wifiCircle = listener.wifiCircle;
	CGFloat radius = ([%orig() image].size.height - listener.wifiPadding) / 2.f;
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

%new -(_UILegibilityImageSet *)batteryImage:(CRNotificationListener *)listener{
	[listener debugLog:@"Dealing with old battery view's symbol management"];

	CRView *batteryCircle = listener.batteryCircle;
	CGFloat radius = ([%orig() image].size.height - listener.batteryPadding) / 2.f;
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

%end

/**************************** StatusBar Image Replacment  ****************************/

%hook UIStatusBarItemView
CRNotificationListener *CRListener;
NSDictionary *CRLegibilityImages;

-(id)initWithItem:(id)arg1 data:(id)arg2 actions:(int)arg3 style:(id)arg4{
	UIStatusBarItemView *o = %orig();
	[[NSDistributedNotificationCenter defaultCenter] addObserver:o selector:@selector(setCRLegibilityImages:) name:@"CRSharedListener" object:nil];
	return o;
}

%new -(void)setCRLegibilityImages:(NSNotification *)notification{
	NSDictionary *userInfo = [notification userInfo];
	CRListener = [userInfo objectForKey:@"CRListener"];
	CRLegibilityImages = [userInfo objectForKey:@"CRCurrentImages"];
}

-(BOOL)updateForNewData:(id)arg1 actions:(int)arg2{
	BOOL should = %orig();
	if(should)
		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"CRSendImages" object:nil];
	return should;
}

-(_UILegibilityImageSet *)contentsImage{
	NSString *currClass = NSStringFromClass([self class]);
	if([CRListener enabledForClassname:currClass])
		return [CRLegibilityImages objectForKey:currClass];

	return %orig();
}
%end

/**************************** Item View Spacing  ****************************/

%hook UIStatusBarLayoutManager
CRNotificationListener *CRListener;
NSDictionary *CRLegibilityImages;
CGFloat signalWidth;

-(id)initWithRegion:(int)arg1 foregroundView:(id)arg2{
	UIStatusBarLayoutManager *o = %orig();
	[[NSDistributedNotificationCenter defaultCenter] addObserver:o selector:@selector(setCRFrameLegibilityImages:) name:@"CRSharedListener" object:nil];
	return o;
}

%new -(void)setCRFrameLegibilityImages:(NSNotification *)notification{
	NSDictionary *userInfo = [notification userInfo];
	CRListener = [userInfo objectForKey:@"CRListener"];
	CRLegibilityImages = [userInfo objectForKey:@"CRCurrentImages"];
}

-(CGRect)_frameForItemView:(UIStatusBarItemView *)arg1 startPosition:(float)arg2{
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"CRSendImages" object:nil];

	if([arg1 isKindOfClass:%c(UIStatusBarSignalStrengthItemView)]){
		if([CRListener enabledForClassname:@"UIStatusBarSignalStrengthItemViews"]){
			[CRListener debugLog:[NSString stringWithFormat:@"Changing the spacing for statusbar item: %@ (from %@)", arg1, NSStringFromCGRect(%orig())]];

			_UILegibilityImageSet *signalSet = [CRLegibilityImages objectForKey:@"UIStatusBarSignalStrengthItemViews"]
			UIImage *image = [signalSet image];
			signalWidth = image.size.width;
			return CGRectMake(%orig().origin.x, ceilf(CRListener.signalPadding / 2.25f), image.size.width * 2, image.size.height * 2);
		}
		
		signalWidth = %orig().size.width;
	}

	else if([arg1 isKindOfClass:%c(UIStatusBarServiceItemView)])
		signalWidth += %orig().size.width + 5.f;

	else if([arg1 isKindOfClass:%c(UIStatusBarDataNetworkItemView)] && [CRListener enabledForClassname:@"UIStatusBarDataNetworkItemView"]){
		[CRListener debugLog:[NSString stringWithFormat:@"Changing the spacing for statusbar item: %@ from (%@)", arg1, NSStringFromCGRect(%orig())]];

		_UILegibilityImageSet *wifiSet = [CRLegibilityImages objectForKey:@"UIStatusBarDataNetworkItemView"]
		CGFloat diameter = [wifiSet image].size.height * 2;
		return CGRectMake(ceilf(signalWidth + diameter  + 1.f), ceilf(CRListener.wifiPadding / 2.25f), diameter, diameter);
		}
	}

	else if([arg1 isKindOfClass:%c(UIStatusBarBatteryItemView)] && [CRListener enabledForClassname:@"UIStatusBarDataNetworkItemView"]){
		[CRListener debugLog:[NSString stringWithFormat:@"Changing the spacing for statusbar item: %@ from (%@)", arg1, NSStringFromCGRect(%orig())]];

		_UILegibilityImageSet *batterySet = [CRLegibilityImages objectForKey:@"UIStatusBarBatteryItemView"]
		CGFloat diameter = [batterySet image].size.height * 2;
		
		int state = MSHookIvar<int>(arg1, "_state");
		if(state != 0)
			[[[arg1 subviews] lastObject] setHidden:YES];

		return CGRectMake(%orig().origin.x, ceilf(CRListener.batteryPadding / 2.25f), diameter, diameter);;
	}

	return %orig();
}
%end