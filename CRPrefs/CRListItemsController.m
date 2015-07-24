#import "CRListItemsController.h"

@implementation CRListItemsController

- (id)tableView:(UITableView *)arg1 cellForRowAtIndexPath:(NSIndexPath *)arg2 {
	PSTableCell *cell = [super tableView:arg1 cellForRowAtIndexPath:arg2];
	CGFloat percent = ((CGFloat)arg2.row + 1.0) / (CGFloat)[arg1 numberOfRowsInSection:arg2.section];
	NSString *title = [[cell titleLabel] text];
	UIColor *color;

	if (arg2.row == 0) {
		NSString *key = [[self specifier] propertyForKey:@"key"];
		HBPreferences *preferences = [[HBPreferences alloc] initWithIdentifier:@"com.insanj.circlet"];
		NSString *colorString = [preferences objectForKey:[key stringByAppendingString:@"Custom"]];
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
		CGFloat radius = 10.0, border = 0.5;
		UIImage *outerCirclet = [UIImage circletWithColor:[UIColor lightGrayColor] radius:radius percentage:percent style:CircletStyleRadial];
		UIImage *middleCirclet = [UIImage circletWithColor:[UIColor whiteColor] radius:(radius - border) percentage:percent style:CircletStyleRadial];
		UIImage *innerCirclet = [UIImage circletWithColor:[UIColor lightGrayColor] radius:(radius - border) percentage:percent style:CircletStyleRadial thickness:((radius * 2.0) / 8.0)];

		UIGraphicsBeginImageContextWithOptions(outerCirclet.size, NO, [UIScreen mainScreen].scale);
		[outerCirclet drawAtPoint:CGPointZero];
		[innerCirclet drawAtPoint:CGPointMake(border / 2.0, border / 2.0)];
		[middleCirclet drawAtPoint:CGPointMake(border, border)];
		UIImage *comboCirclet = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();

		[cell.imageView setImage:comboCirclet];
		return cell;
	}

	else {
		color = [CRTITLETOCOLOR objectForKey:title];
	}

	UIImage *circletImage = [UIImage circletWithColor:color radius:10.0 percentage:percent style:CircletStyleRadial];
	[cell.imageView setImage:circletImage];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];

	if (indexPath.row == 0) {	
		NSString *key = [[self specifier] propertyForKey:@"key"];
		HBPreferences *preferences = [[HBPreferences alloc] initWithIdentifier:@"com.insanj.circlet"];
		NSString *colorString = [preferences objectForKey:[key stringByAppendingString:@"Custom"]];
		
		UIColor *customColor;
		if (!colorString) {
			customColor = [UIColor colorWithRed:52/255.0 green:53/255.0 blue:46/255.0 alpha:1.0];;
		}

		else {
			CIColor *customCIColor = [CIColor colorWithString:colorString];
			customColor = [UIColor colorWithRed:customCIColor.red green:customCIColor.green blue:customCIColor.blue alpha:customCIColor.alpha];
		}

		NSString *messageFiller = MODERN_IOS ? nil : @"\n\n\n\n";

		// Using -initWithFrame: will yield no useful result
		_pickerAlertView = [[UIAlertView alloc] initWithTitle:nil message:messageFiller delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
		_pickerAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
	
		UITextField *colorField = [_pickerAlertView textFieldAtIndex:0];
		colorField.delegate = self;
		// colorField.keyboardType = UIKeyboardTypeDefault;
		// colorField.keyboardAppearance = UIKeyboardAppearanceDark;
		
		const CGFloat *colorComponents = CGColorGetComponents(customColor.CGColor);
		NSString *hexString = [NSString stringWithFormat:@"#%02X%02X%02X", (int)(colorComponents[0] * 255), (int)(colorComponents[1] * 255), (int)(colorComponents[2] * 255)];
		colorField.text = hexString;

		CGFloat pickerHeight = IPAD ? 115.0 : self.view.frame.size.height / (MODERN_IOS ? 3.0 : 3.5);

		NKOColorPickerView *pickerView = [[NKOColorPickerView alloc] initWithFrame:CGRectMake(0.0, 0.0, 270.0, pickerHeight) color:customColor andDidChangeColorBlock:^(UIColor *color) {
			const CGFloat *colorComponents = CGColorGetComponents(color.CGColor);
			NSString *hexString = [NSString stringWithFormat:@"#%02X%02X%02X", (int)(colorComponents[0] * 255), (int)(colorComponents[1] * 255), (int)(colorComponents[2] * 255)];
			
			if (colorField.text.length == 7 && ![hexString isEqualToString:colorField.text]) {
				colorField.text = hexString;
			}
		}];

		if (MODERN_IOS) {
			[_pickerAlertView setValue:pickerView forKey:@"accessoryView"];
		}

		else {
			pickerView.tag = 913;
			[_pickerAlertView addSubview:pickerView];
		}

		[_pickerAlertView show];
	}
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if (string.length == 7) { // If the picker is trying to fit in a color
		return NO;
	}
	
	else if (range.location == 0) { // If the user is trying to remove the #
		textField.text = @"#";
		return NO;
	}
	
	else if (range.location > 6) { // If the user is trying to input more than 6 characters
		return NO;
	}
	
	NSScanner *colorScanner = [NSScanner scannerWithString:[textField.text substringFromIndex:1]];
	
	unsigned int pickerColor;
	[colorScanner scanHexInt:&pickerColor];
	CGFloat red = ((pickerColor & 0xFF0000) >> 16) / 255.0;
	CGFloat green = ((pickerColor & 0x00FF00) >>  8) / 255.0;
	CGFloat blue  = (pickerColor & 0x0000FF) / 255.0;
	
	UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
	NKOColorPickerView *colorPickerView = MODERN_IOS ? (NKOColorPickerView *)[_pickerAlertView valueForKey:@"accessoryView"] : (NKOColorPickerView *)[_pickerAlertView viewWithTag:913];
	[colorPickerView setColor:color];

	return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex != [alertView cancelButtonIndex]) {
		NKOColorPickerView *picker = MODERN_IOS ? (NKOColorPickerView *)[alertView valueForKey:@"accessoryView"] : (NKOColorPickerView *)[alertView viewWithTag:913];
		CIColor *color = [CIColor colorWithCGColor:picker.color.CGColor];

		NSString *key = [[self specifier] propertyForKey:@"key"];
		NSString *colorKey = [key stringByAppendingString:@"Custom"];

		HBPreferences *preferences = [[HBPreferences alloc] initWithIdentifier:@"com.insanj.circlet"];
		[preferences setObject:[color stringRepresentation] forKey:colorKey];
		[[self table] reloadData];
	}
}

- (void)dealloc {
	[_pickerAlertView release];
	[super dealloc];
}

@end
