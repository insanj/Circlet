//
//  CRNotificationListener.h
//  Circlet
//
//  Created by Julian Weiss on 1/14/14.
//  Copyright (c) 2014 insanj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import "CRHeaders.h"

@interface CRNotificationListener : NSObject {
	BOOL debug;
}

@property (nonatomic, retain) NSDictionary *settings;
@property (nonatomic, readonly) NSDictionary *images;

@property (nonatomic, readwrite) BOOL signalEnabled, wifiEnabled, batteryEnabled;
@property (nonatomic, readwrite) CGFloat signalRadius, wifiRadius, batteryRadius;
@property (nonatomic, retain) UIColor *signalWhiteColor, *signalBlackColor, *wifiWhiteColor, *wifiBlackColor, *dataWhiteColor, *dataBlackColor, *batteryWhiteColor, *batteryBlackColor, *chargingWhiteColor, *chargingBlackColor;

+(CRNotificationListener *)sharedListener;
-(CRNotificationListener *)init;
-(BOOL)reloadPrefs;
-(void)debugLog:(NSString *)str;
-(BOOL)enabledForClassname:(NSString *)className;

@end