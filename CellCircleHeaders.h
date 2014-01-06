#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

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
-(id)foregroundStyle;
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

@interface UIStatusBarForegroundView : UIView
-(void)_cleanUpAfterDataChange;
-(void)_cleanUpAfterSimpleReflow;
-(id)_computeVisibleItemsPreservingHistory:(BOOL)arg1;
-(void)_reflowItemViewsCrossfadingCenterWithDuration:(double)arg1;
-(void)_reflowItemViewsWithDuration:(double)arg1 preserveHistory:(BOOL)arg2;
-(void)_setStatusBarData:(id)arg1 actions:(int)arg2 animated:(BOOL)arg3;
-(BOOL)_tryToPlaceItem:(id)arg1 inItemArray:(id)arg2 layoutManager:(id)arg3 roomRemaining:(float*)arg4 allowSwap:(BOOL)arg5 swappedItem:(id*)arg6;
-(float)edgePadding;
-(id)foregroundStyle;
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