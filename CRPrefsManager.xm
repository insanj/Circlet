#import "CRPrefsManager.h"

@implementation CRPrefsManager

static CRPrefsManager *sharedManager;

+ (instancetype)sharedManager {
	if (!sharedManager) {
		sharedManager = [[self alloc] init];
	}

	return sharedManager;
}

- (instancetype)init {
	self = [super init];

	if (self) {
		_cachedPreferences = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.insanj.circlet.plist"];

		// Maybe shift to kirb's NSUserDefaults solution someday...
		// [[NSUserDefaults standardUserDefaults] boolForKey:@"didRun" inDomain:@"com.insanj.circlet"];
		// [[NSUserDefaults standardUserDefaults] setBool:YES ForKey:@"didRun" inDomain:@"com.insanj.circlet"];

		[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadPreferences) name:@"CRReloadPreferences" object:nil];
	}

	return self;
}

- (void)reloadPreferences {
	[_cachedPreferences release];
	_cachedPreferences = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.insanj.circlet.plist"];
}

- (void)setObject:(NSObject *)object forKey:(NSString *)key {
	NSMutableDictionary *mutablePreferences = [[NSMutableDictionary alloc] initWithDictionary:_cachedPreferences];
	[mutablePreferences setObject:object forKey:key];
	[mutablePreferences writeToFile:@"/var/mobile/Library/Preferences/com.insanj.circlet.plist" atomically:YES];

	_cachedPreferences = mutablePreferences;
}

- (NSObject *)objectForKey:(NSString *)key {
	return _cachedPreferences[key];
}

- (NSNumber *)numberForKey:(NSString *)key {
	return (NSNumber *) _cachedPreferences[key];
}

- (NSString *)stringForKey:(NSString *)key {
	return (NSString *) _cachedPreferences[key];
}

- (CGFloat)floatForKey:(NSString *)key {
	return _cachedPreferences[key] ? [_cachedPreferences[key] floatValue] : 0.0;
}

- (BOOL)boolForKey:(NSString *)key {
	return _cachedPreferences[key] && [_cachedPreferences[key] boolValue];
}

- (void)dealloc {
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self name:@"CRReloadPreferences" object:nil];
	[_cachedPreferences release];
	[super dealloc];
}

@end