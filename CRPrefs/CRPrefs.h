#include "../CRHeaders.h"
#include <Preferences/PSListItemsController.h>
#include <Preferences/PSListController.h>
#include <Preferences/PSTableCell.h>
#include <Preferences/PSSegmentTableCell.h>
#include <Preferences/PSTextViewTableCell.h>
#include <UIKit/UIActivityViewController.h>
#include <Twitter/Twitter.h>
#include <notify.h>

#define URL_ENCODE(string) [(NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)(string), NULL, CFSTR(":/=,!$& '()*+;[]@#?"), kCFStringEncodingUTF8) autorelease]
#define CRTINTCOLOR [UIColor colorWithRed:52/255.0 green:53/255.0 blue:46/255.0 alpha:1.0]

@interface CRPrefsListController : PSListController
@end

@interface CRItemPrefsListController : PSListController
@property(nonatomic, retain) NSDictionary *titleToColor;
@end

@interface CRSignalPrefsListController : CRItemPrefsListController
@end

@interface CRWifiPrefsListController : CRItemPrefsListController
@end

@interface CRBatteryPrefsListController : CRItemPrefsListController
@end

@interface CRListItemsController : PSListItemsController
@end

@interface CRCreditsCell : PSTableCell <UITextViewDelegate> {
	UITextView *_plainTextView;
}

@end

@interface CRSegmentTableCell : PSSegmentTableCell
@end

