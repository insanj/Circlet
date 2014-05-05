#import "CRPrefs.h"

@implementation CRListItemsController

- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2 {
	PSTableCell *cell = [super tableView:arg1 cellForRowAtIndexPath:arg2];

	CRItemPrefsListController *parent = (CRItemPrefsListController *) [self parentController];
	CRLOG(@"parent: %@", parent);
	NSDictionary *titleToColor = parent.titleToColor;
	CRLOG(@"titleToColor: %@", titleToColor);
	UIColor *color = [titleToColor objectForKey:[[cell titleLabel] text]];
	CRLOG(@"color: %@", color);

	UIView *colorThumb = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 20.0, 20.0)];
	colorThumb.backgroundColor = color;
	colorThumb.layer.masksToBounds = YES;
	colorThumb.layer.cornerRadius = 10.0;
	colorThumb.layer.borderColor = [UIColor lightGrayColor].CGColor;
	colorThumb.layer.borderWidth = 1.0;

	UIGraphicsBeginImageContextWithOptions(colorThumb.bounds.size, NO, 0.0);
	[colorThumb.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	[colorThumb release];
	[cell.imageView setImage:image];
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
