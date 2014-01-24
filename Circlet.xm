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

%hook SpringBoard

-(id)init{
	if(![NSDictionary dictionaryWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.insanj.circlet.plist"]])
		[self circlet_generateCirclesFresh];

	return %orig();
}

%new -(void)circlet_generateCirclesFresh{ 
	NSError *error;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	[fileManager removeItemAtPath:@"/private/var/mobile/Library/Circlet" error:&error];

	CRNotificationListener *listener = [CRNotificationListener sharedListener];
	if(listener.signalEnabled){
		[listener.signalCircle setRadius:(listener.signalPadding / 2.0)];
		[self circlet_saveCircle:listener.signalCircle toPath:@"/private/var/mobile/Library/Circlet/Signal" withWhite:listener.signalWhiteColor black:listener.signalBlackColor count:5];
	}

	if(listener.wifiEnabled){
		[listener.wifiCircle setRadius:(listener.wifiPadding / 2.0)];
		[self circlet_saveCircle:listener.wifiCircle toPath:@"/private/var/mobile/Library/Circlet/Wifi" withWhite:listener.wifiWhiteColor black:listener.signalBlackColor count:3];
		[self circlet_saveCircle:listener.wifiCircle toPath:@"/private/var/mobile/Library/Circlet/Data" withWhite:listener.dataWhiteColor black:listener.dataBlackColor count:1];
	}

	if(listener.batteryEnabled){
		[listener.batteryCircle setRadius:(listener.batteryPadding / 2.0)];
		[self circlet_saveCircle:listener.batteryCircle toPath:@"/private/var/mobile/Library/Circlet/Battery" withWhite:listener.batteryWhiteColor black:listener.batteryBlackColor count:20];
		[self circlet_saveCircle:listener.wifiCircle toPath:@"/private/var/mobile/Library/Circlet/Charging" withWhite:listener.chargingWhiteColor black:listener.chargingBlackColor count:20];
	}
}

%new -(void)circlet_saveCircle:(CRView *)circle toPath:(NSString *)path withWhite:(UIColor *)white black:(UIColor *)black count:(int)count{

	NSError *error;
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	if([fileManager fileExistsAtPath:path])
		return;

	[fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
	
	CRView *whiteCircle = [circle versionWithColor:white];
	CRView *blackCircle = [circle versionWithColor:black];

	for(int i = 0; i < count; i++){
		[whiteCircle setState:i withMax:count];
		[blackCircle setState:i withMax:count];

		[self circlet_saveCircle:whiteCircle toPath:path withName:[NSString stringWithFormat:@"/%iWhite@2x.png", i]];
		[self circlet_saveCircle:blackCircle toPath:path withName:[NSString stringWithFormat:@"/%iBlack@2x.png", i]];
	}

	NSLog(@"[Circlet] Wrote %i circle-views to directory: %@", count, [fileManager contentsOfDirectoryAtPath:path error:&error]);
}

%new -(void)circlet_saveCircle:(CRView *)circle toPath:(NSString *)path withName:(NSString *)name{
	UIGraphicsBeginImageContextWithOptions(circle.bounds.size, NO, 0.0);
    [circle.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

	[UIImagePNGRepresentation(image) writeToFile:[path stringByAppendingString:name] atomically:YES];
}

%end

/**************************** StatusBar Image Replacment  ****************************/

%hook UIStatusBarItemView

-(_UILegibilityImageSet *)contentsImage{
	NSString *className = NSStringFromClass([self class]);
	CRNotificationListener *listener = [CRNotificationListener sharedListener];
	BOOL shouldOverride = [listener enabledForClassname:className];
	[listener debugLog:[NSString stringWithFormat:@"Override preferences for classname \"%@\" are set to %@.", className, shouldOverride?@"override":@"ignore"]];

	if(shouldOverride){
		CGFloat w, a;
		[[[self foregroundStyle] textColorForStyle:[self legibilityStyle]] getWhite:&w alpha:&a];
		BOOL isWhite = (w > 0.5);
		UIImage *white, *black;

		if([[self class] isKindOfClass:%c(UIStatusBarSignalStrengthItemView)]){
			int bars = MSHookIvar<int>(self, "_signalStrengthBars");
			white = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"/private/var/mobile/Library/Circlet/Signal/%iWhite@2x.png", bars]];
			black = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"/private/var/mobile/Library/Circlet/Signal/%iBlack@2x.png", bars]];
		}//end if signal

		else if([[self class] isKindOfClass:%c(UIStatusBarDataNetworkItemView)]){
			int networkType = MSHookIvar<int>(self, "_dataNetworkType");
			int wifiState = MSHookIvar<int>(self, "_wifiStrengthBars");
			if(networkType == 5){
				white = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"/private/var/mobile/Library/Circlet/Wifi/%iWhite@2x.png", wifiState]];
				black = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"/private/var/mobile/Library/Circlet/Wifi/%iBlack@2x.png", wifiState]];
			}

			else{
				white = [UIImage imageWithContentsOfFile:@"/private/var/mobile/Library/Circlet/Data/0White@2x.png"];
				black = [UIImage imageWithContentsOfFile:@"/private/var/mobile/Library/Circlet/Data/0Black@2x.png"];
			}
		}//end if wifi

		else if ([[self class] isKindOfClass:%c(UIStatusBarBatteryItemView)]){
			int level = ceilf((MSHookIvar<int>(self, "_capacity")) * (19.0/100.0));
			int state = MSHookIvar<int>(self, "_state");
			if(state != 0){
				white = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"/private/var/mobile/Library/Circlet/Charging/%iWhite@2x.png", level]];
				black = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"/private/var/mobile/Library/Circlet/Charging/%iBlack@2x.png", level]];
			}

			else{
				white = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"/private/var/mobile/Library/Circlet/Battery/%iWhite@2x.png", level]];
				black = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"/private/var/mobile/Library/Circlet/Battery/%iBlack@2x.png", level]];			
			}
		}//end if battery

		return isWhite?[%c(_UILegibilityImageSet) imageFromImage:white withShadowImage:black]:[%c(_UILegibilityImageSet) imageFromImage:black withShadowImage:white];
	}//end if override

	return %orig();
}
%end

