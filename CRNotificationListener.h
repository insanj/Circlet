//
//  CRNotificationListener.xm
//  Circlet
//
//  Created by Julian Weiss on 1/14/14.
//  Copyright (c) 2014 insanj. All rights reserved.
//

#import "CRHeaders.h"
#import "CRView.h"

@interface CRNotificationListener : NSObject {
	BOOL debug;
}

@property (nonatomic, retain) NSDictionary *settings;
@property (nonatomic, readwrite) BOOL signalEnabled, wifiEnabled, batteryEnabled;
@property (nonatomic, readwrite) CGFloat signalPadding, wifiPadding, batteryPadding;
@property (nonatomic, retain) UIColor *signalWhiteColor, *signalBlackColor, *wifiWhiteColor, *wifiBlackColor, *dataWhiteColor, *dataBlackColor, *batteryWhiteColor, *batteryBlackColor, *chargingWhiteColor, *chargingBlackColor;

@property (nonatomic, retain) CRView *signalCircle, *wifiCircle, *batteryCircle;

-(CRNotificationListener *)init;
-(BOOL)reloadPrefs;
-(void)debugLog:(NSString *)str;
@end

