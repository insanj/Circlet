#import "CRHeaders.h"

#ifdef DEBUG
    #define CRLOG(fmt, ...) NSLog((@"[Circlet] %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
    #define CRLOG(fmt, ...) 
#endif

#define CRTITLETOCOLOR @{@"Aqua" : [UIColor colorWithRed:127.0/255.0 green:219.0/255.0 blue:255/255.0 alpha:1.0], @"Black" : [UIColor colorWithRed:17.0/255.0 green:17.0/255.0 blue:17.0/255.0 alpha:1.0], @"Black (Default)" : [UIColor colorWithRed:17.0/255.0 green:17.0/255.0 blue:17.0/255.0 alpha:1.0], @"Blue" : [UIColor colorWithRed:0.0/255.0 green:116.0/255.0 blue:217.0/255.0 alpha:1.0], @"Clear" : [UIColor clearColor], @"Fuchsia" : [UIColor colorWithRed:240.0/255.0 green:18.0/255.0 blue:190.0/255.0 alpha:1.0], @"Grey" : [UIColor colorWithRed:170.0/255.0 green:170.0/255.0 blue:170.0/255.0 alpha:1.0], @"Green" : [UIColor colorWithRed:46.0/255.0 green:204.0/255.0 blue:64.0/255.0 alpha:1.0], @"Green (Default)" : [UIColor colorWithRed:46.0/255.0 green:204.0/255.0 blue:64.0/255.0 alpha:1.0], @"Lime" : [UIColor colorWithRed:1.0/255.0 green:255.0/255.0 blue:112.0/255.0 alpha:1.0], @"Maroon" : [UIColor colorWithRed:133.0/255.0 green:20.0/255.0 blue:75.0/255.0 alpha:1.0], @"Navy" : [UIColor colorWithRed:0.0 green:31.0/255.0 blue:63.0/255.0 alpha:1.0], @"Olive" : [UIColor colorWithRed:61.0/255.0 green:153.0/255.0 blue:112.0/255.0 alpha:1.0], @"Orange" : [UIColor colorWithRed:255.0/255.0 green:133.0/255.0 blue:27.0/255.0 alpha:1.0], @"Purple" : [UIColor colorWithRed:177.0/255.0 green:13.0/255.0 blue:201.0/255.0 alpha:1.0], @"Red" : [UIColor colorWithRed:255.0/255.0 green:65.0/255.0 blue:54.0/255.0 alpha:1.0], @"Red (Default)" : [UIColor colorWithRed:255.0/255.0 green:65.0/255.0 blue:54.0/255.0 alpha:1.0], @"Silver" : [UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0], @"Teal" : [UIColor colorWithRed:57.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0], @"White" : [UIColor whiteColor], @"White (Default)" : [UIColor whiteColor], @"Yellow" : [UIColor colorWithRed:255.0/255.0 green:220.0/255.0 blue:0.0 alpha:1.0]}
#define WIFI_CONNECTED [[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] == ReachableViaWiFi

#define NEWEST_IOS ([[[UIDevice currentDevice] systemVersion] compare:@"7.1" options:NSNumericSearch] == NSOrderedDescending)
#define MODERN_IOS ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] == NSOrderedDescending)

#define IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

// Tiny algorithm to cheat the Textual style of some of its overbearing outline thickness
#define LESSENED_THICKNESS(sty) ((sty == CircletStyleTextual || sty == CircletStyleTextualInverse) ? 1.0 / 8.0 : 0.0);

#define CRDEFAULTRADIUS 5.0
#define CRBOLTLEEWAY 7.0

#import <Cephei/HBPreferences.h>

typedef NS_ENUM(NSUInteger, CircletPosition) {
    CircletPositionSignal = 0,
    CircletPositionWifi,
    CircletPositionData,
    CircletPositionTimeMinute,
    CircletPositionTimeHour,
    CircletPositionBattery,
    CircletPositionCharging,
    CircletPositionLowBattery,
};

@interface UIStatusBarItemView (Circlet)

- (UIImage *)circletContentsImageForWhite:(BOOL)white;
- (UIImage *)circletContentsImageForWhite:(BOOL)white string:(NSString *)timeString;

@end

@interface CRAlertViewDelegate : NSObject <UIAlertViewDelegate>

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

