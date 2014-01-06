#import "CellCircleHeaders.h"
#import "CCView.h"
//idea -- set nsdistibuted for the circle view, every time update returns TRUE ping it and set the state (+1)

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
		return CGRectMake(6.0f, 0.f, 18.0f, 20.0f);

	return %orig;
}
%end

@interface UIStatusBar (CellCircle)
-(CCView *)createCircle;
@end

%hook UIStatusBar
static CCView *circle;
%new -(CCView *)createCircle{
	CCView *newCircle = [[CCView alloc] initWithRadius:(5.0f)];
	newCircle.tag = 48;
	newCircle.center = CGPointMake(10.f, 10.0f);
	[newCircle setWhite:[self legibilityStyle]==0];

	[[NSDistributedNotificationCenter defaultCenter] addObserverForName:@"CCStateNotification" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification){
			[newCircle setState:[[notification userInfo][@"bars"] intValue]];
	}];

	return newCircle;
}

-(void)_setStyle:(id)arg1{
	UIStatusBarStyleAttributes *given = arg1;

	NSLog(@"---- setting to %@, style:%i", given, [given style]);
	[circle setWhite:[given style]==1];
	%orig;
}

-(id)initWithFrame:(CGRect)arg1 showForegroundView:(BOOL)arg2 inProcessStateProvider:(id)arg3{
	UIStatusBar *bar = %orig;
	if(!circle){
		circle = [self createCircle];
		[bar addSubview:circle];
	}

	return bar;
}

-(id)initWithFrame:(CGRect)arg1 showForegroundView:(BOOL)arg2{
	UIStatusBar *bar = %orig;
	if(!circle){
		circle = [self createCircle];
		[bar addSubview:circle];
	}

	return bar;
}

-(id)initWithFrame:(CGRect)arg1{
	UIStatusBar *bar = %orig;
	if(!circle){
		circle = [self createCircle];
		[bar addSubview:circle];
	}

	return bar;
}

%end