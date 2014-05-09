//
//  UIImage+Circlet.m
//  testing
//
//  Created by Julian Weiss on 5/3/14.
//  Copyright (c) 2014 Julian Weiss. All rights reserved.
//

#import "UIImage+Circlet.h"

@implementation UIImage (Circlet)

+ (UIImage *)lightCircletWithRadius:(CGFloat)radius percentage:(CGFloat)percent style:(CircletStyle)style {
	return [self circletWithColor:[UIColor whiteColor] radius:radius percentage:percent style:style];
}

+ (UIImage *)darkCircletWithRadius:(CGFloat)radius percentage:(CGFloat)percent style:(CircletStyle)style {
	return [self circletWithColor:[UIColor blackColor] radius:radius percentage:percent style:style];
}

+ (UIImage *)circletWithColor:(UIColor *)color radius:(CGFloat)radius percentage:(CGFloat)percent style:(CircletStyle)style {
	CGFloat diameter = radius * 2.0;
	CGFloat thickness = diameter / 10.0;
	CGRect frame = (CGRect){CGPointMake(thickness / 2.0, thickness / 2.0), CGSizeMake(diameter, diameter)};
	CGRect bounds = (CGRect){CGPointZero, CGSizeMake(diameter + thickness, diameter + thickness)};
	CGPoint center = CGPointMake(bounds.size.width / 2.0, bounds.size.height / 2.0);
	CGColorRef colorRef = color.CGColor; // Light color
	
	UIGraphicsBeginImageContextWithOptions(bounds.size, NO, [UIScreen mainScreen].scale);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
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
		
		if (percent >= 0.98) {
			CGContextFillEllipseInRect(context, frame);
		}
		
		else {
			// Applies inversion settings, or properly deducts percentage amount
			if (style == CircletStyleFill && percent < 1.0) {
				percent = 1.0 - percent;
			}
			
			else if (style == CircletStyleConcentric) {
				percent = 1.0 - percent;
			}
			
			else if (style != CircletStyleRadial) {
				percent -= 1.0;
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
				CGContextAddArc(context, center.x, center.y, radius, M_PI_2 * (3 - (2 * percent)), M_PI_2 * (3 + (2 * percent)), YES);
			}
			
			// ⦿
			else {
				CGRect minor = CGRectInset(frame, percent * radius, percent * radius);
				CGContextAddEllipseInRect(context, minor);
			}
		}
	}
	
	CGContextDrawPath(context, kCGPathFill);
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return image;
}


// Dumb helper method for oulining (shouldn't be used in average production)
+ (UIImage *)circletWithColor:(UIColor *)color radius:(CGFloat)radius percentage:(CGFloat)percent style:(CircletStyle)style thickness:(CGFloat)thickness {
	CGFloat diameter = radius * 2.0;
	CGRect frame = (CGRect){CGPointMake(thickness / 2.0, thickness / 2.0), CGSizeMake(diameter, diameter)};
	CGRect bounds = (CGRect){CGPointZero, CGSizeMake(diameter + thickness, diameter + thickness)};
	CGPoint center = CGPointMake(bounds.size.width / 2.0, bounds.size.height / 2.0);
	CGColorRef colorRef = color.CGColor; // Light color
	
	UIGraphicsBeginImageContextWithOptions(bounds.size, NO, [UIScreen mainScreen].scale);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
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
		
		if (percent >= 0.98) {
			CGContextFillEllipseInRect(context, frame);
		}
		
		else {
			// Applies inversion settings, or properly deducts percentage amount
			if (style == CircletStyleFill && percent < 1.0) {
				percent = 1.0 - percent;
			}
			
			else if (style == CircletStyleConcentric) {
				percent = 1.0 - percent;
			}
			
			else if (style != CircletStyleRadial) {
				percent -= 1.0;
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
				CGContextAddArc(context, center.x, center.y, radius, M_PI_2 * (3 - (2 * percent)), M_PI_2 * (3 + (2 * percent)), YES);
			}
			
			// ⦿
			else {
				CGRect minor = CGRectInset(frame, percent * radius, percent * radius);
				CGContextAddEllipseInRect(context, minor);
			}
		}
	}
	
	CGContextDrawPath(context, kCGPathFill);
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return image;
}

+ (UIImage *)circletWithInnerColor:(UIColor *)inner outerColor:(UIColor *)outer radius:(CGFloat)radius innerPercentage:(CGFloat)innerPercent outerPercentage:(CGFloat)outerPercent style:(CircletStyle)style {
	UIImage *outerCirclet = [UIImage circletWithColor:outer radius:radius percentage:outerPercent style:style];
	UIImage *innerCirclet = [UIImage circletWithColor:inner radius:(radius / 2.0) percentage:innerPercent style:style];
	
	UIGraphicsBeginImageContextWithOptions(outerCirclet.size, NO, [UIScreen mainScreen].scale);
	[outerCirclet drawAtPoint:CGPointZero blendMode:kCGBlendModeMultiply alpha:1.0];
	[innerCirclet drawAtPoint:CGPointMake(innerCirclet.size.width / 2.0, innerCirclet.size.height / 2.0) blendMode:kCGBlendModeMultiply alpha:1.0];
	UIImage *comboCirclet = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return comboCirclet;
}

@end
