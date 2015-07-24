#import "CRDataPrefsListController.h"

@implementation CRDataPrefsListController

- (NSArray *)specifiers{
	if (!_specifiers) {
		NSString *compatibleName = MODERN_IOS ? @"CRDataPrefs" : @"CRCDataPrefs";
		_specifiers = [[self loadSpecifiersFromPlistName:compatibleName target:self] retain];
	}

	return _specifiers;
}

- (void)loadView {
	[super loadView];

	HBPreferences *preferences = [[HBPreferences alloc] initWithIdentifier:@"com.insanj.circlet"];
	NSInteger style = [preferences integerForKey:@"dataStyle" default:-1];

	if (style == -1) {
		PSSpecifier *dataStyleSpecifier = [self specifierForID:@"DataStyle"];
		[self setPreferenceValue:@(1) specifier:dataStyleSpecifier];
		[self reloadSpecifier:dataStyleSpecifier];
	}
}

@end
