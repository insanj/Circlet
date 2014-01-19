//
//  CRNotificationListener.xm
//  Circlet
//
//  Created by Julian Weiss on 1/14/14.
//  Copyright (c) 2014 insanj. All rights reserved.
//

#import "CRNotificationListener.h"


NSString *const CRImagesLoadedNotification = @"CRImagesLoadedNotification";

enum{
	CRMessageIdGetSignalImage,
	CRMessageIdGetDataImage,
	CRMessageIdGetBatteryImage
};

static LMConnection connection = {
	MACH_PORT_NULL,
	"circlet.datasource"
};

__attribute__((visibility("hidden")))
@interface CRNotificationListenerImpl : CRNotificationListener
@end

static CRNotificationListener *sharedListener;
static NSArray *colors = @[UIColorFromRGB(0x7FDBFF),   UIColorFromRGB(0x111111), UIColorFromRGB(0x0074D9),
			 	   [UIColor clearColor],	    UIColorFromRGB(0xF012BE), UIColorFromRGB(0xAAAAAA),
			 	   UIColorFromRGB(0x2ECC40),    UIColorFromRGB(0x01FF70), UIColorFromRGB(0x85144B),
				   UIColorFromRGB(0x001F3F),    UIColorFromRGB(0x3D9970), UIColorFromRGB(0xFF851B),
		     	   UIColorFromRGB(0xB10DC9),    UIColorFromRGB(0xFF4136), UIColorFromRGB(0xDDDDDD),
		     	   UIColorFromRGB(0x39CCCC),    UIColorFromRGB(0xFFFFFF), UIColorFromRGB(0xFFDC00)];

@implementation CRNotificationListener

+(void)initialize{
	sharedListener = [[self alloc] init];
}

+(CRNotificationListener *)sharedListener{
	return sharedListener;
}

-(CRNotificationListener *)init{
	if(sharedListener)
		return sharedListener;

	else if((self = [super init])){
		[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(respring) name:@"CRPrefsChanged" object:nil];
		[self reloadPrefs];
		_signalCircle = [[CRView alloc] initWithRadius:_signalPadding];
		_wifiCircle = [[CRView alloc] initWithRadius:_wifiPadding];
		_batteryCircle = [[CRView alloc] initWithRadius:_batteryPadding];
		sharedInstance = self;
	}

	return self;
}

-(void)respring{
	[(SpringBoard *)[%c(SpringBoard) sharedApplication] _relaunchSpringBoardNow];
}

-(BOOL)reloadPrefs{
	_settings = [NSDictionary dictionaryWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.insanj.circlet.plist"]];
	debug = _settings[@"debugEnabled"] != nil && [_settings[@"debugEnabled"] boolValue];
	[self debugLog:[NSString stringWithFormat:@"Reloading _settings, retrieved plist:%@ ", _settings]];

	// Signal
	_signalEnabled = _settings[@"signalEnabled"] == nil || [_settings[@"signalEnabled"] boolValue];
	_signalPadding = (_settings[@"signalSize"] == nil)?12.f:[_settings[@"signalSize"] floatValue];

	_signalWhiteColor = [self colorWithCaseNumber:[_settings[@"signalLightColor"] intValue] andDefault:16];
	_signalBlackColor = [self colorWithCaseNumber:[_settings[@"signalDarkColor"] intValue] andDefault:1];
	
	// Data/Wifi
	_wifiEnabled = _settings[@"wifiEnabled"] != nil && [_settings[@"wifiEnabled"] boolValue];
	_wifiPadding = (_settings[@"wifiSize"] == nil)?12.f:[_settings[@"wifiSize"] floatValue];

	_wifiWhiteColor = [self colorWithCaseNumber:[_settings[@"wifiLightColor"] intValue] andDefault:16];
	_wifiBlackColor = [self colorWithCaseNumber:[_settings[@"wifiDarkColor"] intValue] andDefault:1];
	_dataWhiteColor = [self colorWithCaseNumber:[_settings[@"dataLightColor"] intValue] andDefault:16];
	_dataBlackColor = [self colorWithCaseNumber:[_settings[@"dataDarkColor"] intValue] andDefault:1];

	// Battery
	_batteryEnabled = _settings[@"batteryEnabled"] != nil && [_settings[@"batteryEnabled"] boolValue];
	_batteryPadding = (_settings[@"batterySize"] == nil)?12.f:[_settings[@"batterySize"] floatValue];

	_batteryWhiteColor = [self colorWithCaseNumber:[_settings[@"batteryLightColor"] intValue] andDefault:16];
	_batteryBlackColor = [self colorWithCaseNumber:[_settings[@"batteryDarkColor"] intValue] andDefault:1];
	_chargingWhiteColor = [self colorWithCaseNumber:[_settings[@"chargingLightColor"] intValue] andDefault:16];
	_chargingBlackColor = [self colorWithCaseNumber:[_settings[@"chargingDarkColor"] intValue] andDefault:1];


	return _settings != nil;
}

-(UIColor *)colorWithCaseNumber:(int)arg1 andDefault:(int)arg2{
	return [colors objectAtIndex:(arg1==0)?arg2:(arg1-1)];
}

-(UIImage *)imageFromCircle:(CRView *)circle{
    UIGraphicsBeginImageContextWithOptions(circle.bounds.size, NO, 0.f);
    [circle.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(_UILegibilityImageSet *)signalImageForItemView:(UIStatusBarSignalStrengthItemView *)view andOriginal:(_UILegibilityImageSet *)original{
	[self debugLog:[NSString stringWithFormat:@"Generating signal image from shared notification listener: %@", self]];

    CGFloat radius = ([original image].size.height - _signalPadding) / 2.0;
	if(_signalCircle.radius != radius)
		[_signalCircle setRadius:radius];

	CGFloat signalState = MSHookIvar<int>(view, "_signalStrengthBars");
	[self debugLog:[NSString stringWithFormat:@"SignalStrength Bars:%f", signalState]];
	[_signalCircle setState:signalState withMax:5.0];

	UIImage *image = [self imageFromCircle:[_signalCircle versionWithColor:_signalWhiteColor]];
	UIImage *shadow = [self imageFromCircle:[_signalCircle versionWithColor:_signalBlackColor]];

	[listener debugLog:[NSString stringWithFormat:@"Created Signal Circle view with radius:%f, state:%f, lightColor:%@, and darkColor:%@", radius, signalState, image, shadow]];
                                
	LMResponseBuffer buffer;
	result = [LMResponseConsumeImage(&buffer) CGImage];

    return CGImageRetain(result);
}


-(void)debugLog:(NSString*)str{
	if(debug)
		NSLog(@"[Circlet] \e[1;31m%@\e[m ", str);
}

-(BOOL)enabledForClassname:(NSString *)className{
	return ([className isEqualToString:@"UIStatusBarSignalStrengthItemView"] && _signalEnabled) || ([className isEqualToString:@"UIStatusBarDataNetworkItemView"] && _wifiEnabled) || ([className isEqualToString:@"UIStatusBarBatteryItemView"] && _batteryEnabled);
}

-(void)dealloc{
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
}
@end