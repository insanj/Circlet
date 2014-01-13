//
//  CCView.m
//  CellCircle
//
//  Created by Julian Weiss on 1/5/14.
//  Copyright (c) 2014 insanj. All rights reserved.
//

#import "CCView.h"

@interface CCView (Private)
-(void)addLine;
-(void)removeLine;
-(void)setInsideHeight:(CGFloat)height;
-(void)resetLevel;
@end

@implementation CCView
@synthesize shouldUpdateManager, holder, inside, original;

#pragma mark - lifecycle
-(instancetype)initWithRadius:(CGFloat)given{
	CGFloat pending = given * 2.f;
	if((self = [super initWithFrame:CGRectMake(0.f, 0.f, pending, pending)])){
		self.layer.cornerRadius = 50;
		radius = given;
		diameter = pending;
		state = CCViewStateNull;
		
		self.backgroundColor = [UIColor clearColor];
		fake = [[UIButton alloc] initWithFrame:CGRectMake(0.f, 0.f, diameter, diameter)];
		[fake setBackgroundColor:[UIColor clearColor]];
		fake.layer.borderWidth = CCBorderWidth;
		fake.layer.borderColor = [UIColor whiteColor].CGColor;
		fake.layer.cornerRadius = 50.f;
		fake.layer.masksToBounds = NO;
		[self addSubview:fake];
		
		holder = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, diameter, diameter)];
		holder.center = fake.center;
		holder.backgroundColor = [UIColor clearColor];
		holder.clipsToBounds = YES;
		holder.layer.cornerRadius = 50.f;
		[self insertSubview:holder belowSubview:fake];

		inside = [[UIView alloc] initWithFrame:holder.frame];
		inside.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.f];
		inside.clipsToBounds = YES;
		[holder addSubview:inside];

		__unsafe_unretained CCView *weakSelf = self;
		levelHandler = ^void(CMAccelerometerData *accelerometerData, NSError *error){			
			CGFloat x = accelerometerData.acceleration.x;
			weakSelf.holder.transform = CGAffineTransformIdentity;
			weakSelf.holder.transform = CGAffineTransformMakeRotation(-x * 0.5f);
		};	

		manager = [[CMMotionManager alloc] init];
		shouldUpdateManager = YES;
		[manager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:levelHandler];
	}
	
	return self;
}

-(void)hijackOriginal:(UIStatusBarSignalStrengthItemView *)arg1{
	original = arg1;
}

# pragma mark - setters (public)

-(void)setRadius:(CGFloat)given{
	self.layer.cornerRadius = given;
	radius = given;
	diameter = radius * 2.f;
}

-(void)setState:(NSInteger)given{
	state = (CCViewState) given;
	[self removeLine];

	switch(state){
		case CCViewStateNull:
			[self addLine];
			[self setInsideHeight:0.f];
			break;
		case CCViewStateEmpty:
			[self setInsideHeight:0.f];
			break;
		case CCViewStateOne:
			[self setInsideHeight:diameter/5.f];
			break;
		case CCViewStateTwo:
			[self setInsideHeight:(2.f * diameter)/5.f];
			break;
		case CCViewStateThree:
			[self setInsideHeight:(3.f * diameter)/5.f];
			break;
		case CCViewStateFour:
			[self setInsideHeight:(4.f * diameter)/5.f];
			break;
		case CCViewStateFive:
			[self setInsideHeight:diameter];
			break;
	}
}

-(void)setShouldLevel:(BOOL)given{
	if(shouldUpdateManager && given)
		return;
	
	if(shouldUpdateManager && !given){
		shouldUpdateManager = NO;
		[self resetLevel];
	}
	
	else{
		shouldUpdateManager = YES;
		[manager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:levelHandler];
	}
}

-(void)setTint:(UIColor *)given{
	fake.layer.borderColor = given.CGColor;

	CGFloat w, a;
	[given getWhite:&w alpha:&a];
	inside.backgroundColor = [UIColor colorWithWhite:(w/2.f) alpha:a];
}

#pragma mark - reactors (private)

-(void)addLine{
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path moveToPoint:CGPointMake(0.f, 0.f)];
	[path addLineToPoint:CGPointMake(diameter, diameter)];
	
	line = [CAShapeLayer layer];
	line.path = [path CGPath];
	line.strokeColor = fake.layer.borderColor;
	line.lineWidth = 3.f;
	line.fillColor = [[UIColor clearColor] CGColor];
	[self.layer addSublayer:line];
}

-(void)removeLine{
	[line removeFromSuperlayer];
	line = nil;
}

-(void)setInsideHeight:(CGFloat)height{
	[manager stopAccelerometerUpdates];

	CGRect insideFrame = holder.frame;
	insideFrame.size.height = height;
	insideFrame.origin.y = (diameter - height);
	
	[UIView animateWithDuration:0.1f animations:^{
		[inside setFrame:insideFrame];
	} completion:^(BOOL finished){
		[manager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:levelHandler];
	}];
}

-(void)resetLevel{
	[manager stopAccelerometerUpdates];

	holder.transform = CGAffineTransformIdentity;
	holder.transform = CGAffineTransformMakeRotation(0.f);
}

