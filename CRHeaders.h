#include <stdlib.h>
#include <objc/runtime.h>
#include <QuartzCore/QuartzCore.h>
#include <UIKit/UIKit.h>
#include <Foundation/NSDistributedNotificationCenter.h>
#import "substrate.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#ifdef DEBUG
	#define CRLOG(fmt, ...) NSLog((@"[Circlet] %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
	#define CRLOG(fmt, ...) 
#endif

@interface SBUIController
-(void)_deviceLockStateChanged:(NSNotification *)changed;
@end

@interface SBUIAnimationController
-(void)endAnimation;
@end

@interface SpringBoard
-(void)_relaunchSpringBoardNow;
-(void)applicationOpenURL:(id)url publicURLsOnly:(BOOL)only;
-(void)_applicationOpenURL:(NSURL *)url withApplication:(id)application sender:(id)sender publicURLsOnly:(BOOL)publicOnly animating:(BOOL)animating additionalActivationFlags:(id)activationFlags activationHandler:(id)activationHandler;
-(void)applicationOpenURL:(id)url withApplication:(id)application sender:(id)sender publicURLsOnly:(BOOL)only animating:(BOOL)animating needsPermission:(BOOL)permission additionalActivationFlags:(id)flags activationHandler:(id)handler;
@end

struct _rawData {
	BOOL itemIsEnabled[25];
	BOOL timeString[64];
	int gsmSignalStrengthRaw;
	int gsmSignalStrengthBars;
	BOOL serviceString[100];
	BOOL serviceCrossfadeString[100];
	BOOL serviceImages[2][100];
	BOOL operatorDirectory[1024];
	unsigned int serviceContentType;
	int wifiSignalStrengthRaw;
	int wifiSignalStrengthBars;
	unsigned int dataNetworkType;
	int batteryCapacity;
	unsigned int batteryState;
	BOOL batteryDetailString[150];
	int bluetoothBatteryCapacity;
	int thermalColor;
	unsigned int thermalSunlightMode : 1;
	unsigned int slowActivity : 1;
	unsigned int syncActivity : 1;
	BOOL activityDisplayId[256];
	unsigned int bluetoothConnected : 1;
	unsigned int displayRawGSMSignal : 1;
	unsigned int displayRawWifiSignal : 1;
	unsigned int locationIconType : 1;
	unsigned int quietModeInactive : 1;
	unsigned int tetheringConnectionCount;
};

@interface UIStatusBarComposedData : NSObject
-(void *)rawData; //Fuck da police, ily casting
@end


@interface _UILegibilityImageSet : NSObject
@property(retain) UIImage *image;
@property(retain) UIImage *shadowImage;

+(id)imageFromImage:(UIImage *)arg1 withShadowImage:(UIImage *)arg2;

-(void)setImage:(UIImage *)arg1;
-(UIImage *)image;
-(id)initWithImage:(UIImage *)arg1 shadowImage:(UIImage *)arg2;
-(void)setShadowImage:(UIImage *)arg1;
-(UIImage *)shadowImage;
@end

@interface UIStatusBarItem : NSObject
@property(readonly) int type;
@property(readonly) Class viewClass;
@property(readonly) int priority;
@property(readonly) int leftOrder;
@property(readonly) int rightOrder;
@property(readonly) NSString *indicatorName;

+(BOOL)isItemWithTypeExclusive:(int)arg1;
+(BOOL)itemType:(int)arg1 idiom:(int)arg2 appearsInRegion:(int)arg3;
+(BOOL)itemType:(int)arg1 idiom:(int)arg2 canBeEnabledForData:(id)arg3 style:(id)arg4;
+(BOOL)typeIsValid:(int)arg1;
+(id)itemWithType:(int)arg1 idiom:(int)arg2;

-(id)initWithType:(int)arg1;
-(int)compareRightOrder:(id)arg1;
-(int)compareLeftOrder:(id)arg1;
-(Class)viewClass;
-(int)rightOrder;
-(int)leftOrder;
-(NSString *)indicatorName;
-(int)comparePriority:(id)arg1;
-(BOOL)appearsInRegion:(int)arg1;
-(BOOL)appearsOnRight;
-(BOOL)appearsOnLeft;
-(int)priority;
-(int)type;
@end

@interface UIStatusBarItemView : UIView
+(id)createViewForItem:(UIStatusBarItem *)arg1 withData:(id)arg2 actions:(int)arg3 foregroundStyle:(id)arg4;

