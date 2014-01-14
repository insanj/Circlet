#import "CellCircleHeaders.h"
#import "CCView.h"

// Global variables for preference usage
static BOOL debug = TRUE;
static CGFloat padding = 12.f;

#ifdef debug
	#define debugLog(string, ...) NSLog(@"[CellCircle] \e[1;31m%@\e[m ",[NSString stringWithFormat:string, ## __VA_ARGS__])
#else
	#define debugLog(string, ...)
#endif

static CGFloat lastDiameter;

@interface UIStatusBarSignalStrengthItemView (CellCircle)
-(void)setCircle:(CCView *)arg1;
-(UIImage *)imageFromCircle:(CCView *)arg1;
@end

%hook UIStatusBarSignalStrengthItemView
static int lastState;
static CCView *circle;

//- (void)addObserver:(id)notificationObserver selector:(SEL)notificationSelector name:(NSString *)notificationName object:(NSString *)notificationSender

-(id)init{
	UIStatusBarSignalStrengthItemView *original = %orig;
	[original setCircle:[[CCView alloc] initWithRadius:8.f]];
	[[NSDistributedNotificationCenter defaultCenter] addObserver:original selector:@selector(prefsChanged:) name:@"CCPrefsChanged" object:nil];
	return %orig();
}

%new -(void)setCircle:(CCView *)arg1{
	circle = arg1;
}

// Generate a UIImage from given CCView using GraphicsImageContext (should be quite accurate)
%new -(UIImage *)imageFromCircle:(CCView *)arg1{
	UIGraphicsBeginImageContextWithOptions(arg1.bounds.size, NO, 0.f);
    [arg1.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

// Return a converted CCView (to UIImage) in both black and white, to replace the contentsImage 
-(_UILegibilityImageSet *)contentsImage{
	debugLog(@"Dealing with old signal view's symbol management");

	lastDiameter = [%orig image].size.height - padding;
	CGFloat radius = (lastDiameter / 2.f);
	if(circle.radius != radius)
		[circle setRadius:radius];

	lastState = MSHookIvar<int>(self, "_signalStrengthBars");
	[circle setState:lastState];

	UIColor *textColor = [[self foregroundStyle] textColorForStyle:[self legibilityStyle]];
	UIImage *image = [self imageFromCircle:[circle versionWithColor:textColor]];
	UIImage *shadow = [self imageFromCircle:[circle versionWithInverse:textColor]];

	return [%c(_UILegibilityImageSet) imageFromImage:image withShadowImage:shadow];
}

-(void)dealloc{
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
	%orig();
}

%end

%hook UIStatusBarLayoutManager

// Make sure the spacing in the layoutmanager is the circle's preferred, not original
-(CGRect)_frameForItemView:(UIStatusBarItemView *)arg1 startPosition:(float)arg2{
	if([arg1 isKindOfClass:%c(UIStatusBarSignalStrengthItemView)]){
		debugLog(@"Changing the spacing for statusbaritem: %@", arg1);
		return CGRectMake(%orig().origin.x, padding / 2.f, lastDiameter, lastDiameter);
	}

	return %orig;
}
%end