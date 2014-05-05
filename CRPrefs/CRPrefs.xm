#import "CRPrefs.h"

#define URL_ENCODE(string) [(NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)(string), NULL, CFSTR(":/=,!$& '()*+;[]@#?"), kCFStringEncodingUTF8) autorelease]
#define CRTINTCOLOR [UIColor colorWithRed:52/255.0 green:53/255.0 blue:46/255.0 alpha:1.0]

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

	// This is here to check for first-run (never set) specifiers.
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.insanj.circlet.plist"]];

	if (![settings objectForKey:@"signalStyle"]) {
		PSSpecifier *signalStyleSpecifier = [self specifierForID:@"SignalStyle"];
		[self setPreferenceValue:@(1) specifier:signalStyleSpecifier];
		[self reloadSpecifier:signalStyleSpecifier];
	}

	if (![settings objectForKey:@"wifiStyle"]) {
		PSSpecifier *wifiStyleSpecifier = [self specifierForID:@"WifiStyle"];
		[self setPreferenceValue:@(1) specifier:wifiStyleSpecifier];
		[self reloadSpecifier:wifiStyleSpecifier];
	}

	if (![settings objectForKey:@"batteryStyle"]) {
		PSSpecifier *batteryStyleSpecifier = [self specifierForID:@"BatteryStyle"];
		[self setPreferenceValue:@(1) specifier:batteryStyleSpecifier];
		[self reloadSpecifier:batteryStyleSpecifier];
	}

	if (![settings objectForKey:@"signalSize"]) {
		PSSpecifier *signalSizeSpecifier = [self specifierForID:@"SignalSize"];
		[self setPreferenceValue:@(5.0) specifier:signalSizeSpecifier];
		[self reloadSpecifier:signalSizeSpecifier];
	}

	if (![settings objectForKey:@"wifiSize"]) {
		PSSpecifier *wifiSizeSpecifier = [self specifierForID:@"WifiSize"];
		[self setPreferenceValue:@(5.0) specifier:wifiSizeSpecifier];
		[self reloadSpecifier:wifiSizeSpecifier];
	}

	if (![settings objectForKey:@"batterySize"]) {
		PSSpecifier *batterySizeSpecifier = [self specifierForID:@"BatterySize"];
		[self setPreferenceValue:@(5.0) specifier:batterySizeSpecifier];
		[self reloadSpecifier:batterySizeSpecifier];
	}

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

- (void)dealloc {
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

@end

@implementation CRSignalPrefsListController

- (NSArray *)specifiers{
	if(!_specifiers)
		_specifiers = [[self loadSpecifiersFromPlistName:@"CRSignalPrefs" target:self] retain];

	return _specifiers;
}

- (void)loadView {
	[super loadView];

	[UISwitch appearanceWhenContainedIn:self.class, nil].onTintColor = CRTINTCOLOR;
	[UISegmentedControl appearanceWhenContainedIn:self.class, nil].tintColor = CRTINTCOLOR;
}

- (void)viewWillAppear:(BOOL)animated {
	self.view.tintColor = CRTINTCOLOR;
	self.navigationController.navigationBar.tintColor = CRTINTCOLOR;
}

- (void)tableView:(id)arg1 didSelectRowAtIndexPath:(id)arg2 {
	[super tableView:arg1 didSelectRowAtIndexPath:arg2];
	[arg1 deselectRowAtIndexPath:arg2 animated:YES];
}

@end

@implementation CRWifiPrefsListController

- (NSArray *)specifiers{
	if(!_specifiers)
		_specifiers = [[self loadSpecifiersFromPlistName:@"CRWifiPrefs" target:self] retain];

	return _specifiers;
}

- (void)loadView {
	[super loadView];

	[UISwitch appearanceWhenContainedIn:self.class, nil].onTintColor = CRTINTCOLOR;
	[UISegmentedControl appearanceWhenContainedIn:self.class, nil].tintColor = CRTINTCOLOR;
}

- (void)viewWillAppear:(BOOL)animated {
	self.view.tintColor = CRTINTCOLOR;
	self.navigationController.navigationBar.tintColor = CRTINTCOLOR;
}

- (void)tableView:(id)arg1 didSelectRowAtIndexPath:(id)arg2 {
	[super tableView:arg1 didSelectRowAtIndexPath:arg2];
	[arg1 deselectRowAtIndexPath:arg2 animated:YES];
}

@end

@implementation CRBatteryPrefsListController

- (NSArray *)specifiers{
	if(!_specifiers)
		_specifiers = [[self loadSpecifiersFromPlistName:@"CRBatteryPrefs" target:self] retain];

	return _specifiers;
}

- (void)loadView {
	[super loadView];

	[UISwitch appearanceWhenContainedIn:self.class, nil].onTintColor = CRTINTCOLOR;
	[UISegmentedControl appearanceWhenContainedIn:self.class, nil].tintColor = CRTINTCOLOR;
}

- (void)viewWillAppear:(BOOL)animated {
	self.view.tintColor = CRTINTCOLOR;
	self.navigationController.navigationBar.tintColor = CRTINTCOLOR;
}

- (void)tableView:(id)arg1 didSelectRowAtIndexPath:(id)arg2 {
	[super tableView:arg1 didSelectRowAtIndexPath:arg2];
	[arg1 deselectRowAtIndexPath:arg2 animated:YES];
}

@end

@implementation CRListItemsController

- (void)viewWillAppear:(BOOL)animated {
	self.view.tintColor = CRTINTCOLOR;
    self.navigationController.navigationBar.tintColor = CRTINTCOLOR;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	self.view.tintColor = nil;
	self.navigationController.navigationBar.tintColor = nil;
}

- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2 {
	PSTableCell *cell = [super tableView:arg1 cellForRowAtIndexPath:arg2];

	NSDictionary *labelToColor =  @{@"Aqua"			  : UIColorFromRGB(0x7FDBFF),
									@"Black"   		  : UIColorFromRGB(0x111111),
									@"Black (Default)"   : UIColorFromRGB(0x111111),
									@"Blue"		  	: UIColorFromRGB(0x0074D9),
									@"Clear"   		  : [UIColor clearColor],
									@"Fuchsia" 		  : UIColorFromRGB(0xF012BE),
									@"Grey"			  : UIColorFromRGB(0xAAAAAA),
									@"Green"   		  : UIColorFromRGB(0x2ECC40),
									@"Lime"			  : UIColorFromRGB(0x01FF70),
									@"Maroon"  		  : UIColorFromRGB(0x85144B),
									@"Navy"			  : UIColorFromRGB(0x001F3F),
									@"Olive"   		  : UIColorFromRGB(0x3D9970),
									@"Orange" 		   : UIColorFromRGB(0xFF851B),
									@"Purple"  	  	: UIColorFromRGB(0xB10DC9),
									@"Red"			   : UIColorFromRGB(0xFF4136),
									@"Silver" 		   : UIColorFromRGB(0xDDDDDD),
									@"Teal"		  	: UIColorFromRGB(0x39CCCC),
									@"White (Default)"   : UIColorFromRGB(0xFFFFFF),
									@"Yellow" 		   : UIColorFromRGB(0xFFDC00) };

	UIView *colorThumb = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 20.0, 20.0)];
	colorThumb.backgroundColor = [labelToColor objectForKey:[[cell titleLabel] text]];
	colorThumb.layer.masksToBounds = YES;
	colorThumb.layer.cornerRadius = 10.0;
	colorThumb.layer.borderColor = [UIColor lightGrayColor].CGColor;
	colorThumb.layer.borderWidth = 1.0;

	UIGraphicsBeginImageContextWithOptions(colorThumb.bounds.size, NO, 0.0);
	[colorThumb.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	[colorThumb release];
	[cell.imageView setImage:image];
	return cell;
}

