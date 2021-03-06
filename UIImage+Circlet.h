//
//  UIImage+Circlet.h
//  Circlet
//
//  Created by Julian Weiss on 5/3/14.
//  Copyright (c) 2014 Julian Weiss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreText/CoreText.h>

@interface UIImage (Circlet)

typedef NS_ENUM(NSUInteger, CircletStyle) {
    CircletStyleRadial = 0,
    CircletStyleFill, // == 1
    CircletStyleConcentric, // == 2
    CircletStyleTextual, // == 3
	
	CircletStyleRadialInverse, // == 4
    CircletStyleFillInverse, // == 5
    CircletStyleConcentricInverse, // == 6
	CircletStyleTextualInverse, // == 7
};

+ (UIImage *)circletWithColor:(UIColor *)color radius:(CGFloat)radius percentage:(CGFloat)percent style:(CircletStyle)style;
+ (UIImage *)circletWithColor:(UIColor *)color radius:(CGFloat)radius percentage:(CGFloat)percent style:(CircletStyle)style thickness:(CGFloat)thickness;

+ (UIImage *)doubleCircletWithLeftColor:(UIColor *)leftColor rightColor:(UIColor *)rightColor radius:(CGFloat)radius leftPercentage:(CGFloat)leftPercent rightPercentage:(CGFloat)rightPercent style:(CircletStyle)style;
+ (UIImage *)doubleCircletWithLeftColor:(UIColor *)leftColor rightColor:(UIColor *)rightColor radius:(CGFloat)radius leftPercentage:(CGFloat)leftPercent rightPercentage:(CGFloat)rightPercent style:(CircletStyle)style thickness:(CGFloat)thickness;

+ (UIImage *)doubleCircletWithLeftColor:(UIColor *)leftColor rightColor:(UIColor *)rightColor radius:(CGFloat)radius leftString:(NSString *)leftString rightString:(NSString *)rightString style:(CircletStyle)style thickness:(CGFloat)thickness;
+ (UIImage *)doubleCircletWithLeftColor:(UIColor *)leftColor rightColor:(UIColor *)rightColor radius:(CGFloat)radius leftString:(NSString *)leftString rightString:(NSString *)rightString style:(CircletStyle)style;

+ (UIImage *)circletWithColor:(UIColor *)color radius:(CGFloat)radius string:(NSString *)string invert:(BOOL)invert;
+ (UIImage *)circletWithColor:(UIColor *)color radius:(CGFloat)radius string:(NSString *)string invert:(BOOL)invert thickness:(CGFloat)thickness;

+ (CGFloat)circletLargestFontSizeForString:(NSString *)string inFrame:(CGRect)frame prediction:(CGFloat)pointSize;

@end
