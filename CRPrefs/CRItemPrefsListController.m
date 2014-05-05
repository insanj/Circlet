#import "CRPrefs.h"

@implementation CRItemPrefsListController

- (void)loadView {
	_titleToColor = CRTITLETOCOLOR;
	[super loadView];

	[UISwitch appearanceWhenContainedIn:self.class, nil].onTintColor = CRTINTCOLOR;
	[UISegmentedControl appearanceWhenContainedIn:self.class, nil].tintColor = CRTINTCOLOR;
}

- (void)viewWillAppear:(BOOL)animated {
	self.view.tintColor = CRTINTCOLOR;
	self.navigationController.navigationBar.tintColor = CRTINTCOLOR;
}

- (void)tableView:(id)arg1 didSelectRowAtIndexPath:(id)arg2 {
	[super tableView:arg1 didSelectRowAtIndexPath:arg2];
	[arg1 deselectRowAtIndexPath:arg2 animated:YES];
}

- (NSArray *)lightColorTitles:(id)target {
	NSMutableArray *titles = [[NSMutableArray alloc] initWithArray:[[_titleToColor allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
	[titles insertObject:@"Custom" atIndex:0];
	[titles removeObject:@"Black (Default)"];
	[titles removeObject:@"White"];
	return titles;
}

- (NSArray *)lightColorValues:(id)target {
	return [self lightColorTitles:target];
}

- (NSArray *)darkColorTitles:(id)target {
	NSMutableArray *titles = [[NSMutableArray alloc] initWithArray:[[_titleToColor allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
	[titles insertObject:@"Custom" atIndex:0];
	[titles removeObject:@"Black"];
	[titles removeObject:@"White (Default)"];
	return titles;
}

- (NSArray *)darkColorValues:(id)target {
	return [self darkColorTitles:target];
}

@end