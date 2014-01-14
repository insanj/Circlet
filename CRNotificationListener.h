//
//  CRNotificationListener.xm
//  CellCircle
//
//  Created by Julian Weiss on 1/14/14.
//  Copyright (c) 2014 insanj. All rights reserved.
//

#import "CRHeaders.h"

@interface CRNotificationListener : NSObject {
	NSDictionary *settings;
	BOOL debug;
}

@property (nonatomic, readwrite) BOOL signalEnabled;
@property (nonatomic, readwrite) CGFloat signalPadding;

-(CRNotificationListener *)init;
-(void)reloadPrefs;
-(void)debugLog:(NSString *)str;
@end