@end

@implementation CRCreditsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) {
		_plainTextView = [[UITextView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 88.0)];
		self.clipsToBounds = _plainTextView.clipsToBounds = NO;
		_plainTextView.backgroundColor = [UIColor clearColor];
		_plainTextView.userInteractionEnabled = YES;
		_plainTextView.scrollEnabled = NO;
		_plainTextView.editable = NO;
		_plainTextView.delegate = self;
	
		NSMutableAttributedString *clickable = [[[NSMutableAttributedString alloc] initWithString:@"Circlet (1.0) was created by Julian Weiss with lots of love from Benno, A³Tweaks, and the entire Hashbang crew. Inspired by the awesome members of /r/jailbreak. To stay updated on Circlet (and many other projects), make sure to follow me on Twitter. Enjoy!" attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:[UIFont smallSystemFontSize]]}] autorelease];
		[clickable setAttributes:@{ NSLinkAttributeName : [NSURL URLWithString:@"http://insanj.com/"]} range:[clickable.string rangeOfString:@"Julian Weiss"]];
		[clickable setAttributes:@{ NSLinkAttributeName : [NSURL URLWithString:@"http://bensge.com/"]} range:[clickable.string rangeOfString:@"Benno"]];
		[clickable setAttributes:@{ NSLinkAttributeName : [NSURL URLWithString:@"http://www.a3tweaks.com/"]} range:[clickable.string rangeOfString:@"A³Tweaks"]];
		[clickable setAttributes:@{ NSLinkAttributeName : [NSURL URLWithString:@"http://hbang.ws/"]} range:[clickable.string rangeOfString:@"Hashbang Crew"]];
		[clickable setAttributes:@{ NSLinkAttributeName : [NSURL URLWithString:@"http://reddit.com/r/jailbreak"]} range:[clickable.string rangeOfString:@"/r/jailbreak"]];
		[clickable setAttributes:@{ NSLinkAttributeName : [NSURL URLWithString:@"http://twitter.com/insanj"]} range:[clickable.string rangeOfString:@"on Twitter"]];
	
		_plainTextView.dataDetectorTypes = UIDataDetectorTypeLink;
		_plainTextView.linkTextAttributes = @{ NSForegroundColorAttributeName : [UIColor colorWithRed:68/255.0 green:132/255.0 blue:231/255.0 alpha:1.0] };
		_plainTextView.attributedText = clickable;

		[self addSubview:_plainTextView];
	}

	return self;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
	return YES;
}

- (void)dealloc {
	_plainTextView = nil;
	[_plainTextView release];

	[super dealloc];
}

@end

@implementation CRSegmentTableCell

- (void)layoutSubviews {
	[super layoutSubviews];

	// Break the deadlock
	self.control.frame = CGRectInset(self.control.frame, 8.0, 0.0);
	// self.control.center = CGPointMake(self.control.center.x, self.center.y / 2.0);
}

- (void)setSeparatorStyle:(int)style {
	[super setSeparatorStyle:1];
}

@end

