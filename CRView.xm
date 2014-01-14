//
//  CRView.m
//  CellCircle
//
//  Created by Julian Weiss on 1/5/14.
//  Copyright (c) 2014 insanj. All rights reserved.
//

#import "CRView.h"

@interface CRView (Private)
-(void)addLine;
-(void)removeLine;
-(void)setInsideHeight:(CGFloat)height;
-(void)resetLevel;
@end

@implementation CRView
@synthesize radius, shouldUpdateManager, holder, inside, state;

#pragma mark - lifecycle
-(instancetype)initWithRadius:(CGFloat)given{
	CGFloat pending = given * 2.f;
	CCBorderWidth = 1.f;
	CCReactiveBorderWidth = CCBorderWidth/2.f;
	
	if((self = [super initWithFrame:CGRectMake(0.f, 0.f, pending, pending)])){
		self.layer.cornerRadius = given;
		radius = given;
		diameter = pending;
		state = -1;
		
		self.backgroundColor = [UIColor clearColor];
		fake = [[UIButton alloc] initWithFrame:CGRectMake(0.f, 0.f, diameter, diameter)];
		[fake setBackgroundColor:[UIColor clearColor]];
		fake.layer.borderWidth = CCBorderWidth;
		fake.layer.borderColor = [UIColor whiteColor].CGColor;
		fake.layer.cornerRadius = given;
		fake.layer.masksToBounds = NO;
		[self addSubview:fake];
		
		holder = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, diameter, diameter)];
		holder.center = fake.center;
		holder.backgroundColor = [UIColor clearColor];
		holder.clipsToBounds = YES;
		holder.layer.cornerRadius = given;
		[self insertSubview:holder belowSubview:fake];
		
		inside = [[UIView alloc] initWithFrame:holder.frame];
		inside.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.f];
		inside.clipsToBounds = YES;
		[holder addSubview:inside];
		
		__unsafe_unretained CRView *weakSelf = self;
		levelHandler = ^void(CMAccelerometerData *accelerometerData, NSError *error){
			CGFloat x = accelerometerData.acceleration.x;
			weakSelf.holder.transform = CGAffineTransformIdentity;
			weakSelf.holder.transform = CGAffineTransformMakeRotation(-x * 0.5f);
		};
		
		shouldUpdateManager = NO;
	}
	
	return self;
}

# pragma mark - setters (public)

-(void)setRadius:(CGFloat)given{
	radius = given;
	diameter = radius * 2.f;

	self.layer.cornerRadius = radius;

	[fake setFrame:CGRectMake(0.f, 0.f, diameter, diameter)];
	fake.layer.cornerRadius = radius;

	[holder setFrame:CGRectMake(0.f, 0.f, diameter, diameter)];
	holder.center = fake.center;
	holder.layer.cornerRadius = radius;

	[inside setFrame:holder.frame];
}

-(void)setState:(int)given{
	state = given;
	[self removeLine];
	
	switch(state){
		case -1:
			[self addLine];
			[self setInsideHeight:0.f];
			break;
		case 0:
			[self setInsideHeight:0.f];
			break;
		case 1:
			[self setInsideHeight:diameter/5.f];
			break;
		case 2:
			[self setInsideHeight:(2.f * diameter)/5.f];
			break;
		case 3:
			[self setInsideHeight:(3.f * diameter)/5.f];
			break;
		case 4:
			[self setInsideHeight:(4.f * diameter)/5.f];
			break;
		case 5:
			[self setInsideHeight:diameter];
			break;
	}
}

-(void)setShouldLevel:(BOOL)given{
	if(!manager)
		manager = [[CMMotionManager alloc] init];

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
	inside.backgroundColor = given;
}

#pragma mark - converter getters

-(CRView *)versionWithColor:(UIColor *)given{
	CRView *version = [[CRView alloc] initWithRadius:radius];
	version.center = self.center;

	[version setState:state];
	[version setTint:given];
	return version;
}

-(CRView *)versionWithInverse:(UIColor *)given{
	CRView *inverse = [[CRView alloc] initWithRadius:radius];
	inverse.center = self.center;

	[inverse setState:state];

	CGFloat w, a;
	[given getWhite:&w alpha:&a];
	[inverse setTint:[UIColor colorWithWhite:1.f-w alpha:a]];

	return inverse;
}

#pragma mark - reactors (private)

-(void)addLine{
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path moveToPoint:CGPointMake(0.f, 0.f)];
	[path addLineToPoint:CGPointMake(diameter, diameter)];
	
	line = [CAShapeLayer layer];
	line.path = [path CGPath];
	line.strokeColor = fake.layer.borderColor;
	line.lineWidth = CCBorderWidth;
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