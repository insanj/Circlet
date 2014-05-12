#import "CRPrefs.h"

static void circletDisable(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"CLSmartDisable" object:nil];
}

@implementation CRPrefsListController

- (void)loadView {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &circletDisable, CFSTR("com.insanj.circlet/Disable"), NULL, 0);
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(smartDisable) name:@"CLSmartDisable" object:nil];

	[super loadView];

	[UISwitch appearanceWhenContainedIn:self.class, nil].onTintColor = CRTINTCOLOR;
	[UISegmentedControl appearanceWhenContainedIn:self.class, nil].tintColor = CRTINTCOLOR;
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareTapped:)] autorelease];
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"CRPrefs" target:self] retain];
	}

	return _specifiers;
}

- (void)viewDidDisappear:(BOOL)animated {
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pullHeaderPin) object:nil];
	[super viewDidDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
	self.view.tintColor = CRTINTCOLOR;
	self.navigationController.navigationBar.tintColor = CRTINTCOLOR;
	[self pullHeaderPin];

	[super viewWillAppear:animated];
	[self smartDisable];
}

- (void)pullHeaderPin {
	CRLOG(@"Pulling header pin...");
	NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[NSDate date]];
	CGFloat hour = [components hour];
	CGFloat minute = [components minute] / 60.0;
	CGFloat combined = (fmod(hour + minute, 12.0) + 1.0) / 12.0; // (hour + minute) / 23.0;

	CRLOG(@"Percentage full: %f", combined);

	if (!self.navigationItem.titleView) {
		NSInteger style = arc4random_uniform(5); // Don't really like concentric inverse here
		self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage circletWithColor:CRTINTCOLOR radius:13.0 percentage:combined style:style]];
		self.navigationItem.titleView.tag = style;
	}

	else {
		UIImageView *titleView = (UIImageView *) self.navigationItem.titleView;
		titleView.image = [UIImage circletWithColor:CRTINTCOLOR radius:13.0 percentage:combined style:titleView.tag];
	}
	
	[self performSelector:@selector(pullHeaderPin) withObject:nil afterDelay:(60.0 - [components second])];
}

- (void)smartDisable {
	CRLOG(@"Smart disabling...");
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.insanj.circlet.plist"]];
	NSNumber *signalValue = [settings objectForKey:@"signalEnabled"];
	NSNumber *wifiValue = [settings objectForKey:@"wifiEnabled"];
	NSNumber *timeValue = [settings objectForKey:@"timeEnabled"];
	NSNumber *batteryValue = [settings objectForKey:@"batteryEnabled"];
	PSSpecifier *signalAdjustmentsSpecifier = [self specifierForID:@"SignalAdjustments"];
	PSSpecifier *wifiAdjustmentsSpecifier = [self specifierForID:@"WifiAdjustments"];
	PSSpecifier *timeAdjustmentsSpecifier = [self specifierForID:@"TimeAdjustments"];
	PSSpecifier *batteryAdjustmentsSpecifier = [self specifierForID:@"BatteryAdjustments"];

	if (signalValue && ![signalValue boolValue]) {
		[signalAdjustmentsSpecifier setProperty:@(NO) forKey:@"enabled"];
		[self reloadSpecifier:signalAdjustmentsSpecifier];
	}

	else {
		[signalAdjustmentsSpecifier setProperty:@(YES) forKey:@"enabled"];
		[self reloadSpecifier:signalAdjustmentsSpecifier];
	}

	if (!wifiValue || ![wifiValue boolValue]) {
		[wifiAdjustmentsSpecifier setProperty:@(NO) forKey:@"enabled"];
		[self reloadSpecifier:wifiAdjustmentsSpecifier];
	}

	else {
		[wifiAdjustmentsSpecifier setProperty:@(YES) forKey:@"enabled"];
		[self reloadSpecifier:wifiAdjustmentsSpecifier];
	}

	if (!timeValue || ![timeValue boolValue]) {
		[timeAdjustmentsSpecifier setProperty:@(NO) forKey:@"enabled"];
		[self reloadSpecifier:timeAdjustmentsSpecifier];
	}

	else {
		[timeAdjustmentsSpecifier setProperty:@(YES) forKey:@"enabled"];
		[self reloadSpecifier:timeAdjustmentsSpecifier];
	}

	if (!batteryValue || ![batteryValue boolValue]) {
		[batteryAdjustmentsSpecifier setProperty:@(NO) forKey:@"enabled"];
		[self reloadSpecifier:batteryAdjustmentsSpecifier];
	}

	else {
		[batteryAdjustmentsSpecifier setProperty:@(YES) forKey:@"enabled"];
		[self reloadSpecifier:batteryAdjustmentsSpecifier];
	}

}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	self.view.tintColor = nil;
	self.navigationController.navigationBar.tintColor = nil;
}

- (void)tableView:(id)arg1 didSelectRowAtIndexPath:(id)arg2 {
 	[super tableView:arg1 didSelectRowAtIndexPath:arg2];
	[arg1 deselectRowAtIndexPath:arg2 animated:YES];
}

- (void)shareTapped:(UIBarButtonItem *)sender {
	NSString *text = @"Life has never been simpler than with #Circlet by @insanj.";
	NSURL *url = [NSURL URLWithString:@"http://insanj.com/circlet"];

	if (%c(UIActivityViewController)) {
		UIActivityViewController *viewController = [[[%c(UIActivityViewController) alloc] initWithActivityItems:[NSArray arrayWithObjects:text, url, nil] applicationActivities:nil] autorelease];
		[self.navigationController presentViewController:viewController animated:YES completion:NULL];
	}

	else if (%c(TWTweetComposeViewController) && [TWTweetComposeViewController canSendTweet]) {
		TWTweetComposeViewController *viewController = [[[TWTweetComposeViewController alloc] init] autorelease];
		viewController.initialText = text;
		[viewController addURL:url];
		[self.navigationController presentViewController:viewController animated:YES completion:NULL];
	}

	else {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/intent/tweet?text=%@%%20%@", URL_ENCODE(text), URL_ENCODE(url.absoluteString)]]];
	}
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
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://insanj.com/circlet"]];
}

- (void)dealloc {
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (BOOL)canBeShownFromSuspendedState {
	return NO;
}

@end
