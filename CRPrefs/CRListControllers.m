#import "CRPrefs.h"

@implementation CRSignalPrefsListController
@synthesize titleToColor;

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
@synthesize titleToColor;

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

@implementation CRBatteryPrefsListController
@synthesize titleToColor;

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
@end