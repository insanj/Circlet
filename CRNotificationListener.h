//
//  CRNotificationListener.xm
//  Circlet
//
//  Created by Julian Weiss on 1/14/14.
//  Copyright (c) 2014 insanj. All rights reserved.
//

#import "CRHeaders.h"

@interface CRNotificationListener : NSObject {
	BOOL debug;
}

@property (nonatomic, retain) NSDictionary *settings;
@property (nonatomic, readwrite) BOOL signalEnabled, wifiEnabled;
@property (nonatomic, readwrite) CGFloat signalPadding, wifiPadding;
@property (nonatomic, retain) UIColor *signalWhiteColor, *signalBlackColor, *wifiWhiteColor, *wifiBlackColor, *dataWhiteColor, *dataBlackColor;

-(CRNotificationListener *)init;
-(BOOL)reloadPrefs;
-(void)debugLog:(NSString *)str;
@end

