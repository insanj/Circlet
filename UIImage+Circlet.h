//
//  UIImage+Circlet.h
//  testing
//
//  Created by Julian Weiss on 5/3/14.
//  Copyright (c) 2014 Julian Weiss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>

@interface UIImage (Circlet)

typedef NS_ENUM(NSUInteger, CircletStyle) {
	// Bottom up
    CircletStyleRadial = 0,
    CircletStyleFill, // == 1
    CircletStyleConcentric, // == 2
	
	// Bottom down
	CircletStyleRadialInverse, // == 3
    CircletStyleFillInverse, // == 4
    CircletStyleConcentricInverse, // == 5
};

+ (UIImage *)lightCircletWithRadius:(CGFloat)radius percentage:(CGFloat)percent style:(CircletStyle)style;
+ (UIImage *)darkCircletWithRadius:(CGFloat)radius percentage:(CGFloat)percent style:(CircletStyle)style;
+ (UIImage *)circletWithColor:(UIColor *)color radius:(CGFloat)radius percentage:(CGFloat)percent style:(CircletStyle)style;
+ (UIImage *)circletWithInnerColor:(UIColor *)inner outerColor:(UIColor *)outer radius:(CGFloat)radius innerPercentage:(CGFloat)innerPercent outerPercentage:(CGFloat)outerPercent style:(CircletStyle)style;

+ (UIImage *)circletWithColor:(UIColor *)color radius:(CGFloat)radius percentage:(CGFloat)percent style:(CircletStyle)style thickness:(CGFloat)thickness;

@end
