#import "CellCircleHeaders.h"
#import "CCView.h"


@interface UIStatusBarSignalStrengthItemView (CellCircle)
+(int)bars;
@end

%hook UIStatusBarSignalStrengthItemView
static int bars;

%new +(int)bars{
	return bars;
}

-(_UILegibilityImageSet *)contentsImage{
	UIGraphicsBeginImageContextWithOptions([%orig image].size, NO, 0.0);
	UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return [%c(_UILegibilityImageSet) imageFromImage:blank withShadowImage:blank];
}

-(BOOL)updateForNewData:(id)arg1 actions:(int)arg2{
	bars = MSHookIvar<int>(self, "_signalStrengthBars");
	NSLog(@"&&&& update bars: %i", bars);
	return %orig;
}
%end


//UIStatusBarSignalStrengthItemView: 0x12de1fa90; frame = (6 0; 35 20); alpha = 0; autoresize = RM+BM; userInteractionEnabled = NO; layer = <CALayer: 0x17822f520>> [Item = <UIStatusBarItem: 0x17822f4e0> [SignalStrength (Left)]]
%hook UIStatusBarLayoutManager
static CCView *circle;

-(CGRect)_frameForItemView:(id)arg1 startPosition:(float)arg2{
	if([arg1 isKindOfClass:%c(UIStatusBarSignalStrengthItemView)])
		return CGRectMake(6, 0, 18, 20);

	return %orig;
}
//-(UIStatusBarItemView *)_viewForItem:(UIStatusBarItem *)arg1;
/*-(id)_viewForItem:(id)arg1{
	NSLog(@"----- view %@, orig:%@", arg1, %orig);
	/*if([%orig isKindOfClass:%c(UIStatusBarSignalStrengthItemView)]){
		NSLog(@"----- if!");
		if(circle){
			[circle removeFromSuperview];
			circle = nil;
		}

		UIStatusBarSignalStrengthItemView *bubbles = %orig;
		int bars = MSHookIvar<int>(bubbles, "_signalStrengthBars");
		circle = [[CCView alloc] initWithRadius:(bubbles.frame.size.height / 2.0f)];
		circle.center = bubbles.center;
		[circle setState:bars];
		[bubbles addSubview:circle];
	}

	return %orig;
}*/
%end

%hook UIStatusBarForegroundView
-(id)initWithFrame:(CGRect)arg1 foregroundStyle:(id)arg2{
	UIStatusBarForegroundView *view = %orig;
	circle = [[CCView alloc] initWithRadius:(ceilf(arg1.size.height / 2.0f))];
	circle.center = view.center;

	int bars = [%c(UIStatusBarSignalStrengthItemView) bars];
	[circle setState:bars];

	[view addSubview:circle];
	return view;
}

%end