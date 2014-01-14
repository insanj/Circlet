//
//  Circular.xm
//  CellCircle
//
//  Created by Julian Weiss on 1/5/14.
//  Copyright (c) 2014 insanj. All rights reserved.
//

#import "CRHeaders.h"
#import "CRNotificationListener.h"
#import "CRView.h"

// Global variables and functions for preference usage
static CRNotificationListener *listener;
static CRView *signalCircle;
static CGFloat signalDiameter;

%ctor{
	@autoreleasepool{
		listener = [[CRNotificationListener alloc] init];		
		signalCircle = [[CRView alloc] initWithRadius:listener.signalPadding];
	}
}

@interface UIStatusBarSignalStrengthItemView (Circular)
-(void)setCircle:(CRView *)arg1;
-(UIImage *)imageFromCircle:(CRView *)arg1;
@end

%hook UIStatusBarSignalStrengthItemView
static int signalState;

// Generate a UIImage from given CRView using GraphicsImageContext (should be quite accurate)
%new -(UIImage *)imageFromCircle:(CRView *)arg1{
	UIGraphicsBeginImageContextWithOptions(arg1.bounds.size, NO, 0.f);
    [arg1.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

// Return a converted CRView (to UIImage) in both black and white, to replace the contentsImage 
-(_UILegibilityImageSet *)contentsImage{
	if(listener.signalEnabled){
		[listener debugLog:@"Dealing with old signal view's symbol management"];

		signalDiameter = [%orig image].size.height - listener.signalPadding;
		CGFloat radius = (signalDiameter / 2.f);
		if(signalCircle.radius != radius)
			[signalCircle setRadius:radius];

		signalState = MSHookIvar<int>(self, "_signalStrengthBars");
		[signalCircle setState:signalState];

		UIColor *textColor = [[self foregroundStyle] textColorForStyle:[self legibilityStyle]];
		UIImage *image = [self imageFromCircle:[signalCircle versionWithColor:textColor]];
		UIImage *shadow = [self imageFromCircle:[signalCircle versionWithInverse:textColor]];

		return [%c(_UILegibilityImageSet) imageFromImage:image withShadowImage:shadow];
	}

	return %orig();
}

%end

%hook UIStatusBarLayoutManager

// Make sure the spacing in the layoutmanager is the circle's preferred, not original
-(CGRect)_frameForItemView:(UIStatusBarItemView *)arg1 startPosition:(float)arg2{
	if([arg1 isKindOfClass:%c(UIStatusBarSignalStrengthItemView)] && listener.signalEnabled){
		[listener debugLog:[NSString stringWithFormat:@"Changing the spacing for statusbaritem: %@", arg1]];
		return CGRectMake(%orig().origin.x, listener.signalPadding / 2.f, signalDiameter, signalDiameter);
	}

	return %orig();
}
%end