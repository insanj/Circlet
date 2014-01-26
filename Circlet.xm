//
//  Circlet.xm
//  Circlet
//
//  Created by Julian Weiss on 1/5/14.
//  Copyright (c) 2014 insanj. All rights reserved.
//

#import "Circlet.h"
#import "CRNotificationListener.h"
#define CRPathFrom(a) [@"/Library/Application Support/Library/Circlet/" stringByAppendingString:a]

/******************** Initial Launch Hooks ********************/

%hook SBUIController
static BOOL kCRUnlocked;

-(void)_deviceLockStateChanged:(NSNotification *)changed{
	%orig();

	NSNumber *state = changed.userInfo[@"kSBNotificationKeyState"];
	if(!state.boolValue)
		kCRUnlocked = YES;
}
%end

@interface CRAlertViewDelegate : NSObject <UIAlertViewDelegate>
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
@end

@implementation CRAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if(buttonIndex != 0)
		[(SpringBoard *)[UIApplication sharedApplication] applicationOpenURL:[NSURL URLWithString:@"prefs:root=Circlet"] publicURLsOnly:NO];
}
@end

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

/******************** SpringBoard (foreground) Methods ********************/

%hook SpringBoard

%new -(void)circlet_generateCirclesFresh:(CRNotificationListener *)listener{ 
	[listener debugLog:[NSString stringWithFormat:@"Generating circles fresh from listener (%@). Signal: %@, Wifi: %@, Battery: %@", listener, NSStringFromBool(listener.signalEnabled), NSStringFromBool(listener.wifiEnabled), NSStringFromBool(listener.batteryEnabled)]];

	NSError *error;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	[fileManager removeItemAtPath:CRPathFrom(@"") error:&error];
	[fileManager createDirectoryAtPath:CRPathFrom(@"") withIntermediateDirectories:YES attributes:nil error:&error];

	if(listener.signalEnabled){
		[listener.signalCircle setRadius:(listener.signalPadding / 2.0)];
		[self circlet_saveCircle:listener.signalCircle toPath:CRPathFrom(@"Signal/") withWhite:listener.signalWhiteColor black:listener.signalBlackColor count:5];
	}

	if(listener.wifiEnabled){
		[listener.wifiCircle setRadius:(listener.wifiPadding / 2.0)];
		[self circlet_saveCircle:listener.wifiCircle toPath:CRPathFrom(@"Wifi/")withWhite:listener.wifiWhiteColor black:listener.wifiBlackColor count:3];
		[self circlet_saveCircle:listener.wifiCircle toPath:CRPathFrom(@"Data/") withWhite:listener.dataWhiteColor black:listener.dataBlackColor count:1];
	}

	if(listener.batteryEnabled){
		[listener.batteryCircle setRadius:(listener.batteryPadding / 2.0)];
		[self circlet_saveCircle:listener.batteryCircle toPath:CRPathFrom(@"Battery/") withWhite:listener.batteryWhiteColor black:listener.batteryBlackColor count:20];
		[self circlet_saveCircle:listener.wifiCircle toPath:CRPathFrom(@"Charging/") withWhite:listener.chargingWhiteColor black:listener.chargingBlackColor count:20];
	}
}

%new -(void)circlet_saveCircle:(CRView *)circle toPath:(NSString *)path withWhite:(UIColor *)white black:(UIColor *)black count:(int)count{

	NSLog(@"--- saveCircle:%@ toPath:%@ withWhite:%@ black:%@ count:%i", circle, path, white, black, count);

	NSError *error;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if([fileManager fileExistsAtPath:path])
		return;

	[fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];

	NSLog(@"---- passed initial tests, created directory at path %@, check:%@, contents:%@", path, NSStringFromBool([fileManager fileExistsAtPath:path]), [fileManager contentsOfDirectoryAtPath:path error:&error]);
	
	CRView *whiteCircle = [circle versionWithColor:white];
	CRView *blackCircle = [circle versionWithColor:black];

	for(int i = 1; i <= count; i++){
		[whiteCircle setState:i withMax:count];
		[blackCircle setState:i withMax:count];

		[self circlet_saveCircle:whiteCircle toPath:path withName:[NSString stringWithFormat:@"%iWhite@2x.png", i]];
		[self circlet_saveCircle:blackCircle toPath:path withName:[NSString stringWithFormat:@"%iBlack@2x.png", i]];
	}

	NSLog(@"[Circlet] Wrote %i circle-views to directory: %@ (errors: %@)", count, [fileManager contentsOfDirectoryAtPath:path error:&error], error);
}

