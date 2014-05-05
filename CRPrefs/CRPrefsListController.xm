#import "CRPrefs.h"

static void circletDisable(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"CLSmartDisable" object:nil];
}

@implementation CRPrefsListController

- (void)loadView {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &circletDisable, CFSTR("com.insanj.circlet/Disable"), NULL, 0);
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(smartDisable) name:@"CLSmartDisable" object:nil];

	[super loadView];

	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareTapped:)] autorelease];
	[UISwitch appearanceWhenContainedIn:self.class, nil].onTintColor = CRTINTCOLOR;
	[UISegmentedControl appearanceWhenContainedIn:self.class, nil].tintColor = CRTINTCOLOR;
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"CRPrefs" target:self] retain];
	}

	return _specifiers;
}

- (void)viewWillAppear:(BOOL)animated {
	self.view.tintColor = CRTINTCOLOR;
	self.navigationController.navigationBar.tintColor = CRTINTCOLOR;

	[super viewWillAppear:animated];
	[self smartDisable];
}

- (void)smartDisable {
	CRLOG(@"Smart disabling...");
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.insanj.circlet.plist"]];
	NSNumber *signalValue = [settings objectForKey:@"signalEnabled"];
	NSNumber *wifiValue = [settings objectForKey:@"wifiEnabled"];
	NSNumber *batteryValue = [settings objectForKey:@"batteryEnabled"];
	PSSpecifier *signalAdjustmentsSpecifier = [self specifierForID:@"SignalAdjustments"];
	PSSpecifier *wifiAdjustmentsSpecifier = [self specifierForID:@"WifiAdjustments"];
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

- (void)replenish {
	UIStatusBar *statusBar = (UIStatusBar *)[[UIApplication sharedApplication] statusBar];
	UIView *fakeStatusBar = [statusBar snapshotViewAfterScreenUpdates:YES];
	[statusBar.superview addSubview:fakeStatusBar];

	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"CRRefreshStatusBar" object:nil];

	CGRect upwards = statusBar.frame;
	upwards.origin.y -= upwards.size.height;
	statusBar.frame = upwards;

	CGFloat shrinkAmount = 5.0;

	[UIView animateWithDuration:0.6 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void){
		NSLog(@"Animating out...");
		
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

@end
