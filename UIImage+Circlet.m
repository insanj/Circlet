//
//  UIImage+Circlet.m
//  testing
//
//  Created by Julian Weiss on 5/3/14.
//  Copyright (c) 2014 Julian Weiss. All rights reserved.
//

#import "UIImage+Circlet.h"
#define CIRCLET_FONT @"HelveticaNeue"

@implementation UIImage (Circlet)

+ (UIImage *)circletWithColor:(UIColor *)color radius:(CGFloat)radius percentage:(CGFloat)percent style:(CircletStyle)style {
	return [self circletWithColor:color radius:radius percentage:percent style:style thickness:((radius * 2.0) / 10.0)];
}

+ (UIImage *)circletWithColor:(UIColor *)color radius:(CGFloat)radius percentage:(CGFloat)percent style:(CircletStyle)style thickness:(CGFloat)thickness {
	CGFloat diameter = radius * 2.0;
	CGRect frame = (CGRect){CGPointMake(thickness / 2.0, thickness / 2.0), CGSizeMake(diameter, diameter)};
	CGRect bounds = (CGRect){CGPointZero, CGSizeMake(diameter + thickness, diameter + thickness)};
	CGPoint center = CGPointMake(bounds.size.width / 2.0, bounds.size.height / 2.0);
	CGColorRef colorRef = color.CGColor; // Light color
	
	UIGraphicsBeginImageContextWithOptions(bounds.size, NO, [UIScreen mainScreen].scale);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetShouldAntialias(context, YES);
	
	// Creates outline of circle with calculated thickness as additional pixels
	CGContextSetLineWidth(context, thickness);
    CGContextSetStrokeColorWithColor(context, colorRef);
	
	// ⚬
	if (style == CircletStyleConcentricInverse) {
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
			CGRect minor = CGRectInset(frame, percent * radius, percent * radius);
			CGContextAddEllipseInRect(context, minor);
		}
		
		// ➉ or ➓
		else {
			NSString *circletText = [NSString stringWithFormat:@"%i", (int)percent];
			CGFloat circletTextSize = [self circletLargestFontSizeForString:circletText inFrame:frame prediction:diameter / circletText.length];
			
			UIFont *circletTextFont = [UIFont fontWithName:CIRCLET_FONT size:circletTextSize];
			NSMutableParagraphStyle *circletTextParagraphStyle = [[NSMutableParagraphStyle alloc] init];
			circletTextParagraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
			circletTextParagraphStyle.alignment = NSTextAlignmentCenter;
			
			NSAttributedString *circletAttributedText = [[NSAttributedString alloc] initWithString:circletText attributes:@{ NSFontAttributeName : circletTextFont, NSForegroundColorAttributeName : color, NSParagraphStyleAttributeName : circletTextParagraphStyle }];
			
			if (style == CircletStyleTextualInverse) {
				CGContextFillEllipseInRect(context, frame);
				CGContextSetBlendMode(context, kCGBlendModeDestinationOut);
			}
			
			CGRect circletCenterFrame = frame;
			circletCenterFrame.origin.y = (thickness / 2.0) + ((frame.size.height - [circletAttributedText size].height) / 2.0);
			[circletAttributedText drawInRect:circletCenterFrame];
		}
	}
	
	CGContextDrawPath(context, kCGPathFill);
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return image;
}

+ (UIImage *)circletWithInnerColor:(UIColor *)inner outerColor:(UIColor *)outer radius:(CGFloat)radius innerPercentage:(CGFloat)innerPercent outerPercentage:(CGFloat)outerPercent style:(CircletStyle)style {
	return [self circletWithInnerColor:inner outerColor:outer radius:radius innerPercentage:innerPercent outerPercentage:outerPercent style:style thickness:(radius / 10.0)];
}