-(BOOL)isVisible;
-(int)textStyle;
-(void)setLayoutManager:(id)arg1; // UIStatusBarLayoutManager *
-(id)layoutManager;
-(void)beginDisablingRasterization;
-(id)imageWithText:(id)arg1;
-(void)performPendedActions;
-(BOOL)animatesDataChange;
-(float)maximumOverlap;
-(float)addContentOverlap:(float)arg1;
-(float)resetContentOverlap;
-(float)extraRightPadding;
-(float)extraLeftPadding;
-(id)textFont;
-(void)drawText:(id)arg1 forWidth:(float)arg2 lineBreakMode:(int)arg3 letterSpacing:(float)arg4 textSize:(CGSize)arg5;
-(float)setStatusBarData:(id)arg1 actions:(int)arg2;
-(float)currentRightOverlap;
-(float)currentLeftOverlap;
-(float)currentOverlap;
-(void)setCurrentOverlap:(float)arg1;
-(void)setVisible:(BOOL)arg1 frame:(CGRect)arg2 duration:(double)arg3;
-(void)endDisablingRasterization;
-(BOOL)cachesImage;
-(float)shadowPadding;
-(float)standardPadding;
-(void)setLayerContentsImage:(id)arg1;
-(float)legibilityStrength;
-(BOOL)allowsUpdates;
-(float)updateContentsAndWidth;
-(void)setAllowsUpdates:(BOOL)arg1;
-(id)initWithItem:(UIStatusBarItem *)arg1 data:(id)arg2 actions:(int)arg3 style:(id)arg4;
-(void)setPersistentAnimationsEnabled:(BOOL)arg1;
-(int)legibilityStyle;
-(_UILegibilityImageSet *)contentsImage;
-(BOOL)updateForNewData:(id)arg1 actions:(int)arg2;
-(void)endImageContext;
-(id)imageFromImageContextClippedToWidth:(float)arg1;
-(void)beginImageContextWithMinimumWidth:(float)arg1;
-(id)foregroundStyle; //UIStatusBarForegroundStyleAttributes *
-(id)imageWithShadowNamed:(id)arg1;
-(UIStatusBarItem *)item;
-(int)textAlignment;
-(void)setVisible:(BOOL)arg1;
-(void)willMoveToWindow:(id)arg1;
-(BOOL)_shouldAnimatePropertyWithKey:(id)arg1;
-(void)setContentMode:(int)arg1;
@end

@interface UIStatusBarSignalStrengthItemView : UIStatusBarItemView{
    int _signalStrengthRaw;
    int _signalStrengthBars;
    BOOL _enableRSSI;
    BOOL _showRSSI;
}

-(NSString *)_stringForRSSI;
-(float)extraRightPadding;
-(_UILegibilityImageSet *)contentsImage;
-(BOOL)updateForNewData:(id)arg1 actions:(int)arg2;
-(void)touchesEnded:(id)arg1 withEvent:(id)arg2;
@end

@interface UIStatusBarDataNetworkItemView : UIStatusBarItemView  {
    int _dataNetworkType;
    int _wifiStrengthRaw;
    int _wifiStrengthBars;
    BOOL _enableRSSI;
    BOOL _showRSSI;
}


-(id)_dataNetworkImage;
-(id)_stringForRSSI;
-(float)maximumOverlap;
-(float)extraLeftPadding;
-(id)contentsImage;
-(BOOL)updateForNewData:(id)arg1 actions:(int)arg2;
-(void)touchesEnded:(id)arg1 withEvent:(id)arg2;
@end

@interface UIStatusBarServiceItemView : UIStatusBarItemView
@end

@interface UIStatusBarBatteryItemView : UIStatusBarItemView  {
    int _capacity;
    int _state;
    UIView *_accessoryView;
}

-(float)_batteryYOffsetWithBackground:(id)arg1;
-(id)_accessoryImage;
-(BOOL)_needsAccessoryImage;
-(void)_updateAccessoryImage;
-(float)extraRightPadding;
-(float)legibilityStrength;
-(id)contentsImage;
-(BOOL)updateForNewData:(id)arg1 actions:(int)arg2;
@end

@interface UIStatusBarNotChargingItemView : UIStatusBarItemView  {
    NSString *_notChargingString;
}

-(void)dealloc;
-(id)contentsImage;
-(BOOL)updateForNewData:(id)arg1 actions:(int)arg2;
@end

@interface UIStatusBarLayoutManager : NSObject
@property BOOL persistentAnimationsEnabled;

-(id)initWithRegion:(int)arg1 foregroundView:(id)arg2;
-(void)itemView:(id)arg1 widthChangedBy:(float)arg2;
-(float)_widthNeededForItemView:(id)arg1;
-(id)_viewForItem:(id)arg1;
-(BOOL)_processDelta:(float)arg1 forView:(id)arg2;
-(CGRect)_repositionedNewFrame:(CGRect)arg1 widthDelta:(float)arg2;
-(float)_positionAfterPlacingItemView:(id)arg1 startPosition:(float)arg2;
-(CGRect)_frameForItemView:(id)arg1 startPosition:(float)arg2;
-(id)_itemViewsSortedForLayout;
-(id)_createViewForItem:(id)arg1 withData:(id)arg2 actions:(int)arg3;
-(BOOL)_updateItemView:(id)arg1 withData:(id)arg2 actions:(int)arg3 animated:(BOOL)arg4;
-(id)_itemViews;
-(void)_positionNewItemViewsWithEnabledItems:(BOOL*)arg1;
-(void)_prepareEnabledItemType:(int)arg1 withEnabledItems:(BOOL*)arg2 withData:(id)arg3 actions:(int)arg4 itemAppearing:(BOOL*)arg5 itemDisappearing:(BOOL*)arg6;
-(void)setPersistentAnimationsEnabled:(BOOL)arg1;
-(BOOL)itemIsVisible:(id)arg1;
-(float)removeOverlap:(float)arg1 fromItems:(id)arg2;
-(float)widthNeededForItem:(id)arg1;
-(float)distributeOverlap:(float)arg1 amongItems:(id)arg2;
-(float)widthNeededForItems:(id)arg1;
-(void)clearOverlapFromItems:(id)arg1;
-(CGRect)rectForItems:(id)arg1;
-(void)makeVisibleItemsPerformPendedActions;
-(void)removeDisabledItems:(BOOL*)arg1;
-(void)positionInvisibleItems;
-(void)setVisibilityOfItem:(id)arg1 visible:(BOOL)arg2;
-(void)reflowWithVisibleItems:(id)arg1 duration:(double)arg2;
-(void)setVisibilityOfAllItems:(BOOL)arg1;
-(BOOL)updateItemsWithData:(id)arg1 actions:(int)arg2 animated:(BOOL)arg3;
-(BOOL)prepareEnabledItems:(BOOL*)arg1 withData:(id)arg2 actions:(int)arg3;
-(void)setForegroundView:(id)arg1;
-(float)_startPosition;
@end

