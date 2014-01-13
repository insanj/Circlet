#import "CellCircleHeaders.h"
#import "CCView.h"

// Some nice optional debugging (in case we add preferences later)
#define DEBUG TRUE

#ifdef DEBUG
	#define debugLog(string, ...) NSLog(@"[CellCircle] \e[1;31m%@\e[m ",[NSString stringWithFormat:string, ## __VA_ARGS__])
#else
	#define debugLog(string, ...)
#endif

// Global frame variable, as to be accessed in layoutmanager and itemview (and also for prefs)
static CGRect circleFrame = CGRectMake(5.f, 1.f, 18.f, 18.f);

@interface UIStatusBarSignalStrengthItemView (CellCircle)
-(CCView *)circleWithFrame:(CGRect)frame;
-(UIImage *)imageFromCircle:(CCView *)circle;
@end

%hook UIStatusBarSignalStrengthItemView
static CCView *currentCircle;

// If needed, create new CCView with given frame (derive radius and set frame to be near-perfect)
%new -(CCView *)circleWithFrame:(CGRect)frame{
	if(!currentCircle || (currentCircle && !CGRectEqualToRect(currentCircle.frame, frame))){
		currentCircle = [[CCView alloc] initWithRadius:frame.size.height/2.f];
		currentCircle.frame = frame;
	}

	return currentCircle;
}

// Generate a UIImage from given CCView using GraphicsImageContext (should be quite accurate)
%new -(UIImage *)imageFromCircle:(CCView *)circle{
	BOOL isLeveling = circle.shouldUpdateManager;
	[circle setShouldLevel:NO];

	UIGraphicsBeginImageContextWithOptions(circle.bounds.size, circle.opaque, 0.f);
    [circle.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

	[circle setShouldLevel:isLeveling];
    return image;
}

// Return a converted CCView (to UIImage) in both black and white, to replace the contentsImage 
-(_UILegibilityImageSet *)contentsImage{
	debugLog(@"Dealing with old signal view's symbol management");

	CCView *circle = [self circleWithFrame:circleFrame];

	[circle setTint:[UIColor whiteColor]];
	UIImage *white = [self imageFromCircle:circle];

	[circle setTint:[UIColor blackColor]];
	UIImage *black = [self imageFromCircle:circle];

	return [%c(_UILegibilityImageSet) imageFromImage:white withShadowImage:black];
}

// When updating statusitem, make sure circle style and bars are up-to-date
-(BOOL)updateForNewData:(id)arg1 actions:(int)arg2{
	debugLog(@"Checking for signal update information: %@", %orig?@"YES":@"NO");

	if(%orig){
		int bars = MSHookIvar<int>(self, "_signalStrengthBars");
		[[self circleWithFrame:circleFrame] setState:bars];

	//	UIStatusBarForegroundStyleAttributes *foregroundStyle = [self foregroundStyle];
	//	[circle setTint:[foregroundStyle textColorForStyle:[foregroundStyle legibilityStyle]]];
	}

	return %orig;
}
%end

%hook UIStatusBarLayoutManager

// Make sure the spacing in the layoutmanager is the circle's preferred, not original
-(CGRect)_frameForItemView:(id)arg1 startPosition:(float)arg2{
	if([arg1 isKindOfClass:%c(UIStatusBarSignalStrengthItemView)]){
		debugLog(@"Changing the spacing for statusbaritem: %@", arg1);
		return circleFrame;
	}

	return %orig;
}
%end