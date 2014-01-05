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
    CCViewStateNull,		//searching...
    CCViewStateEmpty,	//no service
    CCViewStatePartial,	//one bars
	CCViewStateHalf,		//two - three bars
	CCViewStateMost,		//four bars
	CCViewStateFull		//five bars
} CCViewState;

@interface CCView : UIView{
	CGFloat radius, diameter;
	CCViewState state;
	
	CAShapeLayer *line;
	
	void(^levelHandler)(CMAccelerometerData *accelerometerData, NSError *error);
	CMMotionManager *manager;
}

@property (nonatomic, readwrite) BOOL level;
@property (nonatomic, retain) UIView *holder, *inside;


-(instancetype)initWithRadius:(CGFloat)given;

-(void)setRadius:(CGFloat)given;
-(void)setState:(CCViewState)given;
-(void)setShouldLevel:(BOOL)given;


@end