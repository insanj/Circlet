//
//  CRView.h
//  CellCircle
//
//  Created by Julian Weiss on 1/5/14.
//  Copyright (c) 2014 insanj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreMotion/CoreMotion.h>

@interface CRView : UIView {
	CGFloat diameter;
	CGFloat CCBorderWidth, CCReactiveBorderWidth;
	
	UIButton *fake;
	CAShapeLayer *line;
	
	void(^levelHandler)(CMAccelerometerData *accelerometerData, NSError *error);
	CMMotionManager *manager;
}

@property (nonatomic, readwrite) CGFloat radius;
@property (nonatomic, readwrite) BOOL shouldUpdateManager;	// NO by default
@property (nonatomic, retain) UIView *holder, *inside;
@property (nonatomic, readwrite) int state, max;

-(instancetype)initWithRadius:(CGFloat)given;

-(void)setRadius:(CGFloat)given;
-(void)setState:(int)arg1 withMax:(int)arg2;
-(void)setShouldLevel:(BOOL)given;
-(void)setTint:(UIColor *)given;

-(CRView *)versionWithColor:(UIColor *)given;
-(CRView *)versionWithInverse:(UIColor *)given;

@end