#import "HBTSTintedListController.h"

@implementation HBTSTintedListController

-(void)viewWillAppear:(BOOL)animated {
	UIColor *tintColor = [UIColor blackColor];
	self.view.tintColor = tintColor;
    self.navigationController.navigationBar.tintColor = tintColor;
}

-(void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	self.view.tintColor = nil;
	self.navigationController.navigationBar.tintColor = nil;
}

@end