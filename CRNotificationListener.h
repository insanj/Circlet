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
#import "CRView.h"

@interface CRNotificationListener : NSObject {
	BOOL debug;
}

@property (nonatomic, retain) NSDictionary *settings;
@property (nonatomic, readonly) NSDictionary *images;

@property (nonatomic, readwrite) BOOL signalEnabled, wifiEnabled, batteryEnabled;
@property (nonatomic, readwrite) CGFloat signalPadding, wifiPadding, batteryPadding;
@property (nonatomic, retain) UIColor *signalWhiteColor, *signalBlackColor, *wifiWhiteColor, *wifiBlackColor, *dataWhiteColor, *dataBlackColor, *batteryWhiteColor, *batteryBlackColor, *chargingWhiteColor, *chargingBlackColor;

@property (nonatomic, retain) CRView *signalCircle, *wifiCircle, *batteryCircle;

+(CRNotificationListener *)sharedListener;
-(CRNotificationListener *)init;
-(BOOL)reloadPrefs;
-(void)debugLog:(NSString *)str;
-(BOOL)enabledForClassname:(NSString *)className;

@end

extern NSString *const CRImagesLoadedNotification;