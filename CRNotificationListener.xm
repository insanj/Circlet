//
//  CRNotificationListener.xm
//  CellCircle
//
//  Created by Julian Weiss on 1/14/14.
//  Copyright (c) 2014 insanj. All rights reserved.
//

#import "CRNotificationListener.h"

@implementation CRNotificationListener
@synthesize signalEnabled, signalPadding;

-(CRNotificationListener *)init{
	if((self = [super init])){
		[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(respring) name:@"CRPrefsChanged" object:nil];
		[self reloadPrefs];
	}

	return self;
}

-(void)respring{
	[(SpringBoard *)[%c(SpringBoard) sharedApplication] _relaunchSpringBoardNow];
}

-(void)reloadPrefs{
	settings = [NSDictionary dictionaryWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.insanj.circular.plist"]];
	[self debugLog:[NSString stringWithFormat:@"Reloading settings, retrieved plist:%@ ", settings]];
	debug = settings[@"debugEnabled"] == nil || [settings[@"debugEnabled"] boolValue];

	signalEnabled = settings[@"signalEnabled"] == nil || [settings[@"signalEnabled"] boolValue];
	signalPadding = (settings[@"signalSize"] == nil)?12.f:[settings[@"signalSize"] floatValue];
}


-(void)debugLog:(NSString*)str{
	if(debug)
		NSLog(@"[Circular] \e[1;31m%@\e[m ", str);
}

-(void)dealloc{
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
}
@end