#import "CREditTextCell.h"

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
	return YES;
}

@end
