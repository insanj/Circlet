#import "CRBatteryPrefsListController.h"

@implementation CRBatteryPrefsListController

+ (NSString *)hb_specifierPlist {
	return MODERN_IOS ? @"CRBatteryPrefs" : @"CRCBatteryPrefs";
}

+ (UIColor *)hb_tintColor {
	return [UIColor colorWithRed:52/255.0 green:53/255.0 blue:46/255.0 alpha:1.0];
}

- (void)loadView {
	[super loadView];
	
	HBPreferences *preferences = [[HBPreferences alloc] initWithIdentifier:@"com.insanj.circlet"];
	NSInteger style = [preferences integerForKey:@"batteryStyle" default:-1];

	if (style == -1) {
		PSSpecifier *batteryStyleSpecifier = [self specifierForID:@"BatteryStyle"];
		[self setPreferenceValue:@(1) specifier:batteryStyleSpecifier];
		[self reloadSpecifier:batteryStyleSpecifier];
	}
}

- (NSArray *)chargingColorTitles:(id)target {
	NSMutableArray *titles = [[NSMutableArray alloc] initWithArray:[[CRTITLETOCOLOR allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
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
	NSMutableArray *titles = [[NSMutableArray alloc] initWithArray:[[CRTITLETOCOLOR allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
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