/**************************** Item View Spacing  ****************************/

%hook UIStatusBarLayoutManager
CGFloat signalWidth;

-(CGRect)_frameForItemView:(UIStatusBarItemView *)arg1 startPosition:(float)arg2{
	CRNotificationListener *listener = [CRNotificationListener sharedListener];
	NSString *className = NSStringFromClass([arg1 class]);
	NSLog(@"--- className:%@", className);

	if([className isEqualToString:@"UIStatusBarSignalStrengthItemView"]){
		if([listener enabledForClassname:className]){
			[listener debugLog:[NSString stringWithFormat:@"Changing the spacing for statusbar item: %@ (from %@)", arg1, NSStringFromCGRect(%orig())]];

			CGFloat diameter = listener.signalPadding;
			signalWidth = diameter;
			return CGRectMake(%orig().origin.x, ceilf(diameter / 2.25), diameter * 2.0, diameter * 2.0);
		}
		
		signalWidth = %orig().size.width;
	}

	else if([className isEqualToString:@"UIStatusBarServiceItemView"])
		signalWidth += %orig().size.width + 5.0;

	else if([className isEqualToString:@"UIStatusBarDataNetworkItemView"] && [listener enabledForClassname:className]){
		[listener debugLog:[NSString stringWithFormat:@"Changing the spacing for statusbar item: %@ from (%@)", arg1, NSStringFromCGRect(%orig())]];

		CGFloat diameter = listener.wifiPadding;
		return CGRectMake(ceilf(signalWidth + diameter  + 1.0), ceilf(listener.wifiPadding / 2.25), diameter, diameter);
	}

	else if([className isEqualToString:@"UIStatusBarBatteryItemView"] && [listener enabledForClassname:className]){
		[listener debugLog:[NSString stringWithFormat:@"Changing the spacing for statusbar item: %@ from (%@)", arg1, NSStringFromCGRect(%orig())]];

		CGFloat diameter = listener.batteryPadding;
		int state = MSHookIvar<int>(arg1, "_state");
		if(state != 0)
			[[[arg1 subviews] lastObject] setHidden:YES];

		return CGRectMake(%orig().origin.x, ceilf(listener.batteryPadding / 2.25), diameter, diameter);;
	}

	return %orig();
}
%end