%new -(BOOL)circlet_saveCircle:(CRView *)circle toPath:(NSString *)path withName:(NSString *)name{
	UIGraphicsBeginImageContextWithOptions(circle.bounds.size, NO, 0.0);
    [circle.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    NSLog(@"---- saving png rep of %@ to %@", image, [path stringByAppendingString:name]);
	return [UIImagePNGRepresentation(image) writeToFile:[path stringByAppendingString:name] atomically:YES];
}

%end

/**************************** StatusBar Image Replacment  ****************************/

@interface UIStatusBarSignalStrengthItemView (Circlet)
-(void)circlet_spawnInjectionObjects;
@end

%hook UIStatusBarSignalStrengthItemView
CRNotificationListener *signalListener;
NSMutableArray *signalImages;

-(id)initWithItem:(UIStatusBarItem *)arg1 data:(id)arg2 actions:(int)arg3 style:(id)arg4{
	UIStatusBarSignalStrengthItemView *view = %orig();
	[view circlet_spawnInjectionObjects];
	return view;
}

%new -(void)circlet_spawnInjectionObjects{
	signalListener = [CRNotificationListener sharedListener];

	if([signalListener enabledForClassname:@"UIStatusBarSignalStrengthItemView"]){
		[signalListener debugLog:[NSString stringWithFormat:@"Overriding preferences for classname \"%@\".", NSStringFromClass([self class])]];
		signalImages = [[NSMutableArray alloc] init];
		for(int i = 0; i < 5; i++){
			[signalImages addObject:@[[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@%iWhite@2x.png", CRPathFrom(@"Signal/"), i]], [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@%iBlack@2x.png", CRPathFrom(@"Signal/"), i]]]];
		}
	}
}

-(_UILegibilityImageSet *)contentsImage{
	if([signalListener enabledForClassname:@"UIStatusBarSignalStrengthItemView"]){
		if(!signalImages || signalImages.count < 3)
			[self circlet_spawnInjectionObjects];

		CGFloat w, a;
		[[[self foregroundStyle] textColorForStyle:[self legibilityStyle]] getWhite:&w alpha:&a];
		int bars = MSHookIvar<int>(self, "_signalStrengthBars");

		UIImage *white = (w > 0.5)?[[signalImages objectAtIndex:bars] firstObject]:[[signalImages objectAtIndex:bars] lastObject];
		UIImage *black = (w > 0.5)?[[signalImages objectAtIndex:bars] lastObject]:[[signalImages objectAtIndex:bars] firstObject];

		return [%c(_UILegibilityImageSet) imageFromImage:white withShadowImage:black];
	}

	return %orig();
}

%end

%hook UIStatusBarDataNetworkItemView
CRNotificationListener *wifiListener;
NSMutableArray *wifiImages;

-(id)initWithItem:(UIStatusBarItem *)arg1 data:(id)arg2 actions:(int)arg3 style:(id)arg4{
	wifiListener = [CRNotificationListener sharedListener];
	
	if([wifiListener enabledForClassname:@"UIStatusBarDataNetworkItemView"]){
		[wifiListener debugLog:[NSString stringWithFormat:@"Overriding preferences for classname \"%@\".", NSStringFromClass([%orig() class])]];
		wifiImages = [[NSMutableArray alloc] init];
		for(int i = 1; i <= 3; i++){
			[wifiImages addObject:@[[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@%iWhite@2x.png", CRPathFrom(@"Wifi/"), i]], [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@%iBlack@2x.png", CRPathFrom(@"Wifi/"), i]]]];
		}

		[wifiImages addObject:@[[UIImage imageWithContentsOfFile:CRPathFrom(@"Data/1White@2x.png")], [UIImage imageWithContentsOfFile:CRPathFrom(@"Data/1Black@2x.png")]]];
	}

	return %orig();
}

