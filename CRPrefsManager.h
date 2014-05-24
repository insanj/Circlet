#import <UIKit/UIKit.h>
#import <Foundation/NSDistributedNotificationCenter.h>

@interface CRPrefsManager : NSObject

@property(nonatomic, retain) NSDictionary *cachedPreferences;

+ (instancetype)sharedManager;
- (void)reloadPreferences;

- (void)setObject:(NSObject *)object forKey:(NSString *)key;
- (NSObject *)objectForKey:(NSString *)key;
- (NSNumber *)numberForKey:(NSString *)key;
- (NSString *)stringForKey:(NSString *)key;
- (CGFloat)floatForKey:(NSString *)key;
- (BOOL)boolForKey:(NSString *)key;

@end