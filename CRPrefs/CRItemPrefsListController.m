#import "CRItemPrefsListController.h"

@implementation CRItemPrefsListController

- (void)sidesReplenish {	
	UIStatusBar *statusBar = (UIStatusBar *)[[UIApplication sharedApplication] statusBar];
	UIView *fakeStatusBar;

	if (MODERN_IOS) {
		fakeStatusBar = [statusBar snapshotViewAfterScreenUpdates:YES];
	}

	else {
		UIGraphicsBeginImageContextWithOptions(statusBar.frame.size, NO, [UIScreen mainScreen].scale);
		CGContextRef context = UIGraphicsGetCurrentContext();
		[statusBar.layer renderInContext:context];
		UIImage *statusBarImave = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		fakeStatusBar = [[UIImageView alloc] initWithImage:statusBarImave];
	}

	[statusBar.superview addSubview:fakeStatusBar];

	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"CRRefreshStatusBar" object:nil];

	CGRect upwards = statusBar.frame;
	upwards.origin.y -= upwards.size.height;
	statusBar.frame = upwards;

	CGFloat shrinkAmount = 5.0;
	[UIView animateWithDuration:0.6 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void){		
		CGRect shrinkFrame = fakeStatusBar.frame;
		shrinkFrame.origin.x += shrinkAmount;
		shrinkFrame.origin.y += shrinkAmount;
		shrinkFrame.size.width -= shrinkAmount;
		shrinkFrame.size.height -= shrinkAmount;
		fakeStatusBar.frame = shrinkFrame;
		fakeStatusBar.alpha = 0.0;
		
		CGRect downwards = statusBar.frame;
		downwards.origin.y += downwards.size.height;
		statusBar.frame = downwards;
	} completion: ^(BOOL finished) {
		[fakeStatusBar removeFromSuperview];
	}];
}

- (void)middleReplenish {
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"CRRefreshTime" object:nil];
}

- (void)signalReplenish {
	[self sidesReplenish];
}

- (void)carrierReplenish {
	[self sidesReplenish];
}

- (void)dataReplenish {
	[self sidesReplenish];
}

- (void)timeReplenish {
	[self middleReplenish];
}

- (void)batteryReplenish {
	[self sidesReplenish];
}

- (void)tableView:(id)arg1 didSelectRowAtIndexPath:(id)arg2 {
	[super tableView:arg1 didSelectRowAtIndexPath:arg2];
	[arg1 deselectRowAtIndexPath:arg2 animated:YES];
}

- (NSArray *)lightColorTitles:(id)target {
	NSMutableArray *titles = [[NSMutableArray alloc] initWithArray:[[CRTITLETOCOLOR allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
	[titles insertObject:@"Custom" atIndex:0];
	[titles removeObject:@"Black (Default)"];
	[titles removeObject:@"Red (Default)"];
	[titles removeObject:@"White"];
	[titles removeObject:@"Green (Default)"];
	return titles;
}

- (NSArray *)lightColorValues:(id)target {
	return [self lightColorTitles:target];
}

- (NSArray *)darkColorTitles:(id)target {
	NSMutableArray *titles = [[NSMutableArray alloc] initWithArray:[[CRTITLETOCOLOR allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
	[titles insertObject:@"Custom" atIndex:0];
	[titles removeObject:@"Black"];
	[titles removeObject:@"Red (Default)"];
	[titles removeObject:@"White (Default)"];
	[titles removeObject:@"Green (Default)"];
	return titles;
}

- (NSArray *)darkColorValues:(id)target {
	return [self darkColorTitles:target];
}

@end
