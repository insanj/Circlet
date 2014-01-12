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
@synthesize level, holder, inside;

#pragma mark - initialization
-(instancetype)initWithRadius:(CGFloat)given{
	CGFloat pending = given * 2.f;
	if((self = [super initWithFrame:CGRectMake(0.f, 0.f, pending, pending)])){
		self.layer.cornerRadius = 50;
		radius = given;
		diameter = pending;
		state = CCViewStateNull;
		level = YES;
		
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
		[manager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:levelHandler];
	}
	
	return self;
}

# pragma mark - setters (public)

-(void)setRadius:(CGFloat)given{
	self.layer.cornerRadius = given;
	radius = given;
	diameter = radius * 2.f;
}

-(void)setState:(NSInteger)given{
	state = given;
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
	if(level && given)			//if both, ignore
		return;
	
	if(level && !given){
		level = NO;
		[self resetLevel];
	}
	
	else{
		level = YES;
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

@end