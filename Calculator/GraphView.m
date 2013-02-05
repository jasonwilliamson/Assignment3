//
//  GraphView.m
//  Calculator
//
//  Created by Jason Williamson on 2013-01-23.
//  Copyright (c) 2013 Jason Williamson. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer.h"

@implementation GraphView

@synthesize dataSource = _dataSource;
@synthesize scale = _scale;
@synthesize origin = _origin;
@synthesize isLineMode = _isLineMode;

-(void)setup
{
    self.contentMode = UIViewContentModeRedraw;
}

-(void)awakeFromNib
{
    [self setup];
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup]; // get initialized if someone uses alloc/initWithFrame: to create us
    }
    return self;
}

-(void)setScale:(CGFloat)scale
{
    if (_scale != scale) {
        
        _scale = scale;
        
        [self setNeedsDisplay];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setFloat:_scale forKey:@"scale"];
        [defaults synchronize];
    }
    
}

-(CGFloat)scale
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _scale = [defaults floatForKey:@"scale"];
    if (!_scale) {
        self.scale = self.contentScaleFactor;;
    }
    
    return _scale;
}

- (void)setOrigin:(CGPoint)origin
{
    if (_origin.x != origin.x || _origin.y != origin.y ) {
        _origin = origin;
        [self setNeedsDisplay];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setFloat:_origin.x forKey:@"x"];
        [defaults setFloat:_origin.y forKey:@"y"];
        [defaults synchronize];
    }
}

- (CGPoint)origin
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _origin.x = [defaults floatForKey:@"x"];
    _origin.y = [defaults floatForKey:@"y"];
    if (!_origin.x && !_origin.y) {
        CGPoint centered;
        centered.x = (self.bounds.origin.x + self.bounds.size.width) / 2;
        centered.y = (self.bounds.origin.y + self.bounds.size.height) / 2;
        self.origin = centered;
    }
    return _origin;
}

-(void)drawRect:(CGRect)rect
{
    [AxesDrawer drawAxesInRect:self.bounds originAtPoint:self.origin scale:self.scale];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    float startViewCoordX = self.bounds.origin.x;
    float startViewCoordY = self.origin.y - [self.dataSource yAxisPositionForXValue:startViewCoordX inGraphView:self] * self.scale;
    CGContextMoveToPoint(context, startViewCoordX, startViewCoordY);
    
    for (float viewCoordX = self.bounds.origin.x; viewCoordX < self.bounds.origin.x + self.bounds.size.width; viewCoordX+=2) {
        float graphValueX = (viewCoordX - self.origin.x) / self.scale;
        float viewCoordY = self.origin.y - [self.dataSource yAxisPositionForXValue:graphValueX inGraphView:self] * self.scale;
        
        if( self.isLineMode ){
            CGContextAddLineToPoint(context, viewCoordX, viewCoordY);
        }else{
            CGContextFillEllipseInRect(context, CGRectMake(viewCoordX, viewCoordY, 1, 1));
        }
    }
    
    CGContextStrokePath(context);
    
}

-(void)switchChangeEvent:(UISwitch *)switchEvent
{
    self.isLineMode = switchEvent.on;
    [self setNeedsDisplay];
}

-(void)pinch:(UIPinchGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateChanged ||
        recognizer.state == UIGestureRecognizerStateEnded) {
        self.scale *= recognizer.scale;
        recognizer.scale = 1;
    }
}

-(void)pan:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateChanged ||
        recognizer.state == UIGestureRecognizerStateEnded ) {
        CGPoint translation = [recognizer translationInView:self];
        
        self.origin = CGPointMake(self.origin.x + translation.x, self.origin.y + translation.y);
        [recognizer setTranslation:CGPointZero inView:self];
        
    }
}

-(void)tap:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        self.origin = [recognizer locationInView:self];
    }
    
}

@end
