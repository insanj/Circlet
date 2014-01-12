//
//  CCView.h
//  CellCircle
//
//  Created by Julian Weiss on 1/5/14.
//  Copyright (c) 2014 insanj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreMotion/CoreMotion.h>

#define CCBorderWidth 6.f
#define CCBorderReactiveWidth CCBorderWidth/2.f

typedef enum CCViewState{
    CCViewStateNull,		//searching... | airplane
    CCViewStateEmpty,		//no service
    CCViewStateOne,			//one bar
	CCViewStateTwo,			//two bars
	CCViewStateThree,		//three bars
	CCViewStateFour,		//four bars
	CCViewStateFive			//five bars
} CCViewState;

@interface CCView : UIView{
	CGFloat radius, diameter;
	CCViewState state;
	
	UIButton *fake;
	CAShapeLayer *line;
	
	void(^levelHandler)(CMAccelerometerData *accelerometerData, NSError *error);
	CMMotionManager *manager;
}

@property (nonatomic, readwrite) BOOL level;
@property (nonatomic, retain) UIView *holder, *inside;

-(instancetype)initWithRadius:(CGFloat)given;

-(void)setRadius:(CGFloat)given;
-(void)setState:(NSInteger)given;
-(void)setShouldLevel:(BOOL)given;
-(void)setTint:(UIColor *)given;

@end