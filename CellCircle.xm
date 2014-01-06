#import "CellCircleHeaders.h"
#import "CCView.h"

/*
%hook UIStatusBarSignalStrengthItemView
static CCView *circle;

/*
//_UILegibilityImageSet *
-(id)contentsImage{
	int bars = MSHookIvar<int>(self, "_signalStrengthBars");
	CCView *circle = = [[CCView alloc] initWithRadius:8.f];
	circle.center = [%orig image].center;
	return circle;
}//

+(id)createViewForItem:(UIStatusBarItem *)arg1 withData:(id)arg2 actions:(int)arg3 foregroundStyle:(id)arg4{
	NSLog(@"---- orig:%@, arg1:%@, arg2:%@, arg3:%i, arg4:%@", %orig, arg1, arg2, arg3, arg4);
	return %orig;
}


%end*/


//UIStatusBarSignalStrengthItemView: 0x12de1fa90; frame = (6 0; 35 20); alpha = 0; autoresize = RM+BM; userInteractionEnabled = NO; layer = <CALayer: 0x17822f520>> [Item = <UIStatusBarItem: 0x17822f4e0> [SignalStrength (Left)]]
%hook UIStatusBarLayoutManager
static CCView *circle;

-(UIView *)_viewForItem:(UIStatusBarItem *)arg1{
	NSLog(@"----- view %@, orig:%@", arg1, %orig);
	if([%orig isKindOfClass:%c(UIStatusBarSignalStrengthItemView)]){
		NSLog(@"------ if!");
		circle = [[CCView alloc] initWithRadius:(%orig.frame.size.height / 2)];
		circle.center = %orig.center;

		int bars = MSHookIvar<int>(arg1, "_signalStrengthBars");
		[circle setState:bars];
		return circle;
	}

	return %orig;
}
%end