+ (UIImage *)circletWithInnerColor:(UIColor *)inner outerColor:(UIColor *)outer radius:(CGFloat)radius innerPercentage:(CGFloat)innerPercent outerPercentage:(CGFloat)outerPercent style:(CircletStyle)style thickness:(CGFloat)thickness {
	// Side-by-side:
	CGFloat smallRadius = (radius / 2.0) - thickness;
	
	UIImage *outerCirclet = [UIImage circletWithColor:outer radius:smallRadius percentage:outerPercent style:style thickness:thickness];
	UIImage *innerCirclet = [UIImage circletWithColor:inner radius:smallRadius percentage:innerPercent style:style thickness:thickness];
	
	CGSize comboSize = CGSizeMake((radius * 2.0) - thickness, (smallRadius * 2.0) + thickness);
	UIGraphicsBeginImageContextWithOptions(comboSize, NO, [UIScreen mainScreen].scale);
	[innerCirclet drawAtPoint:CGPointZero blendMode:kCGBlendModeMultiply alpha:1.0];
	[outerCirclet drawAtPoint:CGPointMake(outerCirclet.size.width + thickness, 0.0) blendMode:kCGBlendModeMultiply alpha:1.0];
	UIImage *comboCirclet = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	/*
	 Inner/Outer:
	 UIImage *outerCirclet = [UIImage circletWithColor:outer radius:radius percentage:outerPercent style:style];
	 UIImage *innerCirclet = [UIImage circletWithColor:inner radius:(radius / 2.0) percentage:innerPercent style:style];
	 
	 UIGraphicsBeginImageContextWithOptions(outerCirclet.size, NO, [UIScreen mainScreen].scale);
	 [outerCirclet drawAtPoint:CGPointZero blendMode:kCGBlendModeMultiply alpha:1.0];
	 [innerCirclet drawAtPoint:CGPointMake(innerCirclet.size.width / 2.0, innerCirclet.size.height / 2.0) blendMode:kCGBlendModeMultiply alpha:1.0];
	 UIImage *comboCirclet = UIGraphicsGetImageFromCurrentImageContext();
	 UIGraphicsEndImageContext();
	 
	 Diagonal:
	 CGFloat spacer = radius / 30.0;
	 CGFloat smallRadius = (radius / 2.0) - spacer;
	 CGFloat thickness = (smallRadius * 2.0) / 10.0;
	 UIImage *outerCirclet = [UIImage circletWithColor:outer radius:(smallRadius + spacer) percentage:outerPercent style:style thickness:thickness];
	 UIImage *innerCirclet = [UIImage circletWithColor:inner radius:(smallRadius + spacer) percentage:innerPercent style:style thickness:thickness];
	 
	 CGSize comboSize = CGSizeMake(radius * 2.0, radius * 2.0);
	 UIGraphicsBeginImageContextWithOptions(comboSize, NO, [UIScreen mainScreen].scale);
	 [outerCirclet drawAtPoint:CGPointZero blendMode:kCGBlendModeMultiply alpha:1.0];
	 [innerCirclet drawAtPoint:CGPointMake((smallRadius * 2.0), (smallRadius * 2.0)) blendMode:kCGBlendModeMultiply alpha:1.0];
	 UIImage *comboCirclet = UIGraphicsGetImageFromCurrentImageContext();
	 UIGraphicsEndImageContext();
	 */
	
	return comboCirclet;
}

+ (UIImage *)circletWithColor:(UIColor *)color radius:(CGFloat)radius string:(NSString *)string invert:(BOOL)invert {
	CGFloat diameter = radius * 2.0;
	return [self circletWithColor:color radius:radius string:string invert:invert thickness:(diameter / 10.0)];
}

+ (UIImage *)circletWithColor:(UIColor *)color radius:(CGFloat)radius string:(NSString *)string invert:(BOOL)invert thickness:(CGFloat)thickness {
	CGFloat diameter = radius * 2.0;
	CGRect frame = (CGRect){CGPointMake(thickness / 2.0, thickness / 2.0), CGSizeMake(diameter, diameter)};
	CGRect bounds = (CGRect){CGPointZero, CGSizeMake(diameter + thickness, diameter + thickness)};
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
		CGContextFillEllipseInRect(context, frame);
		CGContextSetBlendMode(context, kCGBlendModeDestinationOut);
	}
	
	CGRect circletCenterFrame = frame;
	circletCenterFrame.origin.y = (thickness / 2.0) + ((frame.size.height - [circletAttributedText size].height) / 2.0);
	[circletAttributedText drawInRect:circletCenterFrame];
	
	CGContextDrawPath(context, kCGPathFill);
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return image;
}

+ (CGFloat)circletLargestFontSizeForString:(NSString *)string inFrame:(CGRect)frame prediction:(CGFloat)pointSize {
	UIFont *font = [UIFont fontWithName:CIRCLET_FONT size:pointSize];
	CGSize stringSize = [string sizeWithFont:font];
	CGFloat widthCeiling = frame.size.width - 2.0, heightCeiling = frame.size.height - 2.0;
	
    while (stringSize.width > widthCeiling|| stringSize.height > heightCeiling) {
        font = [UIFont fontWithName:CIRCLET_FONT size:font.pointSize - 1.0];
        stringSize = [string sizeWithFont:font];
    }
	
    return font.pointSize;
}

@end
