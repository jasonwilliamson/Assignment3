//
//  GraphViewController.h
//  Calculator
//
//  Created by Jason Williamson on 2013-01-23.
//  Copyright (c) 2013 Jason Williamson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplitViewBarButtonItemPresenter.h"

@interface GraphViewController : UIViewController <SplitViewBarButtonItemPresenter>

@property (nonatomic, strong) NSMutableArray *program;


@end
