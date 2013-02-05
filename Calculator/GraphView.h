//
//  GraphView.h
//  Calculator
//
//  Created by Jason Williamson on 2013-01-23.
//  Copyright (c) 2013 Jason Williamson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GraphView;

@protocol GraphViewDataSource

-(float)yAxisPositionForXValue:(float)xValue inGraphView:(GraphView *)sender;

@end

@interface GraphView : UIView

@property (nonatomic, weak) IBOutlet id <GraphViewDataSource> dataSource;
@property (nonatomic) CGFloat scale;
@property (nonatomic) CGPoint origin;
@property (nonatomic) BOOL isLineMode;

-(void)pinch:(UIPinchGestureRecognizer *)gesture;
-(void)pan:(UIPanGestureRecognizer *)gesture;
-(void)tap:(UITapGestureRecognizer *)gesture;

@end
