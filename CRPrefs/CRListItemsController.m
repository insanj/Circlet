#import "CRPrefs.h"
#import "../UIImage+Circlet.h"

@implementation CRListItemsController

- (void)loadView {
	_safeTitleToColor = [CRTITLETOCOLOR retain];
	[super loadView];
}

- (id)tableView:(UITableView *)arg1 cellForRowAtIndexPath:(NSIndexPath *)arg2 {
	PSTableCell *cell = [super tableView:arg1 cellForRowAtIndexPath:arg2];

	CGFloat percent = ((CGFloat)arg2.row + 1.0) / (CGFloat)[arg1 numberOfRowsInSection:arg2.section];
	UIImage *circletImage = [UIImage circletWithColor:[_safeTitleToColor objectForKey:[[cell titleLabel] text]] radius:10.0 percentage:percent style:CircletStyleRadial];

	[cell.imageView setImage:circletImage];
	return cell;
}

- (void)viewWillAppear:(BOOL)animated {
	self.view.tintColor = CRTINTCOLOR;
    self.navigationController.navigationBar.tintColor = CRTINTCOLOR;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	self.view.tintColor = nil;
	self.navigationController.navigationBar.tintColor = nil;
}

@end
