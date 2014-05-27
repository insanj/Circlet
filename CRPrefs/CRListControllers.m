#import "CRPrefs.h"

@implementation CRSignalPrefsListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		NSString *compatibleName = MODERN_IOS ? @"CRSignalPrefs" : @"CRCSignalPrefs";
		_specifiers = [[self loadSpecifiersFromPlistName:compatibleName target:self] retain];
	}

	return _specifiers;
}

- (void)loadView {
	[super loadView];

	if (![[CRPrefsManager sharedManager] objectForKey:@"signalStyle"]) {
		PSSpecifier *signalStyleSpecifier = [self specifierForID:@"SignalStyle"];
		[self setPreferenceValue:@(1) specifier:signalStyleSpecifier];
		[self reloadSpecifier:signalStyleSpecifier];
	}
}

@end

@implementation CRWifiPrefsListController

- (NSArray *)specifiers{
	if (!_specifiers) {
		NSString *compatibleName = MODERN_IOS ? @"CRWifiPrefs" : @"CRCWifiPrefs";
		_specifiers = [[self loadSpecifiersFromPlistName:compatibleName target:self] retain];
	}

	return _specifiers;
}

- (void)loadView {
	[super loadView];

	if (![[CRPrefsManager sharedManager] objectForKey:@"wifiStyle"]) {
		PSSpecifier *wifiStyleSpecifier = [self specifierForID:@"WifiStyle"];
		[self setPreferenceValue:@(1) specifier:wifiStyleSpecifier];
		[self reloadSpecifier:wifiStyleSpecifier];
	}
}

@end

@implementation CRTimePrefsListController

- (NSArray *)specifiers{
	if (!_specifiers) {
		NSString *compatibleName = MODERN_IOS ? @"CRTimePrefs" : @"CRCTimePrefs";
		_specifiers = [[self loadSpecifiersFromPlistName:compatibleName target:self] retain];
	}

	return _specifiers;
}

- (void)loadView {
	[super loadView];

	if (![[CRPrefsManager sharedManager] objectForKey:@"timeStyle"]) {
		PSSpecifier *timeStyleSpecifier = [self specifierForID:@"TimeStyle"];
		[self setPreferenceValue:@(1) specifier:timeStyleSpecifier];
		[self reloadSpecifier:timeStyleSpecifier];
	}
}

@end

@implementation CRBatteryPrefsListController

- (NSArray *)specifiers{
	if (!_specifiers) {
		NSString *compatibleName = MODERN_IOS ? @"CRBatteryPrefs" : @"CRCBatteryPrefs";
		_specifiers = [[self loadSpecifiersFromPlistName:compatibleName target:self] retain];
	}

	return _specifiers;
}

- (void)loadView {
	[super loadView];
	
	if (![[CRPrefsManager sharedManager] objectForKey:@"batteryStyle"]) {
		PSSpecifier *batteryStyleSpecifier = [self specifierForID:@"BatteryStyle"];
		[self setPreferenceValue:@(1) specifier:batteryStyleSpecifier];
		[self reloadSpecifier:batteryStyleSpecifier];
	}
}

- (NSArray *)chargingColorTitles:(id)target {
	NSMutableArray *titles = [[NSMutableArray alloc] initWithArray:[[_titleToColor allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
	[titles insertObject:@"Custom" atIndex:0];
	[titles removeObject:@"Black (Default)"];
	[titles removeObject:@"Red (Default)"];
	[titles removeObject:@"White (Default)"];
	[titles removeObject:@"Green"];
	return titles;
}

- (NSArray *)chargingColorValues:(id)target {
	return [self chargingColorTitles:target];
}

- (NSArray *)lowPowerColorTitles:(id)target {
	NSMutableArray *titles = [[NSMutableArray alloc] initWithArray:[[_titleToColor allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
	[titles insertObject:@"Custom" atIndex:0];
	[titles removeObject:@"Black (Default)"];
	[titles removeObject:@"Red"];
	[titles removeObject:@"White (Default)"];
	[titles removeObject:@"Green (Default)"];
	return titles;
}

- (NSArray *)lowPowerColorValues:(id)target {
	return [self lowPowerColorTitles:target];
}

@end