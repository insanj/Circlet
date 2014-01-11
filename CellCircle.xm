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
		NSLog(@"---- bars:%i", bars);
		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"CCStateNotification" object:nil userInfo:@{@"bars" : @(bars)}];
	}

	return %orig;
}
%end


%hook UIStatusBarLayoutManager
-(CGRect)_frameForItemView:(id)arg1 startPosition:(float)arg2{
	if([arg1 isKindOfClass:%c(UIStatusBarSignalStrengthItemView)])
		return CGRectMake(6.0f, 0.f, 18.0f, 20.0f);

	return %orig;
}
%end

@interface UIStatusBarForegroundView (CellCircle)
-(CCView *)createCircle;
@end

%hook UIStatusBarForegroundView
static CCView *circle;

%new -(CCView *)createCircle{
	circle = [[CCView alloc] initWithRadius:(5.0f)];
	circle.center = CGPointMake(10.f, 10.0f);

	[[NSDistributedNotificationCenter defaultCenter] addObserverForName:@"CCStateNotification" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification){
		[circle setState:[[notification userInfo][@"bars"] intValue]];
		
		UIStatusBarForegroundStyleAttributes *foregroundStyle = [self foregroundStyle];
		[circle setTint:[foregroundStyle textColorForStyle:[foregroundStyle legibilityStyle]]];
	}];

	return circle;
}


-(void)_setStyle:(id)arg1{
	UIStatusBarForegroundStyleAttributes *foregroundStyle = arg1;
	[circle setTint:[foregroundStyle textColorForStyle:[foregroundStyle legibilityStyle]]];
	%orig;
}

// ---- adding <UIStatusBarSignalStrengthItemView: 0x147d11160; frame = (6 0; 18 20); alpha = 0; autoresize = RM+BM; userInteractionEnabled = NO; layer = <CALayer: 0x17003a400>> [Item = <UIStatusBarItem: 0x17003a3e0> [SignalStrength (Left)]]
-(void)addSubview:(id)arg1{
	if([arg1 isKindOfClass:%c(UIStatusBarSignalStrengthItemView)])
		%orig(circle?circle:[self createCircle]);
	else
		%orig;
}

%end