#import "CRPrefsListController.h"

void circletSidesRefresh(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    CFNotificationCenterPostNotification(center, CFSTR("com.insanj.circlet/ReloadPrefs"), nil, nil, TRUE);
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"CLSmartDisable" object:nil];

	UIStatusBar *statusBar = (UIStatusBar *)[[UIApplication sharedApplication] statusBar];
	UIView *fakeStatusBar;

	if (MODERN_IOS) {
		fakeStatusBar = [statusBar snapshotViewAfterScreenUpdates:YES];
	}

	else {
		UIGraphicsBeginImageContextWithOptions(statusBar.frame.size, NO, [UIScreen mainScreen].scale);
		CGContextRef context = UIGraphicsGetCurrentContext();
		[statusBar.layer renderInContext:context];
		UIImage *statusBarImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		fakeStatusBar = [[UIImageView alloc] initWithImage:statusBarImage];
	}

	CGRect upwards = statusBar.frame;
	upwards.origin.y -= upwards.size.height;

	[statusBar.superview addSubview:fakeStatusBar];
	statusBar.frame = upwards;

	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"CRRefreshStatusBar" object:nil];

	CGFloat shrinkAmount = 5.0;
	[UIView animateWithDuration:0.6 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void){		
		CGRect shrinkFrame = fakeStatusBar.frame;
		shrinkFrame.origin.x += shrinkAmount;
		shrinkFrame.origin.y += shrinkAmount;
		shrinkFrame.size.width -= shrinkAmount;
		shrinkFrame.size.height -= shrinkAmount;
		fakeStatusBar.frame = shrinkFrame;
		fakeStatusBar.alpha = 0.0;
		
		CGRect downwards = statusBar.frame;
		downwards.origin.y += downwards.size.height;
		statusBar.frame = downwards;
	} completion: ^(BOOL finished) {
		[fakeStatusBar removeFromSuperview];
	}];
}

void circletCenterRefresh(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    CFNotificationCenterPostNotification(center, CFSTR("com.insanj.circlet/ReloadPrefs"), nil, nil, TRUE);
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"CLSmartDisable" object:nil];
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"CRRefreshTime" object:nil];
}

@implementation CRPrefsListController

- (void)loadView {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &circletSidesRefresh, CFSTR("com.insanj.circlet/Sides"), NULL, 0);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &circletCenterRefresh, CFSTR("com.insanj.circlet/Center"), NULL, 0);
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(smartDisable) name:@"CLSmartDisable" object:nil];

	[super loadView];
}

+ (NSString *)hb_specifierPlist {
	return IPAD ? @"CRBPrefs" : @"CRPrefs";
}

+ (UIColor *)hb_tintColor {
	return [UIColor colorWithRed:52/255.0 green:53/255.0 blue:46/255.0 alpha:1.0];
}

+ (NSString *)hb_shareText {
	return @"Life has never been simpler than with #Circlet by @insanj.";
}

+ (NSURL *)hb_shareURL {
	return [NSURL URLWithString:@"http://insanj.com/circlet"];
}

- (void)viewDidDisappear:(BOOL)animated {
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pullHeaderPin) object:nil];
	[super viewDidDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
	[self smartDisable];
	[self pullHeaderPin];

	[super viewWillAppear:animated];
}

- (void)pullHeaderPin {
	NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[NSDate date]];
	CGFloat hour = [components hour];
	CGFloat minute = [components minute] / 60.0;
	CGFloat combined = (fmod(hour + minute, 12.0) + 1.0) / 12.0;

	if (!self.navigationItem.titleView) {
		// Randomly pick radial, fill, concentric or their inverses
		NSInteger style = arc4random_uniform(1) + arc4random_uniform(3);

		self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage circletWithColor:[UIColor colorWithRed:52/255.0 green:53/255.0 blue:46/255.0 alpha:1.0] radius:13.0 percentage:combined style:style]];
		self.navigationItem.titleView.tag = style;
	}

	else {
		UIImageView *titleView = (UIImageView *) self.navigationItem.titleView;
		titleView.image = [UIImage circletWithColor:[UIColor colorWithRed:52/255.0 green:53/255.0 blue:46/255.0 alpha:1.0] radius:13.0 percentage:combined style:titleView.tag];
	}
	
	[self performSelector:@selector(pullHeaderPin) withObject:nil afterDelay:(60.0 - [components second])];
}

- (void)smartDisable {
	PSSpecifier *signalAdjustmentsSpecifier = [self specifierForID:@"SignalAdjustments"];
	PSSpecifier *carrierTextSpecifier = [self specifierForID:@"CarrierText"];
	PSSpecifier *wifiAdjustmentsSpecifier = [self specifierForID:@"WifiAdjustments"];
	PSSpecifier *dataAdjustmentsSpecifier = [self specifierForID:@"DataAdjustments"];
	PSSpecifier *timeAdjustmentsSpecifier = [self specifierForID:@"TimeAdjustments"];
	PSSpecifier *batteryAdjustmentsSpecifier = [self specifierForID:@"BatteryAdjustments"];

	HBPreferences *preferences = [[HBPreferences alloc] initWithIdentifier:@"com.insanj.circlet"];

	[signalAdjustmentsSpecifier setProperty:@([preferences boolForKey:@"signalEnabled" default:YES]) forKey:@"enabled"];
	[self reloadSpecifier:signalAdjustmentsSpecifier];

	[carrierTextSpecifier setProperty:@([preferences boolForKey:@"carrierEnabled"]) forKey:@"enabled"];
	[self reloadSpecifier:carrierTextSpecifier];

	[wifiAdjustmentsSpecifier setProperty:@([preferences boolForKey:@"wifiEnabled"]) forKey:@"enabled"];
	[self reloadSpecifier:wifiAdjustmentsSpecifier];
	
	[dataAdjustmentsSpecifier setProperty:@([preferences boolForKey:@"dataEnabled"]) forKey:@"enabled"];
	[self reloadSpecifier:dataAdjustmentsSpecifier];

	[timeAdjustmentsSpecifier setProperty:@([preferences boolForKey:@"timeEnabled"]) forKey:@"enabled"];
	[self reloadSpecifier:timeAdjustmentsSpecifier];

	[batteryAdjustmentsSpecifier setProperty:@([preferences boolForKey:@"batteryEnabled"]) forKey:@"enabled"];
	[self reloadSpecifier:batteryAdjustmentsSpecifier];
}

- (void)tableView:(id)arg1 didSelectRowAtIndexPath:(id)arg2 {
 	[super tableView:arg1 didSelectRowAtIndexPath:arg2];
	[arg1 deselectRowAtIndexPath:arg2 animated:YES];
}

- (void)twitter { 
	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tweetbot:///user_profile/insanj"]];
	}

	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitterrific:///profile?screen_name=insanj"]];
	}

	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tweetings:///user?screen_name=insanj"]];
	}

	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=insanj"]];
	}

	else {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://mobile.twitter.com/insanj"]];
	}
}

- (void)github {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/insanj/circlet"]];
}

- (void)website {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://insanj.com/circlet"]];
}

- (void)dealloc {
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

// iPad seems to obey all laws. -smartDisable doesn't work here, too, for some reason.
- (BOOL)canBeShownFromSuspendedState {
	if (IPAD) {
		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"CLGTFO" object:nil userInfo:@{ @"sender" : NSStringFromClass([UIApplication sharedApplication].class)} ];
	}

	return NO; 
}

@end