# pragma mark - hijack'd methods

// higher level
+(id)createViewForItem:(UIStatusBarItem *)arg1 withData:(id)arg2 actions:(int)arg3 foregroundStyle:(id)arg4{
	return [[%c(UIStatusBarSignalStrengthItemView) class] createViewForItem:arg1 withData:arg2 actions:arg3 foregroundStyle:arg4];
}

-(BOOL)isVisible{
	return [original isVisible];
}

-(int)textStyle{
	return [original textStyle];
}

-(void)setLayoutManager:(id)arg1{
	[original setLayoutManager:arg1];
}

-(id)layoutManager{
	return [original layoutManager];
}

-(void)beginDisablingRasterization{
	[original beginDisablingRasterization];
}

-(id)imageWithText:(id)arg1{
	return [original imageWithText:arg1];
}

-(void)performPendedActions{
	[original performPendedActions];
}

-(BOOL)animatesDataChange{
	return [original animatesDataChange];
}

-(float)maximumOverlap{
	return [original maximumOverlap];
}

-(float)addContentOverlap:(float)arg1{
	return [original addContentOverlap:arg1];
}

-(float)resetContentOverlap{
	return [original resetContentOverlap];
}

-(float)extraRightPadding{
	return [original extraRightPadding];
}

-(float)extraLeftPadding{
	return [original extraLeftPadding];
}

-(id)textFont{
	return [original textFont];
}

-(void)drawText:(id)arg1 forWidth:(float)arg2 lineBreakMode:(int)arg3 letterSpacing:(float)arg4 textSize:(CGSize)arg5{
	[original drawText:arg1 forWidth:arg2 lineBreakMode:arg3 letterSpacing:arg4 textSize:arg5];
}

-(float)setStatusBarData:(id)arg1 actions:(int)arg2{
	return [original setStatusBarData:arg1 actions:arg2];
}

-(float)currentRightOverlap{
	return [original currentRightOverlap];
}

-(float)currentLeftOverlap{
	return [original currentLeftOverlap];
}

-(float)currentOverlap{
	return [original currentOverlap];
}

-(void)setCurrentOverlap:(float)arg1{
	[original setCurrentOverlap:arg1];
}

-(void)setVisible:(BOOL)arg1 frame:(CGRect)arg2 duration:(double)arg3{
	[original setVisible:arg1 frame:arg2 duration:arg3];
}

-(void)endDisablingRasterization{
	[original endDisablingRasterization];
}

-(BOOL)cachesImage{
	return [original cachesImage];
}

-(float)shadowPadding{
	return [original shadowPadding];
}

-(float)standardPadding{
	return [original standardPadding];
}

-(void)setLayerContentsImage:(id)arg1{
	[original setLayerContentsImage:arg1];
}

-(float)legibilityStrength{
	return [original legibilityStrength];
}

-(BOOL)allowsUpdates{
	return [original allowsUpdates];
}

-(float)updateContentsAndWidth{
	return [original updateContentsAndWidth];
}

-(void)setAllowsUpdates:(BOOL)arg1{
	[original setAllowsUpdates:arg1];
}

-(id)initWithItem:(UIStatusBarItem *)arg1 data:(id)arg2 actions:(int)arg3 style:(id)arg4{
	return (CCView*)[original initWithItem:arg1 data:arg2 actions:arg3 style:arg4];
}

-(void)setPersistentAnimationsEnabled:(BOOL)arg1{
	[original setPersistentAnimationsEnabled:arg1];
}

-(int)legibilityStyle{
	return [original legibilityStyle];
}

-(_UILegibilityImageSet *)contentsImage{
	return [original contentsImage];
}

-(BOOL)updateForNewData:(id)arg1 actions:(int)arg2{
	return [original updateForNewData:arg1 actions:arg2];
}

-(void)endImageContext{
	[original endImageContext];
}

-(id)imageFromImageContextClippedToWidth:(float)arg1{
	return [original imageFromImageContextClippedToWidth:arg1];
}

-(void)beginImageContextWithMinimumWidth:(float)arg1{
	[original beginImageContextWithMinimumWidth:arg1];
}

-(id)foregroundStyle{
	return [original foregroundStyle];
}

-(id)imageWithShadowNamed:(id)arg1{
	return [original imageWithShadowNamed:arg1];
}

-(UIStatusBarItem *)item{
	return [original item];
}

-(int)textAlignment{
	return [original textAlignment];
}

-(void)setVisible:(BOOL)arg1{
	[original setVisible:arg1];
}

-(void)willMoveToWindow:(id)arg1{
	[original willMoveToWindow:arg1];
}

-(BOOL)_shouldAnimatePropertyWithKey:(id)arg1{
	return [original _shouldAnimatePropertyWithKey:arg1];
}

-(void)setContentMode:(int)arg1{
	[original setContentMode:arg1];
}

// lower level
-(NSString *)_stringForRSSI{
	return [original _stringForRSSI];
}

-(void)touchesEnded:(id)arg1 withEvent:(id)arg2{
	[original touchesEnded:arg1 withEvent:arg2];
}
@end