@interface UIStatusBarForegroundStyleAttributes : NSObject
- (int)legibilityStyle;
- (UIColor *)textColorForStyle:(int)arg1;
@end

@interface UIStatusBarForegroundView : UIView
-(UIStatusBarForegroundStyleAttributes *)foregroundStyle;
-(void)_cleanUpAfterDataChange;
-(void)_cleanUpAfterSimpleReflow;
-(id)_computeVisibleItemsPreservingHistory:(BOOL)arg1;
-(void)_reflowItemViewsCrossfadingCenterWithDuration:(double)arg1;
-(void)_reflowItemViewsWithDuration:(double)arg1 preserveHistory:(BOOL)arg2;
-(void)_setStatusBarData:(id)arg1 actions:(int)arg2 animated:(BOOL)arg3;
-(BOOL)_tryToPlaceItem:(id)arg1 inItemArray:(id)arg2 layoutManager:(id)arg3 roomRemaining:(float*)arg4 allowSwap:(BOOL)arg5 swappedItem:(id*)arg6;
-(float)edgePadding;
-(int)idiom;
-(BOOL)ignoringData;
-(id)initWithFrame:(CGRect)arg1 foregroundStyle:(id)arg2;
-(BOOL)pointInside:(CGPoint)arg1 withEvent:(id)arg2;
-(void)reflowItemViews:(BOOL)arg1;
-(void)reflowItemViewsCrossfadingCenter:(id)arg1 duration:(double)arg2;
-(void)reflowItemViewsForgettingEitherSideItemHistory;
-(void)setBounds:(CGRect)arg1;
-(void)setFrame:(CGRect)arg1;
-(void)setIdiom:(int)arg1;
-(void)setPersistentAnimationsEnabled:(BOOL)arg1;
-(void)setStatusBarData:(id)arg1 actions:(int)arg2 animated:(BOOL)arg3;
-(void)startIgnoringData;
-(void)stopIgnoringData:(BOOL)arg1;
@end


@interface _UIScrollsToTopInitiatorView : UIView
-(BOOL)_shouldSeekHigherPriorityTouchTarget;
-(id)hitTest:(CGPoint)arg1 withEvent:(id)arg2;
-(void)touchesEnded:(id)arg1 withEvent:(id)arg2;
@end

@interface UIStatusBar : _UIScrollsToTopInitiatorView
-(void)_setStyle:(id)arg1;
-(int)legibilityStyle;
-(id)initWithFrame:(CGRect)arg1 showForegroundView:(BOOL)arg2 inProcessStateProvider:(id)arg3;
-(id)initWithFrame:(CGRect)arg1 showForegroundView:(BOOL)arg2;
-(id)initWithFrame:(CGRect)arg1;
@end

@interface UIStatusBarWindow : UIWindow  {
    UIStatusBar *_statusBar;
    int _orientation;
    float _topCornersOffset;
    BOOL _cornersHidden;
}

+(CGRect)statusBarWindowFrame;
+(BOOL)isIncludedInClassicJail;

-(id)initWithFrame:(CGRect)arg1;
-(void)dealloc;

-(int)orientation;
-(BOOL)_isStatusBarWindow;
-(BOOL)_shouldZoom;

-(void)setTopCornerStyle:(int)arg1 topCornersOffset:(float)arg2 bottomCornerStyle:(int)arg3 animationParameters:(id)arg4;
-(void)setCornersHidden:(BOOL)arg1 animationParameters:(id)arg2;
-(void)setOrientation:(int)arg1 animationParameters:(id)arg2;
-(void)setStatusBar:(id)arg1;

-(void)_rotate;
-(BOOL)_disableViewScaling;
-(BOOL)_disableGroupOpacity;
-(void)_updateTransformLayerForClassicPresentation;

-(id)hitTest:(CGRect)arg1 withEvent:(id)arg2;
@end

@interface UIStatusBarStyleAttributes : NSObject
-(int)style;
@end

