//
//  CalculatorViewController.h
//  Calculator
//
//  Created by Jason Williamson on 2013-01-13.
//  Copyright (c) 2013 Jason Williamson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RotatableViewController.h"

@interface CalculatorViewController : RotatableViewController

@property (weak, nonatomic) IBOutlet UILabel *display;
@property (weak, nonatomic) IBOutlet UILabel *calculationDisplay;

@end
