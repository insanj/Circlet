#import "CRPrefs.h"
#import "../UIImage+Circlet.h"

@implementation CRListItemsController

- (void)loadView {
	_safeTitleToColor = [CRTITLETOCOLOR retain];
	[super loadView];
}

- (id)tableView:(UITableView *)arg1 cellForRowAtIndexPath:(NSIndexPath *)arg2 {
	PSTableCell *cell = [super tableView:arg1 cellForRowAtIndexPath:arg2];

	UIColor *color;
	if (arg2.row == 0) {
		NSString *key = [[self specifier] propertyForKey:@"key"];
		NSString *colorString = CRVALUE([key stringByAppendingString:@"Custom"]);
		if (!colorString) {
			color = [UIColor clearColor];
		}
		
		else {
			CIColor *customColor = [CIColor colorWithString:colorString];
			color = [UIColor colorWithRed:customColor.red green:customColor.green blue:customColor.blue alpha:customColor.alpha];
		}
	}

	else {
		color = [_safeTitleToColor objectForKey:[[cell titleLabel] text]];
	}

	CGFloat percent = ((CGFloat)arg2.row + 1.0) / (CGFloat)[arg1 numberOfRowsInSection:arg2.section];
	UIImage *circletImage = [UIImage circletWithColor:color radius:10.0 percentage:percent style:CircletStyleRadial];

	[cell.imageView setImage:circletImage];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];

	if (indexPath.row == 0) {
		UIAlertView *picker = [[UIAlertView alloc] initWithTitle:@"Custom Color" message:@"What custom color would you like to use? Make sure your follow the RED, GREEN, BLUE, ALPHA, format!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
		picker.alertViewStyle = UIAlertViewStylePlainTextInput;

		UITextField *pickerField = [picker textFieldAtIndex:0];
		pickerField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
	    pickerField.placeholder = @"0.1 0.2 0.3 1.0";
	    [picker show];
	    [picker release];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex != [alertView cancelButtonIndex]) {
		NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithDictionary:CRSETTINGS];
		NSString *key = [[self specifier] propertyForKey:@"key"];
		NSString *colorKey = [key stringByAppendingString:@"Custom"];

		UITextField *pickerField = [alertView textFieldAtIndex:0];
		[settings setObject:pickerField.text forKey:colorKey];
		[settings writeToFile:CRPATH atomically:YES];
		[[self table] reloadData];
	}
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
