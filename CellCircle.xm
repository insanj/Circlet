#import "CellCircleHeaders.h"
#import "CCView.h"
#import "substrate.h"

@interface UIStatusBarSignalStrengthItemView (CellCircle)
@property (nonatomic, retain) CCView *circle;
-(CCView *)circleWithRadius:(CGFloat)arg1 andCenter:(CGPoint)arg2;
@end

%hook UIStatusBarSignalStrengthItemView

// Below method doesn't appear to be called at any time in Springboard, but I wanted
// to leave it in here to reassure that this solution isn't viable (even if UIView is return)
//+(id)createViewForItem:(UIStatusBarItem *)arg1 withData:(id)arg2 actions:(int)arg3 foregroundStyle:(id)arg4

// Initialize and set-up the instance variable (circle), and add it as a subview
-(id)init{
	NSLog(@"[CellCircle]: Creating CellCircle and loading into signal view");
	UIStatusBarSignalStrengthItemView *original = %orig;
	self.circle = [original circleWithRadius:original.frame.size.height/2.f andCenter:original.center];
	[original addSubview:self.circle];
	return original;
}

// Return a transparent image for the statusbar item's symbol
-(_UILegibilityImageSet *)contentsImage{
	NSLog(@"[CellCircle]: Dealing with old signal view's symbol management");
	UIGraphicsBeginImageContextWithOptions([%orig image].size, NO, 0.f);
	UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return [%c(_UILegibilityImageSet) imageFromImage:blank withShadowImage:blank];
}

// When updating statusitem, make sure circle style and bars are up-to-date
-(BOOL)updateForNewData:(id)arg1 actions:(int)arg2{
	NSLog(@"[CellCircle]: Checking for signal update information (looks like there %@ an update)", %orig?@"is":@"isn't");
	if(%orig){
		int bars = MSHookIvar<int>(self, "_signalStrengthBars");
		[self.circle setState:bars];

		UIStatusBarForegroundStyleAttributes *foregroundStyle = [self foregroundStyle];
		[self.circle setTint:[foregroundStyle textColorForStyle:[foregroundStyle legibilityStyle]]];
	}

	return %orig;
}

// Create new CCView with the given radius and center-point
%new -(CCView *)circleWithRadius:(CGFloat)arg1 andCenter:(CGPoint)arg2{
	NSLog(@"[CellCircle]: Creating a new circle (CCView) to load into statusbar");
	CCView *newCircle = [[CCView alloc] initWithRadius:arg1];
	newCircle.center = arg2;
	newCircle.alpha = 1.f;
	newCircle.hidden = NO;
	newCircle.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;

	return newCircle;
}
%end

// Make sure the spacing in the layoutmanager is the circle's preferred, not original
%hook UIStatusBarLayoutManager
-(CGRect)_frameForItemView:(id)arg1 startPosition:(float)arg2{
	if([arg1 isKindOfClass:%c(UIStatusBarSignalStrengthItemView)]){
		NSLog(@"[CellCircle]: Changing the spacing for statusbaritem (%@)", arg1);
		return CGRectMake(6.0f, 0.f, 20.0f, 20.0f);
	}

	return %orig;
}
%end