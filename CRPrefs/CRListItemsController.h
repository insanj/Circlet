#import <Preferences/Preferences.h>
#import <UIKit/UIKit.h>
#import <Cephei/prefs/HBListItemsController.h>
#import "../UIImage+Circlet.h"
#import "NKOColorPickerView.h"

@interface CRListItemsController : HBListItemsController <UIAlertViewDelegate, UITextFieldDelegate>

@property (nonatomic, retain) UIAlertView *pickerAlertView;

@end