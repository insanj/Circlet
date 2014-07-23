//
//  UIImage+Circlet.m
//  Circlet
//
//  Created by Julian Weiss on 5/3/14.
//  Copyright (c) 2014 Julian Weiss. All rights reserved.
//

#import "UIImage+Circlet.h"
#define CIRCLET_FONT @"HelveticaNeue-Medium"

static NSCache *circlet_cache;

static inline NSString *stringRepresentationOfColor(UIColor *color)
{
	CGFloat r, g, b, a;
	[color getRed:&r green:&g blue: &b alpha: &a];

	NSInteger redValue = (NSInteger)(255.0 * r);
    NSInteger greenValue = (NSInteger)(255.0 * g);
    NSInteger blueValue = (NSInteger)(255.0 * b);
    NSInteger alphaValue = (NSInteger)(255.0 * a);

    return [NSString stringWithFormat:@"%02lx%02lx%02lx%02lx", (long)redValue, (long)greenValue, (long)blueValue, (long)alphaValue];
}

@implementation UIImage (Circlet)

+ (void)initialize
{
	circlet_cache = [[NSCache alloc] init];
	[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(__unused NSNotification *note) {
        [circlet_cache removeAllObjects];
    }];
}

+ (UIImage *)circletWithColor:(UIColor *)color radius:(CGFloat)radius percentage:(CGFloat)percent style:(CircletStyle)style {

	NSString *cacheKey = [NSString stringWithFormat:@"Image-%@-%f-%f-%li", stringRepresentationOfColor(color), radius, percent, (long)style];

	UIImage *image = [circlet_cache objectForKey:cacheKey];
	if (image == nil)
	{
		image = [self circletWithColor:color radius:radius percentage:percent style:style thickness:((radius * 2.0) / 10.0)];
		[circlet_cache setObject:image forKey:cacheKey];
	}

	return image;
}

