#import "CRSegmentTableCell.h"

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