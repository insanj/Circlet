#import "CellCircleHeaders.h"
#import "CCView.h"

// Some nice optional debugging (in case we add preferences later)
#define DEBUG TRUE

#ifdef DEBUG
	#define debugLog(string, ...) NSLog(@"[CellCircle] \e[1;31m%@\e[m ",[NSString stringWithFormat:string, ## __VA_ARGS__])
#else
	#define debugLog(string, ...)
#endif

#define PADDING 8.f
static CGFloat lastDiameter;

@interface UIStatusBarSignalStrengthItemView (CellCircle)
-(UIImage *)imageFromCircle:(CCView *)circle;
@end

%hook UIStatusBarSignalStrengthItemView
static int lastState;

// Generate a UIImage from given CCView using GraphicsImageContext (should be quite accurate)
%new -(UIImage *)imageFromCircle:(CCView *)circle{
	UIGraphicsBeginImageContextWithOptions(circle.bounds.size, NO, 0.f);
    [circle.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

// Return a converted CCView (to UIImage) in both black and white, to replace the contentsImage 
-(_UILegibilityImageSet *)contentsImage{
	debugLog(@"Dealing with old signal view's symbol management");

	lastDiameter = [%orig image].size.height - PADDING;
	CGFloat radius = (lastDiameter / 2.f);

	CCView *circle = [[CCView alloc] initWithRadius:radius];
	lastState = MSHookIvar<int>(self, "_signalStrengthBars");
	[circle setState:lastState];

	UIColor *textColor = [[self foregroundStyle] textColorForStyle:[self legibilityStyle]];
	UIImage *image = [self imageFromCircle:[circle versionWithColor:textColor]];
	UIImage *shadow = [self imageFromCircle:[circle versionWithInverse:textColor]];

	return [%c(_UILegibilityImageSet) imageFromImage:image withShadowImage:shadow];
}

// When updating statusitem, make sure circle style and bars are up-to-date
-(BOOL)updateForNewData:(id)arg1 actions:(int)arg2{
	int state =  MSHookIvar<int>(self, "_signalStrengthBars");
	if(%orig || (state != lastState)){
		debugLog(@"Recognized signal information change for state: %i", state);
		return YES;
	}
	
	return NO;
}
%end

%hook UIStatusBarLayoutManager

// Make sure the spacing in the layoutmanager is the circle's preferred, not original
-(CGRect)_frameForItemView:(UIStatusBarItemView *)arg1 startPosition:(float)arg2{
	if([arg1 isKindOfClass:%c(UIStatusBarSignalStrengthItemView)]){
		debugLog(@"Changing the spacing for statusbaritem: %@", arg1);
		return CGRectMake(%orig.origin.x, PADDING / 2.f, lastDiameter, lastDiameter);
	}

	return %orig;
}
%end