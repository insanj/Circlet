#import "CRWifiPrefsListController.h"

@implementation CRWifiPrefsListController

+ (NSString *)hb_specifierPlist {
	return MODERN_IOS ? @"CRWifiPrefs" : @"CRCWifiPrefs";
}

+ (UIColor *)hb_tintColor {
	return [UIColor colorWithRed:52/255.0 green:53/255.0 blue:46/255.0 alpha:1.0];
}

- (void)loadView {
	[super loadView];

	HBPreferences *preferences = [[HBPreferences alloc] initWithIdentifier:@"com.insanj.circlet"];
	NSInteger style = [preferences integerForKey:@"wifiStyle" default:-1];

	if (style == -1) {
		PSSpecifier *wifiStyleSpecifier = [self specifierForID:@"WifiStyle"];
		[self setPreferenceValue:@(1) specifier:wifiStyleSpecifier];
		[self reloadSpecifier:wifiStyleSpecifier];
	}
}

@end