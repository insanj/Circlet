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
	if(%orig)
		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"CCStateNotification" object:self];

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

%hook UIStatusBarViewController
static CCView *circle;


-(id)init{

	//[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(changeState:) name:@"CCStateNotification" object:nil];
	[[NSDistributedNotificationCenter defaultCenter] addObserverForName:@"CCStateNotification" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification){
			UIStatusBarSignalStrengthItemView *sender = notification.object;
			int bars = MSHookIvar<int>(sender, "_signalStrengthBars");
			[circle setState:bars];
	}];

	UIStatusBarViewController *vc = %orig;
	circle = [[CCView alloc] initWithRadius:(5.0f)];
	circle.tag = 48;
	circle.center = CGPointMake(10.f, 10.0f);
	[circle setWhite:YES];
	[vc.view addSubview:circle];


	return vc;
}

-(void)setStatusBarStyle:(int)arg1 animationParameters:(id)arg2{
	%orig;
	if(arg1 == 0)
		[circle setWhite:YES];
	else
		[circle setWhite:NO];
}
%end