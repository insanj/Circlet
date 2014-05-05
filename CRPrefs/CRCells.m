#import "CRPrefs.h"

@implementation CRCreditsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) {
		CGFloat padding = 5.0, savedHeight = 94.0;

		_plainTextView = [[UITextView alloc] initWithFrame:CGRectMake(padding, 0.0, self.frame.size.width - (padding * 2.0), savedHeight)];
		self.clipsToBounds = _plainTextView.clipsToBounds = NO;
		_plainTextView.backgroundColor = [UIColor clearColor];
		_plainTextView.userInteractionEnabled = YES;
		_plainTextView.scrollEnabled = NO;
		_plainTextView.editable = NO;
		_plainTextView.delegate = self;
	
		NSMutableAttributedString *clickable = [[[NSMutableAttributedString alloc] initWithString:@"Circlet (1.0) was created by Julian Weiss with lots of love from Benno, A³Tweaks, and the entire Hashbang crew. Inspired by the awesome members of /r/jailbreak. To stay updated on Circlet (and many other projects), make sure to follow me on Twitter. Enjoy!" attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:[UIFont smallSystemFontSize]]}] autorelease];
		[clickable setAttributes:@{ NSLinkAttributeName : [NSURL URLWithString:@"http://insanj.com/"]} range:[clickable.string rangeOfString:@"Julian Weiss"]];
		[clickable setAttributes:@{ NSLinkAttributeName : [NSURL URLWithString:@"http://bensge.com/"]} range:[clickable.string rangeOfString:@"Benno"]];
		[clickable setAttributes:@{ NSLinkAttributeName : [NSURL URLWithString:@"http://www.a3tweaks.com/"]} range:[clickable.string rangeOfString:@"A³Tweaks"]];
		[clickable setAttributes:@{ NSLinkAttributeName : [NSURL URLWithString:@"http://hbang.ws/"]} range:[clickable.string rangeOfString:@"Hashbang Crew"]];
		[clickable setAttributes:@{ NSLinkAttributeName : [NSURL URLWithString:@"http://reddit.com/r/jailbreak"]} range:[clickable.string rangeOfString:@"/r/jailbreak"]];
		[clickable setAttributes:@{ NSLinkAttributeName : [NSURL URLWithString:@"http://twitter.com/insanj"]} range:[clickable.string rangeOfString:@"on Twitter"]];
	
		_plainTextView.dataDetectorTypes = UIDataDetectorTypeLink;
		_plainTextView.linkTextAttributes = @{ NSForegroundColorAttributeName : [UIColor colorWithRed:68/255.0 green:132/255.0 blue:231/255.0 alpha:1.0] };
		_plainTextView.attributedText = clickable;

		[self addSubview:_plainTextView];
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
