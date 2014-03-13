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
@synthesize radius, shouldUpdateManager, holder, inside, state, max;

#pragma mark - lifecycle
-(instancetype)initWithRadius:(CGFloat)given{
	CGFloat pending = given * 2.0;
	CCBorderWidth = 1.0;
	CCReactiveBorderWidth = CCBorderWidth/2.0;

	if((self = [super initWithFrame:CGRectMake(0.0, 0.0, pending, pending)])){
		self.layer.cornerRadius = given;
		radius = given;
		diameter = pending;
		state = -1;

		self.backgroundColor = [UIColor clearColor];
		fake = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, diameter, diameter)];
		[fake setBackgroundColor:[UIColor clearColor]];
		fake.layer.borderWidth = CCBorderWidth;
		fake.layer.borderColor = [UIColor whiteColor].CGColor;
		fake.layer.cornerRadius = given;
		fake.layer.masksToBounds = NO;
		[self addSubview:fake];

		holder = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, diameter, diameter)];
		holder.center = fake.center;
		holder.backgroundColor = [UIColor clearColor];
		holder.clipsToBounds = YES;
		holder.layer.cornerRadius = given;
		[self insertSubview:holder belowSubview:fake];

		inside = [[UIView alloc] initWithFrame:holder.frame];
		inside.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
		inside.clipsToBounds = YES;
		[holder addSubview:inside];

		__unsafe_unretained CRView *weakSelf = self;
		levelHandler = ^void(CMAccelerometerData *accelerometerData, NSError *error){
			CGFloat x = accelerometerData.acceleration.x;
			weakSelf.holder.transform = CGAffineTransformIdentity;
			weakSelf.holder.transform = CGAffineTransformMakeRotation(-x * 0.5);
		};

		shouldUpdateManager = NO;
	}

	return self;
}

# pragma mark - setters (public)

-(void)setRadius:(CGFloat)given{
	radius = given;
	diameter = radius * 2.0;

	self.layer.cornerRadius = radius;

	[fake setFrame:CGRectMake(0.0, 0.0, diameter, diameter)];
	fake.layer.cornerRadius = radius;

	[holder setFrame:CGRectMake(0.0, 0.0, diameter, diameter)];
	holder.center = fake.center;
	holder.layer.cornerRadius = radius;

	[inside setFrame:holder.frame];
}

-(void)setState:(CGFloat)arg1 withMax:(CGFloat)arg2{
	state = arg1;
	max = arg2;
	[self removeLine];

	//NSLog(@"----- state, arg1:%i, arg2:%i, ")
	if(state == -1){
		[self addLine];
		[self setInsideHeight:0.0];
	}

	else
		[self setInsideHeight:(diameter * (state/max))];
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

	[version setState:state withMax:max];
	[version setTint:given];
	return version;
}

-(CRView *)versionWithInverse:(UIColor *)given{
	CRView *inverse = [[CRView alloc] initWithRadius:radius];
	inverse.center = self.center;

	[inverse setState:state withMax:max];

	CGFloat w, a;
	[given getWhite:&w alpha:&a];
	[inverse setTint:[UIColor colorWithWhite:1.0-w alpha:a]];

	return inverse;
}

#pragma mark - reactors (private)

-(void)addLine{
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path moveToPoint:CGPointMake(0.0, 0.0)];
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

	[UIView animateWithDuration:0.1 animations:^{
		[inside setFrame:insideFrame];
	} completion:^(BOOL finished){
		[manager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:levelHandler];
	}];
}

-(void)resetLevel{
	[manager stopAccelerometerUpdates];

	holder.transform = CGAffineTransformIdentity;
	holder.transform = CGAffineTransformMakeRotation(0.0);
}
@end
