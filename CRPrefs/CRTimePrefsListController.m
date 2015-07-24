#import "CRTimePrefsListController.h"

@implementation CRTimePrefsListController

+ (NSString *)hb_specifierPlist {
	return MODERN_IOS ? @"CRTimePrefs" : @"CRCTimePrefs";
}

+ (UIColor *)hb_tintColor {
	return [UIColor colorWithRed:52/255.0 green:53/255.0 blue:46/255.0 alpha:1.0];
}

- (void)loadView {
	[super loadView];

	HBPreferences *preferences = [[HBPreferences alloc] initWithIdentifier:@"com.insanj.circlet"];
	NSInteger style = [preferences integerForKey:@"timeStyle" default:-1];

	if (style == -1) {
		PSSpecifier *timeStyleSpecifier = [self specifierForID:@"TimeStyle"];
		[self setPreferenceValue:@(1) specifier:timeStyleSpecifier];
		[self reloadSpecifier:timeStyleSpecifier];
	}
}

@end