#import "CellCircleHeaders.h"
#import "CCView.h"
#import "substrate.h"

%hook UIStatusBarSignalStrengthItemView
-(_UILegibilityImageSet *)contentsImage{
	UIGraphicsBeginImageContextWithOptions([%orig image].size, NO, 0.0);
	UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return [%c(_UILegibilityImageSet) imageFromImage:blank withShadowImage:blank];
}

-(BOOL)updateForNewData:(id)arg1 actions:(int)arg2{
	if(%orig){
		int bars = MSHookIvar<int>(self, "_signalStrengthBars");
		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"CCStateNotification" object:nil userInfo:@{@"bars" : @(bars)}];
	}

	return %orig;
}
%end


%hook UIStatusBarLayoutManager
-(CGRect)_frameForItemView:(id)arg1 startPosition:(float)arg2{
	if([arg1 isKindOfClass:%c(UIStatusBarSignalStrengthItemView)])
		return CGRectMake(6.0f, 0.f, 20.0f, 20.0f);

	return %orig;
}
%end

@interface UIStatusBarForegroundView (CellCircle)
-(CCView *)circleWithFrame:(CGRect)frame;
-(void)setCircleStyle:(UIStatusBarForegroundStyleAttributes *)style;
@end

%hook UIStatusBarForegroundView
CCView *circle;

%new -(CCView *)circleWithFrame:(CGRect)frame{
	if(!circle)
		circle = [[CCView alloc] initWithRadius:(frame.size.height / 2.f)];

	circle.frame = frame;
	circle.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;

	[[NSDistributedNotificationCenter defaultCenter] addObserverForName:@"CCStateNotification" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification){
		[circle setState:[[notification userInfo][@"bars"] intValue]];
		[self setCircleStyle:[self foregroundStyle]];
	}];

	return circle;
}

// UIDeviceWhiteColorSpace 1 1, equivalent to -colorWithWhite:alpha:
%new -(void)setCircleStyle:(UIStatusBarForegroundStyleAttributes *)style{
	[circle setTint:[style textColorForStyle:[style legibilityStyle]]];
}

-(void)_setStyle:(id)arg1{
	%orig;
	[self setCircleStyle:arg1];
}

//  ----- adding <UIStatusBarSignalStrengthItemView: 0x137dd5cb0; frame = (0 0; 18 20); alpha = 0; autoresize = RM+BM; userInteractionEnabled = NO; layer = <CALayer: 0x178637f80>> [Item = <UIStatusBarItem: 0x170623120> [SignalStrength (Left)]]
//	----- if where <CCView: 0x137ded630; frame = (6 0; 18 20); autoresize = RM+BM; layer = <CALayer: 0x178621ea0>>

-(void)addSubview:(id)arg1{

	// does get accurately and sufficiently called from SpringBoard
	if([arg1 isKindOfClass:%c(UIStatusBarSignalStrengthItemView)]){
		%orig([self circleWithFrame:[(UIStatusBarSignalStrengthItemView *)arg1 frame]]);
		[self bringSubviewToFront:circle];
	}

	else
		%orig;
}

%end