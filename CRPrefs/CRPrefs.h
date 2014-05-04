#include "../CRHeaders.h"
#include <Preferences/PSListItemsController.h>
#include <Preferences/PSListController.h>
#include <Preferences/PSTableCell.h>
#include <Preferences/PSSegmentTableCell.h>
#include <Preferences/PSTextViewTableCell.h>
#include <UIKit/UIActivityViewController.h>
#include <UIKit/UITextContentViewDelegate.h>
#include <Twitter/Twitter.h>
#include <notify.h>

@interface CRPrefsListController : PSListController
@end

@interface CRSignalPrefsListController : PSListController
@end

@interface CRWifiPrefsListController : PSListController
@end

@interface CRBatteryPrefsListController : PSListController
@end

@interface CRListItemsController : PSListItemsController
@end

@interface CRCreditsCell : PSTextViewTableCell <UITextContentViewDelegate>
@end

@interface CRSegmentTableCell : PSSegmentTableCell
@end

