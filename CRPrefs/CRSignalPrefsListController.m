#import "CRSignalPrefsListController.h"

@implementation CRSignalPrefsListController

+ (NSString *)hb_specifierPlist {
	return MODERN_IOS ? @"CRSignalPrefs" : @"CRCSignalPrefs";
}

+ (UIColor *)hb_tintColor {
	return [UIColor colorWithRed:52/255.0 green:53/255.0 blue:46/255.0 alpha:1.0];
}

- (void)loadView {
	[super loadView];

	HBPreferences *preferences = [[HBPreferences alloc] initWithIdentifier:@"com.insanj.circlet"];
	NSInteger style = [preferences integerForKey:@"signalStyle" default:-1];
	
	if (style == -1) {
		PSSpecifier *signalStyleSpecifier = [self specifierForID:@"SignalStyle"];
		[self setPreferenceValue:@(1) specifier:signalStyleSpecifier];
		[self reloadSpecifier:signalStyleSpecifier];
	}
}

@end