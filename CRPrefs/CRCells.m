#import "CRPrefs.h"

@implementation CRCreditsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) {
		NSString *rawCredits = @"Circlet (1.2) was created by Julian Weiss with lots of love from Benno, A³Tweaks, and the entire Hashbang crew. Uses NKOColorPickerView and UIDiscreteSlider for finer settings control. Inspired by the awesome members of /r/jailbreak. To stay updated on Circlet (and many other projects), make sure to follow me on Twitter. Enjoy!";

		if (IPAD) {
			[self setTitle:rawCredits];

			UILabel *titleLabel = (UILabel *) [self titleTextLabel];
			titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
			titleLabel.numberOfLines = 0;
		}

		else {
			CGFloat padding = 5.0, savedHeight = 116.0;

			_plainTextView = [[UITextView alloc] initWithFrame:CGRectMake(padding, MODERN_IOS ? 0.0 : padding, self.frame.size.width - (padding * 2.0), savedHeight)];
			self.clipsToBounds = _plainTextView.clipsToBounds = NO;
			_plainTextView.backgroundColor = [UIColor clearColor];
			_plainTextView.userInteractionEnabled = YES;
			_plainTextView.scrollEnabled = NO;
			_plainTextView.editable = NO;
			_plainTextView.delegate = self;
		
			NSMutableAttributedString *clickable = [[[NSMutableAttributedString alloc] initWithString:rawCredits attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:[UIFont smallSystemFontSize]]}] autorelease];
			
			if (MODERN_IOS) {
				[clickable setAttributes:@{ NSLinkAttributeName : [NSURL URLWithString:@"http://insanj.com/"]} range:[clickable.string rangeOfString:@"Julian Weiss"]];
				[clickable setAttributes:@{ NSLinkAttributeName : [NSURL URLWithString:@"http://bensge.com/"]} range:[clickable.string rangeOfString:@"Benno"]];
				[clickable setAttributes:@{ NSLinkAttributeName : [NSURL URLWithString:@"http://www.a3tweaks.com/"]} range:[clickable.string rangeOfString:@"A³Tweaks"]];
				[clickable setAttributes:@{ NSLinkAttributeName : [NSURL URLWithString:@"http://hbang.ws/"]} range:[clickable.string rangeOfString:@"Hashbang crew"]];
				[clickable setAttributes:@{ NSLinkAttributeName : [NSURL URLWithString:@"https://github.com/FWCarlos/NKO-Color-Picker-View-iOS"]} range:[clickable.string rangeOfString:@"NKOColorPickerView"]];	
				[clickable setAttributes:@{ NSLinkAttributeName : [NSURL URLWithString:@"https://github.com/philliptharris/UIDiscreteSlider"]} range:[clickable.string rangeOfString:@"UIDiscreteSlider"]];		
				[clickable setAttributes:@{ NSLinkAttributeName : [NSURL URLWithString:@"http://reddit.com/r/jailbreak"]} range:[clickable.string rangeOfString:@"/r/jailbreak"]];
				[clickable setAttributes:@{ NSLinkAttributeName : [NSURL URLWithString:@"http://twitter.com/insanj"]} range:[clickable.string rangeOfString:@"on Twitter"]];
				_plainTextView.linkTextAttributes = @{ NSForegroundColorAttributeName : [UIColor colorWithRed:68/255.0 green:132/255.0 blue:231/255.0 alpha:1.0] };
			}

			// _plainTextView.dataDetectorTypes = UIDataDetectorTypeLink;
			_plainTextView.attributedText = clickable;

			[self addSubview:_plainTextView];
		}
	}

	return self;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
	return YES;
}

- (void)dealloc {
	_plainTextView = nil;
	[_plainTextView release];

	[super dealloc];
}

@end

@implementation CREditTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	// styles: 0, 4, 8... invisible
	//		   1 normal label, no input
	//		   2 tiny blue text, no input
	//		   1000 default, normal label, small black aligned left
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];
	return self;
}

- (BOOL)textFieldShouldReturn:(id)arg1 {
	/*UIStatusBar *statusBar = (UIStatusBar *)[[UIApplication sharedApplication] statusBar];
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
		CRLOG(@"Animating out...");
		
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
*/
	return YES;
}

@end

@implementation CRSegmentTableCell

- (void)layoutSubviews {
	[super layoutSubviews];

	// Break the deadlock
	self.control.frame = CGRectInset(self.control.frame, 8.0, 0.0);
	// self.control.center = CGPointMake(self.control.center.x, self.center.y / 2.0);
}

- (void)setSeparatorStyle:(int)style {
	[super setSeparatorStyle:1];
}

@end

@implementation CRSliderTableCell

- (id)initWithStyle:(int)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3 {
	self = [super initWithStyle:arg1 reuseIdentifier:arg2 specifier:arg3];
	
	if (self) {		
		UIDiscreteSlider *replacementSlider = [[UIDiscreteSlider alloc] initWithFrame:self.control.frame];
		[replacementSlider addTarget:self action:@selector(saveSliderValue) forControlEvents:UIControlEventTouchUpInside];
		replacementSlider.increment = 1.0;

		[self setControl:replacementSlider];
	}

	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];

	NSNumber *value = [[CRPrefsManager sharedManager] numberForKey:[[self specifier] propertyForKey:@"key"]];
	UIDiscreteSlider *slider = (UIDiscreteSlider *) self.control;
	slider.value = value ? [value floatValue] : 5.0;

	CRLOG(@"Set prev-saved slider value as: %@", value);
}

- (void)saveSliderValue {
	UIDiscreteSlider *slider = (UIDiscreteSlider *) self.control;
	NSNumber *value = @(slider.value);
	[[CRPrefsManager sharedManager] setObject:value forKey:[[self specifier] propertyForKey:@"key"]];

	CRLOG(@"Saved slider value as: %@", value);
}

@end
