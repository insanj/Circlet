#import "CRPrefs.h"

@implementation CRSignalPrefsListController

- (NSArray *)specifiers{
	if(!_specifiers)
		_specifiers = [[self loadSpecifiersFromPlistName:@"CRSignalPrefs" target:self] retain];

	return _specifiers;
}

- (void)loadView {
	[super loadView];

	NSDictionary *settings = CRSETTINGS;

	if (![settings objectForKey:@"signalStyle"]) {
		PSSpecifier *signalStyleSpecifier = [self specifierForID:@"SignalStyle"];
		[self setPreferenceValue:@(1) specifier:signalStyleSpecifier];
		[self reloadSpecifier:signalStyleSpecifier];
	}

	if (![settings objectForKey:@"signalSize"]) {
		PSSpecifier *signalSizeSpecifier = [self specifierForID:@"SignalSize"];
		[self setPreferenceValue:@(5.0) specifier:signalSizeSpecifier];
		[self reloadSpecifier:signalSizeSpecifier];
	}
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

	NSDictionary *settings = CRSETTINGS;

	if (![settings objectForKey:@"wifiStyle"]) {
		PSSpecifier *wifiStyleSpecifier = [self specifierForID:@"WifiStyle"];
		[self setPreferenceValue:@(1) specifier:wifiStyleSpecifier];
		[self reloadSpecifier:wifiStyleSpecifier];
	}

	if (![settings objectForKey:@"wifiSize"]) {
		PSSpecifier *wifiSizeSpecifier = [self specifierForID:@"WifiSize"];
		[self setPreferenceValue:@(5.0) specifier:wifiSizeSpecifier];
		[self reloadSpecifier:wifiSizeSpecifier];
	}
}

@end

@implementation CRTimePrefsListController

- (NSArray *)specifiers{
	if(!_specifiers)
		_specifiers = [[self loadSpecifiersFromPlistName:@"CRTimePrefs" target:self] retain];

	return _specifiers;
}

- (void)loadView {
	[super loadView];

	NSDictionary *settings = CRSETTINGS;

	if (![settings objectForKey:@"timeStyle"]) {
		PSSpecifier *timeStyleSpecifier = [self specifierForID:@"TimeStyle"];
		[self setPreferenceValue:@(1) specifier:timeStyleSpecifier];
		[self reloadSpecifier:timeStyleSpecifier];
	}

	if (![settings objectForKey:@"timeSize"]) {
		PSSpecifier *timeSizeSpecifier = [self specifierForID:@"TimeSize"];
		[self setPreferenceValue:@(5.0) specifier:timeSizeSpecifier];
		[self reloadSpecifier:timeSizeSpecifier];
	}
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

	NSDictionary *settings = CRSETTINGS;
	
	if (![settings objectForKey:@"batteryStyle"]) {
		PSSpecifier *batteryStyleSpecifier = [self specifierForID:@"BatteryStyle"];
		[self setPreferenceValue:@(1) specifier:batteryStyleSpecifier];
		[self reloadSpecifier:batteryStyleSpecifier];
	}

	if (![settings objectForKey:@"batterySize"]) {
		PSSpecifier *batterySizeSpecifier = [self specifierForID:@"BatterySize"];
		[self setPreferenceValue:@(5.0) specifier:batterySizeSpecifier];
		[self reloadSpecifier:batterySizeSpecifier];
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