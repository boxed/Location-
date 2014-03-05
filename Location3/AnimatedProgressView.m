#import "AnimatedProgressView.h"
#import "QuartzCore/QuartzCore.h"

#define degreesToRadians(x) (M_PI * x / 180.0)
@implementation AnimatedProgressView

- (void)didMoveToSuperview
{
    CABasicAnimation *rotation;
    rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotation.fromValue = [NSNumber numberWithFloat:0];
    rotation.toValue = [NSNumber numberWithFloat:(2*M_PI)];
    rotation.duration = 2.5; // Speed
    rotation.repeatCount = HUGE_VALF; // Repeat forever. Can be a finite number.
    [self.layer addAnimation:rotation forKey:@"Spin"];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextClipToRect(context, rect);
    
    rect = CGRectInset(rect, 4, 4);
	[[UIColor blackColor] set];
    CGContextSetAlpha(context, 0.2);
	CGContextSetLineWidth(context, 2);
	CGContextStrokeEllipseInRect(context, rect);
    CGContextSetAlpha(context, 1);
    
	[[UIColor whiteColor] set];
    CGContextAddArc(context, CGRectGetMidX(rect), CGRectGetMidY(rect), CGRectGetHeight(rect)/2.0, 0, 1, 0);
    CGContextDrawPath(context, kCGPathStroke);
}

@end
