#include "../CRHeaders.h"
#include <libhbangcommon/prefs/HBRootListController.h>
#import <MessageUI/MessageUI.h>
#include <notify.h>

#define CRTINTCOLOR [UIColor colorWithWhite:0.1 alpha:1.0]

// TODO: add some hack for this in libhbangprefs
@interface CRListItemsController : PSListItemsController
@end

@implementation CRListItemsController

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.tintColor = CRTINTCOLOR;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	self.navigationController.navigationBar.tintColor = nil;
}

@end

@interface CRPrefsListController : HBRootListController
@end

@implementation CRPrefsListController

+ (UIColor *)hb_tintColor {
	return CRTINTCOLOR;
}

+ (NSString *)hb_shareText {
	return @"Life has never been simpler than with #Circlet by @insanj.";
}

+ (NSURL *)hb_shareURL {
	return [NSURL URLWithString:@"http://insanj.com/circlet"];
}

- (instancetype)init {
	self = [super init];

	if (self) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"CRPrefs" target:self] retain];
	}

	return self;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	// This is here to check for first-run (never set) specifiers.
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.insanj.circlet.plist"]];

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
}

- (void)respring {
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"CRPromptRespring" object:nil];
}

- (void)twitter{
	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]])
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tweetbot:///user_profile/insanj"]];

	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]])
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitterrific:///profile?screen_name=insanj"]];

	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings:"]])
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tweetings:///user?screen_name=insanj"]];

	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]])
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=insanj"]];

	else
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://mobile.twitter.com/insanj"]];
}

@end

@interface CRCreditsCell : PSTableCell
@end

@implementation CRCreditsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) {
		self.textLabel.numberOfLines = 0;
	    self.textLabel.font = [UIFont systemFontOfSize:14.0];
	    self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
	}

	return self;
}

@end
