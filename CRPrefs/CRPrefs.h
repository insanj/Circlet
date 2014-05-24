#include "../CRHeaders.h"
#import "../UIImage+Circlet.h"
#import "../CRPrefsManager.h"

#include <Preferences/Preferences.h>
#include <UIKit/UIActivityViewController.h>
#include <Twitter/Twitter.h>
#include <notify.h>

#import "UIDiscreteSlider.h"
#import "NKOColorPickerView.h"

#define URL_ENCODE(string) [(NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)(string), NULL, CFSTR(":/=,!$& '()*+;[]@#?"), kCFStringEncodingUTF8) autorelease]
#define CRTINTCOLOR [UIColor colorWithRed:52/255.0 green:53/255.0 blue:46/255.0 alpha:1.0]

@interface CRPrefsListController : PSListController
- (void)pullHeaderPin;
@end

@interface CRItemPrefsListController : PSListController {
	NSDictionary *_titleToColor;
}
@end

@interface CRSignalPrefsListController : CRItemPrefsListController
@end

@interface CRWifiPrefsListController : CRItemPrefsListController
@end

@interface CRTimePrefsListController : CRItemPrefsListController
@end

@interface CRBatteryPrefsListController : CRItemPrefsListController
@end

@interface CRListItemsController : PSListItemsController <UIAlertViewDelegate, UITextFieldDelegate> {
	NSDictionary *_safeTitleToColor;
}

@property(nonatomic, retain) UIAlertView *pickerAlertView;
@end

@interface CRCreditsCell : PSTableCell <UITextViewDelegate> {
	UITextView *_plainTextView;
}

@end

@interface CREditTextCell : PSEditableTableCell
@end

@interface CRSegmentTableCell : PSSegmentTableCell
@end

@interface CRSliderTableCell : PSSliderTableCell
@end
