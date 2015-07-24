#import "CRSliderTableCell.h"

@implementation CRSliderTableCell

- (id)initWithStyle:(UITableViewCellStyle)arg1 reuseIdentifier:(NSString *)arg2 specifier:(PSSpecifier *)arg3 {
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

	HBPreferences *preferences = [[HBPreferences alloc] initWithIdentifier:@"com.insanj.circlet"];
	CGFloat value = [preferences floatForKey:[[self specifier] propertyForKey:@"key"] default:5.0];
	
	UIDiscreteSlider *slider = (UIDiscreteSlider *) self.control;
	slider.value = value;
}

- (void)saveSliderValue {
	UIDiscreteSlider *slider = (UIDiscreteSlider *) self.control;
	CGFloat value = slider.value;

	HBPreferences *preferences = [[HBPreferences alloc] initWithIdentifier:@"com.insanj.circlet"];
	[preferences setFloat:value forKey:[[self specifier] propertyForKey:@"key"]];
}

@end