-(_UILegibilityImageSet *)contentsImage{
	if([wifiListener enabledForClassname:@"UIStatusBarDataNetworkItemView"]){
		CGFloat w, a;
		[[[self foregroundStyle] textColorForStyle:[self legibilityStyle]] getWhite:&w alpha:&a];
		int networkType = MSHookIvar<int>(self, "_dataNetworkType");
		int wifiState = MSHookIvar<int>(self, "_wifiStrengthBars");
		UIImage *white, *black;

		if(networkType == 5){
			white = (w > 0.5)?[[wifiImages objectAtIndex:wifiState] firstObject]:[[wifiImages objectAtIndex:wifiState] lastObject];
			white = (w > 0.5)?[[wifiImages objectAtIndex:wifiState] firstObject]:[[wifiImages objectAtIndex:wifiState] lastObject];
		}
		
		else{
			white = (w > 0.5)?[[wifiImages objectAtIndex:3] firstObject]:[[wifiImages objectAtIndex:3] lastObject];
			black = (w > 0.5)?[[wifiImages objectAtIndex:3] lastObject]:[[wifiImages objectAtIndex:3] firstObject];
		}

		return [%c(_UILegibilityImageSet) imageFromImage:white withShadowImage:black];
	}

	return %orig();
}

%end

%hook UIStatusBarBatteryItemView
CRNotificationListener *batteryListener;
NSMutableArray *batteryImages;

-(id)initWithItem:(UIStatusBarItem *)arg1 data:(id)arg2 actions:(int)arg3 style:(id)arg4{
	batteryListener = [CRNotificationListener sharedListener];

	if([batteryListener enabledForClassname:@"UIStatusBarBatteryItemView"]){
		[batteryListener debugLog:[NSString stringWithFormat:@"Overriding preferences for classname \"%@\".", NSStringFromClass([%orig() class])]];
		batteryImages = [[NSMutableArray alloc] init];
		for(int i = 1; i <= 20; i++){
			[batteryImages addObject:@[[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@%iWhite@2x.png", CRPathFrom(@"Battery/"), i]], [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@%iBlack@2x.png", CRPathFrom(@"Battery/"), i]]]];
		}

		for(int i = 1; i <= 20; i++){
			[batteryImages addObject:@[[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@%iWhite@2x.png", CRPathFrom(@"Charging/"), i]], [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@%iBlack@2x.png", CRPathFrom(@"Charging/"), i]]]];
		}
	}

	return %orig();
}

-(_UILegibilityImageSet *)contentsImage{
	if([batteryListener enabledForClassname:@"UIStatusBarBatteryItemView"]){
		CGFloat w, a;
		[[[self foregroundStyle] textColorForStyle:[self legibilityStyle]] getWhite:&w alpha:&a];
		int level = ceilf((MSHookIvar<int>(self, "_capacity")) * (2.0/10.0));
		int state = MSHookIvar<int>(self, "_state");
		UIImage *white, *black;

		if(state != 0){
			white = (w > 0.5)?[[batteryImages objectAtIndex:(level + 20)] firstObject]:[[batteryImages objectAtIndex:(level + 20)] lastObject];
			black = (w > 0.5)?[[batteryImages objectAtIndex:(level + 20)] lastObject]:[[batteryImages objectAtIndex:(level + 20)] firstObject];
		}

		else{
			white = (w > 0.5)?[[batteryImages objectAtIndex:level] firstObject]:[[batteryImages objectAtIndex:level] lastObject];
			black = (w > 0.5)?[[batteryImages objectAtIndex:level] lastObject]:[[batteryImages objectAtIndex:level] firstObject];
		}
			
		return [%c(_UILegibilityImageSet) imageFromImage:white withShadowImage:black];
	}

	return %orig();
}

%end

/**************************** Item View Spacing  ****************************/

%hook UIStatusBarLayoutManager
CGFloat signalWidth;

-(CGRect)_frameForItemView:(UIStatusBarItemView *)arg1 startPosition:(float)arg2{
	CRNotificationListener *listener = [CRNotificationListener sharedListener];
	NSString *className = NSStringFromClass([arg1 class]);

	if([className isEqualToString:@"UIStatusBarSignalStrengthItemView"])
		signalWidth = %orig().size.width;

	else if([className isEqualToString:@"UIStatusBarServiceItemView"])
		signalWidth += %orig().size.width;

	else if([className isEqualToString:@"UIStatusBarDataNetworkItemView"] && [listener enabledForClassname:className])
		return CGRectMake(signalWidth + (listener.wifiPadding/1.25), %orig().origin.y, %orig().size.width, %orig().size.height);

	else if([className isEqualToString:@"UIStatusBarBatteryItemView"] && [listener enabledForClassname:className]){
		int state = MSHookIvar<int>(arg1, "_state");
		if(state != 0)
			[[[arg1 subviews] lastObject] setHidden:YES];
	}

	return %orig();
}
%end