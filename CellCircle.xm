#import "CellCircleHeaders.h"
#import "CCView.h"

// Some nice optional debugging (in case we add preferences later)
#define DEBUG TRUE

#ifdef DEBUG
	#define debugLog(string, ...) NSLog(@"[CellCircle] \e[1;31m%@\e[m ",[NSString stringWithFormat:string, ## __VA_ARGS__])
#else
	#define debugLog(string, ...)
#endif

@interface UIStatusBarSignalStrengthItemView (CellCircle)
-(CCView *)circleWithRadius:(CGFloat)arg1 andCenter:(CGPoint)arg2;
-(CCView *)currentCircle;
-(CCView *)ifNeededCircleWithRadius:(CGFloat)arg1 center:(CGPoint)arg2 andOriginal:(UIStatusBarSignalStrengthItemView *)arg3;
@end

static CCView *circle;

// Create new CCView with the given radius and center-point
CCView * circleWithRadiusCenter(CGFloat arg1, CGPoint arg2){
	debugLog(@"Creating a new circle (CCView) to load into statusbar");

	CCView *newCircle = [[CCView alloc] initWithRadius:arg1];
	newCircle.center = arg2;
	newCircle.alpha = 1.f;
	newCircle.hidden = NO;
	newCircle.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;

	return newCircle;
}

// Create a new CCView if one doesn't already exist, and let it hijack the original item
CCView * ifNeededCircleWithRadiusCenterOriginal(CGFloat arg1, CGPoint arg2, UIStatusBarSignalStrengthItemView *arg3){
	debugLog(@"Shipping off CCView (%@) on request from external source", circle);

	if(!circle)
		circle =  circleWithRadiusCenter(arg1, arg2);
	[circle hijackOriginal:arg3];
	return circle;
}


%hook UIStatusBarSignalStrengthItemView

// Below method doesn't appear to be called at any time in Springboard, but I wanted
// to leave it in here to reassure that this solution isn't viable (even if UIView is return)
//+(id)createViewForItem:(UIStatusBarItem *)arg1 withData:(id)arg2 actions:(int)arg3 foregroundStyle:(id)arg4

// Return a transparent image for the statusbar item's symbol
-(_UILegibilityImageSet *)contentsImage{
	debugLog(@"Dealing with old signal view's symbol management");

	UIGraphicsBeginImageContextWithOptions([%orig image].size, NO, 0.f);
	UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return [%c(_UILegibilityImageSet) imageFromImage:blank withShadowImage:blank];
}

// When updating statusitem, make sure circle style and bars are up-to-date
-(BOOL)updateForNewData:(id)arg1 actions:(int)arg2{
	debugLog(@"Checking for signal update information: %@", %orig?@"YES":@"NO");

	if(%orig){
		int bars = MSHookIvar<int>(self, "_signalStrengthBars");
		[circle setState:bars];

		UIStatusBarForegroundStyleAttributes *foregroundStyle = [self foregroundStyle];
		[circle setTint:[foregroundStyle textColorForStyle:[foregroundStyle legibilityStyle]]];
	}

	return %orig;
}
%end

%hook UIStatusBarLayoutManager

// Make sure the spacing in the layoutmanager is the circle's preferred, not original
-(CGRect)_frameForItemView:(id)arg1 startPosition:(float)arg2{
	if([arg1 isKindOfClass:%c(UIStatusBarSignalStrengthItemView)]){
		debugLog(@"Changing the spacing for statusbaritem: %@", arg1);
		return CGRectMake(0.f, 0.f, 20.f, 20.f);
	}

	return %orig;
}

// Always return the hijacked statusitem (CCView) when layout tries to retrieve signal view
-(id)_viewForItem:(id)arg1{
	if([%orig isKindOfClass:%c(UIStatusBarSignalStrengthItemView)]){
		debugLog(@"Hijacking the retrieval of the original view for statusbaritem: %@", arg1);
		UIStatusBarSignalStrengthItemView *original = %orig;
		return ifNeededCircleWithRadiusCenterOriginal(original.frame.size.height/2.f, original.center, original);
	}

	return %orig;
}

// Always return the hijacked statusitem (CCView) when layout tries to create signal view
-(id)_createViewForItem:(id)arg1 withData:(id)arg2 actions:(int)arg3{
	if([%orig isKindOfClass:%c(UIStatusBarSignalStrengthItemView)]){
		debugLog(@"Hijacking the creation of the original view for statusbaritem: %@", arg1);
		UIStatusBarSignalStrengthItemView *original = %orig;
		return ifNeededCircleWithRadiusCenterOriginal(original.frame.size.height/2.f, original.center, original);
	}

	return %orig;
}
%end