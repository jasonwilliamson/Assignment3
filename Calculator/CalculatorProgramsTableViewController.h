//
//  CalculatorProgramsTableViewController.h
//  Calculator
//
//  Created by Jason Williamson on 2013-02-04.
//  Copyright (c) 2013 Jason Williamson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CalculatorProgramsTableViewController;

@protocol CalculatorProgramsTableViewControllerDelegate <NSObject>

@optional

-(void)calculatorProgramsTableViewController:(CalculatorProgramsTableViewController *)sender
                                choseProgram:(id)program;

-(void)calculatorProgramsTableViewController:(CalculatorProgramsTableViewController *)sender
                              deletedProgram:(id)program;



@end

@interface CalculatorProgramsTableViewController : UITableViewController
@property (nonatomic, strong) NSArray *programs; // of CalculatorBrain programs
@property (nonatomic, weak) id <CalculatorProgramsTableViewControllerDelegate> delegate;
@end
