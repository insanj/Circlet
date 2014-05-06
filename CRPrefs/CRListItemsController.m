#import "CRPrefs.h"
#import "../UIImage+Circlet.h"
#import "NKOColorPickerView.h"

@implementation CRListItemsController

- (void)loadView {
	_safeTitleToColor = [CRTITLETOCOLOR retain];
	[super loadView];
}

- (void)viewWillAppear:(BOOL)animated {
	self.view.tintColor = CRTINTCOLOR;
    self.navigationController.navigationBar.tintColor = CRTINTCOLOR;
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	self.view.tintColor = nil;
	self.navigationController.navigationBar.tintColor = nil;
}

- (id)tableView:(UITableView *)arg1 cellForRowAtIndexPath:(NSIndexPath *)arg2 {
	PSTableCell *cell = [super tableView:arg1 cellForRowAtIndexPath:arg2];

	NSString *title = [[cell titleLabel] text];
	UIColor *color;
	if (arg2.row == 0) {
		NSString *key = [[self specifier] propertyForKey:@"key"];
		NSString *colorString = CRVALUE([key stringByAppendingString:@"Custom"]);
		if (!colorString) {
			[cell.imageView setImage:[UIImage imageNamed:@"rainbow.png" inBundle:[NSBundle bundleForClass:self.class]]];
			return cell;
		}

		else {
			CIColor *customColor = [CIColor colorWithString:colorString];
			color = [UIColor colorWithRed:customColor.red green:customColor.green blue:customColor.blue alpha:customColor.alpha];
		}
	}

	else if ([title isEqualToString:@"Clear"]) {
		[cell.imageView setImage:nil];
		return cell;
	}

	else {
		color = [_safeTitleToColor objectForKey:title];
	}

	CGFloat percent = ((CGFloat)arg2.row + 1.0) / (CGFloat)[arg1 numberOfRowsInSection:arg2.section];
	UIImage *circletImage = [UIImage circletWithColor:color radius:10.0 percentage:percent style:CircletStyleRadial];

	[cell.imageView setImage:circletImage];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];

	if (indexPath.row == 0) {	
		NSString *key = [[self specifier] propertyForKey:@"key"];
		NSString *colorString = CRVALUE([key stringByAppendingString:@"Custom"]);
		CIColor *customColor = [CIColor colorWithString:colorString];
		NKOColorPickerView *pickerView = [[NKOColorPickerView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width - 50.0, self.view.frame.size.height / 2.0) color:[UIColor colorWithRed:customColor.red green:customColor.green blue:customColor.blue alpha:customColor.alpha] andDidChangeColorBlock:nil];

		UIAlertView *pickerAlertView = [[UIAlertView alloc] initWithTitle:@"Custom Color" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
		[pickerAlertView setValue:pickerView forKey:@"accessoryView"];
		[pickerAlertView show];
		[pickerAlertView release];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex != [alertView cancelButtonIndex]) {
		NKOColorPickerView *picker = (NKOColorPickerView *)[alertView valueForKey:@"accessoryView"];
		CIColor *color = [CIColor colorWithCGColor:picker.color.CGColor];

		NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithDictionary:CRSETTINGS];
		NSString *key = [[self specifier] propertyForKey:@"key"];
		NSString *colorKey = [key stringByAppendingString:@"Custom"];

		[settings setObject:[color stringRepresentation] forKey:colorKey];
		[settings writeToFile:CRPATH atomically:YES];
		[settings release];

		[[self table] reloadData];
	}
}

@end