+ (UIImage *)circletWithColor:(UIColor *)color radius:(CGFloat)radius percentage:(CGFloat)percent style:(CircletStyle)style thickness:(CGFloat)thickness {

	NSString *cacheKey = [NSString stringWithFormat:@"Image-%@-%f-%f-%li-%f", stringRepresentationOfColor(color), radius, percent, (long)style, thickness];

	UIImage *image = [circlet_cache objectForKey:cacheKey];
	if (image == nil)
	{
		CGFloat diameter = (radius * 2.0) + thickness;
		// CGRect frame = (CGRect){CGPointMake(thickness / 2.0, thickness / 2.0), CGSizeMake(diameter, diameter)};
		CGRect bounds = (CGRect){CGPointZero, CGSizeMake(diameter, diameter)};
		CGPoint center = CGPointMake(bounds.size.width / 2.0, bounds.size.height / 2.0);
		CGColorRef colorRef = color.CGColor; // Light color

		UIGraphicsBeginImageContextWithOptions(bounds.size, NO, [UIScreen mainScreen].scale);
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGContextSetShouldAntialias(context, YES);

		// Creates outline of circle with calculated thickness as additional pixels
		CGContextSetLineWidth(context, thickness);
		CGContextSetStrokeColorWithColor(context, colorRef);

		// ➉ 
		if (style == CircletStyleTextual) {
			return [self circletWithColor:color radius:radius string:[NSString stringWithFormat:@"%i", (int)percent] invert:NO thickness:thickness];
		}

		// ➓
		else if (style == CircletStyleTextualInverse) {
			return [self circletWithColor:color radius:radius string:[NSString stringWithFormat:@"%i", (int)percent] invert:YES thickness:thickness];
		}

		// ⚬
		else if (style == CircletStyleConcentricInverse) {
			CGContextAddArc(context, center.x, center.y, radius * percent, 0.0, M_PI * 2, YES);
			CGContextStrokePath(context);
		}

		else {
			CGContextAddArc(context, center.x, center.y, radius, 0.0, M_PI * 2, YES);
			CGContextSetFillColorWithColor(context, colorRef);
			CGContextStrokePath(context);
			
			// Applies inversion settings, or properly deducts percentage amount
			switch (style) {
				default:
				case CircletStyleRadial:
				case CircletStyleTextual:
				case CircletStyleTextualInverse:
					break;
				case CircletStyleFill:
					percent = /* percent >= 0.99 ? .01 : */ fabs(0.999 - percent);
					break;
				case CircletStyleConcentric:
					percent = 1.0 - percent;
					break;
				case CircletStyleRadialInverse:
				case CircletStyleFillInverse:
				case CircletStyleConcentricInverse:
					percent -= 1.0;
					break;
			}
			
			// ◔
			if (style == CircletStyleRadial) {
				CGFloat startAngle = -M_PI_2, endAngle = -M_PI_2 + (2 * M_PI * percent);
				CGPoint endPoint = CGPointMake(center.x + radius * cos(startAngle), center.y + radius * sin(startAngle));
				UIBezierPath *arc = [UIBezierPath bezierPath];
				[arc moveToPoint:center];
				[arc addLineToPoint:endPoint];
				[arc addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
				[arc addLineToPoint:center];
				[arc fill];
			}
			
			// ◕
			else if (style == CircletStyleRadialInverse) {
				CGFloat startAngle = -M_PI_2, endAngle = -M_PI_2 + ((2 * M_PI) * percent);
				CGPoint endPoint = CGPointMake(center.x + radius * cos(startAngle), center.y + radius * sin(startAngle));
				UIBezierPath *arc = [UIBezierPath bezierPath];
				[arc moveToPoint:center];
				[arc addLineToPoint:endPoint];
				[arc addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:NO];
				[arc addLineToPoint:center];
				[arc fill];
			}
			
			// ◒ or ◓
			else if (style == CircletStyleFill || style == CircletStyleFillInverse) {
				CGContextAddArc(context, center.x, center.y, radius - thickness, M_PI_2 * (3 - (2 * percent)), M_PI_2 * (3 + (2 * percent)), YES);
			}
			
			// ⦿
			else if (style == CircletStyleConcentric) {
				CGFloat inset = percent * (radius + (thickness / 2.0)) ;
				CGRect minor = CGRectInset(bounds, inset, inset);
				CGContextAddEllipseInRect(context, minor);
			}
		}

		CGContextDrawPath(context, kCGPathFill);
		image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();

		[circlet_cache setObject:image forKey:cacheKey];
	}
	
	return image;
}

+ (UIImage *)doubleCircletWithLeftColor:(UIColor *)leftColor rightColor:(UIColor *)rightColor radius:(CGFloat)radius leftPercentage:(CGFloat)leftPercent rightPercentage:(CGFloat)rightPercent style:(CircletStyle)style {

	NSString *cacheKey = [NSString stringWithFormat:@"Image-%@-%@-%f-%f-%f-%li", stringRepresentationOfColor(leftColor), stringRepresentationOfColor(rightColor), radius, leftPercent, rightPercent, (long)style];

	UIImage *image = [circlet_cache objectForKey:cacheKey];
	if (image == nil)
	{
		image = [self doubleCircletWithLeftColor:leftColor rightColor:rightColor radius:radius leftPercentage:leftPercent rightPercentage:rightPercent style:style thickness:(radius / 10.0)];
		[circlet_cache setObject:image forKey:cacheKey];
	}
	return image;
}

+ (UIImage *)doubleCircletWithLeftColor:(UIColor *)leftColor rightColor:(UIColor *)rightColor radius:(CGFloat)radius leftPercentage:(CGFloat)leftPercent rightPercentage:(CGFloat)rightPercent style:(CircletStyle)style thickness:(CGFloat)thickness {

	NSString *cacheKey = [NSString stringWithFormat:@"Image-%@-%@-%f-%f-%f-%li-%f", stringRepresentationOfColor(leftColor), stringRepresentationOfColor(rightColor), radius, leftPercent, rightPercent, (long)style, thickness];

	UIImage *image = [circlet_cache objectForKey:cacheKey];
	if (image == nil)
	{
		CGFloat smallRadius = (radius / 2.0) + thickness;
		
		UIImage *leftCirclet = [UIImage circletWithColor:leftColor radius:smallRadius percentage:leftPercent style:style thickness:thickness];
		UIImage *rightCirclet = [UIImage circletWithColor:rightColor radius:smallRadius percentage:rightPercent style:style thickness:thickness];
		
		CGSize doubleSize = CGSizeMake(leftCirclet.size.width + rightCirclet.size.width + thickness, (smallRadius * 2.0) + thickness);
		UIGraphicsBeginImageContextWithOptions(doubleSize, NO, [UIScreen mainScreen].scale);
		[leftCirclet drawAtPoint:CGPointZero blendMode:kCGBlendModeMultiply alpha:1.0];
		[rightCirclet drawAtPoint:CGPointMake(leftCirclet.size.width + thickness, 0.0) blendMode:kCGBlendModeMultiply alpha:1.0];
		image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		[circlet_cache setObject:image forKey:cacheKey];
	}
	return image;
}

+ (UIImage *)doubleCircletWithLeftColor:(UIColor *)leftColor rightColor:(UIColor *)rightColor radius:(CGFloat)radius leftString:(NSString *)leftString rightString:(NSString *)rightString style:(CircletStyle)style {

	NSString *cacheKey = [NSString stringWithFormat:@"Image-%@-%@-%f-%@-%@-%li", stringRepresentationOfColor(leftColor), stringRepresentationOfColor(rightColor), radius, leftString, rightString, (long)style];

	UIImage *image = [circlet_cache objectForKey:cacheKey];
	if (image == nil)
	{
		image = [self doubleCircletWithLeftColor:leftColor rightColor:rightColor radius:radius leftString:leftString rightString:rightString style:style thickness:(radius / 10.0)];
		[circlet_cache setObject:image forKey:cacheKey];
	}

	return image;
}

+ (UIImage *)doubleCircletWithLeftColor:(UIColor *)leftColor rightColor:(UIColor *)rightColor radius:(CGFloat)radius leftString:(NSString *)leftString rightString:(NSString *)rightString style:(CircletStyle)style thickness:(CGFloat)thickness {
	NSString *cacheKey = [NSString stringWithFormat:@"Image-%@-%@-%f-%@-%@-%li-%f", stringRepresentationOfColor(leftColor), stringRepresentationOfColor(rightColor), radius, leftString, rightString, (long)style, thickness];

	UIImage *image = [circlet_cache objectForKey:cacheKey];
	if (image == nil)
	{
		CGFloat smallRadius = (radius / 2.0) + thickness;
		BOOL invert = style == CircletStyleTextualInverse;

		UIImage *leftCirclet = [UIImage circletWithColor:leftColor radius:smallRadius string:leftString invert:invert thickness:thickness];
		UIImage *rightCirclet = [UIImage circletWithColor:rightColor radius:smallRadius string:rightString invert:invert thickness:thickness];
		
		CGSize doubleSize = CGSizeMake(leftCirclet.size.width + rightCirclet.size.width + thickness, (smallRadius * 2.0) + thickness);
		UIGraphicsBeginImageContextWithOptions(doubleSize, NO, [UIScreen mainScreen].scale);
		[leftCirclet drawAtPoint:CGPointZero blendMode:kCGBlendModeMultiply alpha:1.0];
		[rightCirclet drawAtPoint:CGPointMake(leftCirclet.size.width + thickness, 0.0) blendMode:kCGBlendModeMultiply alpha:1.0];
		image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		[circlet_cache setObject:image forKey:cacheKey];
	}

	return image;
}

+ (UIImage *)circletWithColor:(UIColor *)color radius:(CGFloat)radius string:(NSString *)string invert:(BOOL)invert {
	NSString *cacheKey = [NSString stringWithFormat:@"Image-%@-%f-%@-%li", stringRepresentationOfColor(color), radius, string, (long)invert];

	UIImage *image = [circlet_cache objectForKey:cacheKey];
	if (image == nil)
	{
		CGFloat diameter = radius * 2.0;
		image = [self circletWithColor:color radius:radius string:string invert:invert thickness:(diameter / 10.0)];
		[circlet_cache setObject:image forKey:cacheKey];
	}
	return image;
}

+ (UIImage *)circletWithColor:(UIColor *)color radius:(CGFloat)radius string:(NSString *)string invert:(BOOL)invert thickness:(CGFloat)thickness {
	NSString *cacheKey = [NSString stringWithFormat:@"Image-%@-%f-%@-%li-%f", stringRepresentationOfColor(color), radius, string, (long)invert, thickness];

	UIImage *image = [circlet_cache objectForKey:cacheKey];
	if (image == nil)
	{
		CGFloat diameter = (radius * 2.0) + thickness;
		CGRect frame = (CGRect){CGPointMake(ceilf(thickness / 2.0), ceilf(thickness / 2.0)), CGSizeMake(diameter, diameter)};
		CGRect bounds = (CGRect){CGPointZero, CGSizeMake(diameter, diameter)};
		CGPoint center = CGPointMake(bounds.size.width / 2.0, bounds.size.height / 2.0);
		CGColorRef colorRef = color.CGColor; // Light color
		
		UIGraphicsBeginImageContextWithOptions(bounds.size, NO, [UIScreen mainScreen].scale);
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGContextSetShouldAntialias(context, YES);
		
		// Creates outline of circle with calculated thickness as additional pixels
		CGContextSetLineWidth(context, thickness);
	    CGContextSetStrokeColorWithColor(context, colorRef);
		
		CGContextAddArc(context, center.x, center.y, radius, 0.0, M_PI * 2, YES);
		CGContextSetFillColorWithColor(context, colorRef);
		CGContextStrokePath(context);
		
		CGFloat circletTextSize = [self circletLargestFontSizeForString:string inFrame:frame prediction:diameter / string.length];
		UIFont *circletTextFont = [UIFont fontWithName:CIRCLET_FONT size:circletTextSize];
		NSMutableParagraphStyle *circletTextParagraphStyle = [[NSMutableParagraphStyle alloc] init];
		circletTextParagraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
		circletTextParagraphStyle.alignment = NSTextAlignmentCenter;
		
		NSAttributedString *circletAttributedText = [[NSAttributedString alloc] initWithString:string attributes:@{ NSFontAttributeName : circletTextFont, NSForegroundColorAttributeName : color, NSParagraphStyleAttributeName : circletTextParagraphStyle }];
		
		// CGPoint circletDrawPoint = center;
		// circletDrawPoint.x -= circletAttributedText.size.width / 2.0;
		// circletDrawPoint.y -= circletAttributedText.size.height / 1.9;
		
		if (invert) {
			CGContextFillEllipseInRect(context, bounds);
			CGContextSetBlendMode(context, kCGBlendModeDestinationOut);
		}
		
		CGRect circletCenterFrame = bounds;
		circletCenterFrame.origin.y = (frame.size.height - [circletAttributedText size].height) / 2.0;
		[circletAttributedText drawInRect:circletCenterFrame];
		
		CGContextDrawPath(context, kCGPathFill);
		image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		[circlet_cache setObject:image forKey:cacheKey];
	}
	
	return image;
}

+ (CGFloat)circletLargestFontSizeForString:(NSString *)string inFrame:(CGRect)frame prediction:(CGFloat)pointSize {

	NSString *cacheKey = [NSString stringWithFormat:@"FontSize-%@-%@-%f", string, NSStringFromCGRect(frame), pointSize];
	NSNumber *finalPointSize = [circlet_cache objectForKey:cacheKey];

	if (finalPointSize == nil)
	{
		UIFont *font = [UIFont fontWithName:CIRCLET_FONT size:pointSize];
		CGSize stringSize = [string sizeWithFont:font];
		CGFloat widthCeiling = frame.size.width - 2.0, heightCeiling = frame.size.height - 2.0;
		
	    while (stringSize.width > widthCeiling|| stringSize.height > heightCeiling) {
	        font = [UIFont fontWithName:CIRCLET_FONT size:font.pointSize - 1.0];
	        stringSize = [string sizeWithFont:font];
	    }
	    finalPointSize = [NSNumber numberWithFloat:font.pointSize];
	    [circlet_cache setObject:finalPointSize forKey:cacheKey];
	}
	
    return [finalPointSize floatValue];
}

@end
