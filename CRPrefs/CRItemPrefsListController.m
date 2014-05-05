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
	NSMutableArray *titles = [[NSMutableArray alloc] initWithArray:[_titleToColor allKeys]];
	[titles removeObject:@"Black (Default)"];
	[titles removeObject:@"White"];
	return [titles sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (NSArray *)lightColorValues:(id)target {
	return [self lightColorTitles:target];
}

- (NSArray *)darkColorTitles:(id)target {
	NSMutableArray *titles = [[NSMutableArray alloc] initWithArray:[_titleToColor allKeys]];
	[titles removeObject:@"Black"];
	[titles removeObject:@"White (Default)"];
	return [titles sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (NSArray *)darkColorValues:(id)target {
	return [self darkColorTitles:target];
}

@end