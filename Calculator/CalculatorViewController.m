//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Jason Williamson on 2013-01-13.
//  Copyright (c) 2013 Jason Williamson. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"
#import "GraphViewController.h"

@interface CalculatorViewController ()

@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic, strong) CalculatorBrain *brain;

@end

@implementation CalculatorViewController

@synthesize calculationDisplay = _calculationDisplay;
@synthesize display = _display;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize brain = _brain;

#define MAX_DISPLAY_LENGTH 35

- (CalculatorBrain *)brain
{
    if (!_brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepareForSegue ");
    if ([segue.identifier isEqualToString:@"showGraph"]) {
        [segue.destinationViewController setProgram:self.brain.program];
    }
}

- (void)runProgram
{
    [self updateCalculationDisplay];
    id result = [CalculatorBrain runProgram:self.brain.program usingVariables:nil];
    if([result isKindOfClass:[NSNumber class]]){
        [self updateDisplay:[NSString stringWithFormat:@"%g", [result doubleValue]]];
    }else if([result isKindOfClass:[NSString class]]){
        [self updateDisplay:result];
    }
}

- (void)updateDisplay:(NSString *)text
{
    [self updateDisplay:text byAppendingString:NO];
}

- (void)updateDisplay:(NSString *)text byAppendingString:(BOOL)shouldAppend
{
    if (shouldAppend) {
        self.display.text = [self.display.text stringByAppendingString:text];
    }else{
        self.display.text = text;
    }
}

- (void)updateCalculationDisplay
{
    NSString *appendedString = [CalculatorBrain descriptionOfProgram:self.brain.program];
    self.calculationDisplay.text = [self checkCalculationDisplayLength:appendedString];
}

- (NSString *)checkCalculationDisplayLength:(NSString *)checkString
{
    if (checkString.length > MAX_DISPLAY_LENGTH) {
        int minRange = checkString.length - MAX_DISPLAY_LENGTH;
        checkString = [checkString substringWithRange:NSMakeRange(minRange, MAX_DISPLAY_LENGTH)];
    }
    
    return checkString;
}

-(GraphViewController *)splitViewGraphViewController
{
    id gvc = [self.splitViewController.viewControllers lastObject];
    if (![gvc isKindOfClass:[GraphViewController class]]) {
        gvc = nil;
    }
    return gvc;
}

- (IBAction)graph:(id)sender {
    
    if ([self splitViewGraphViewController]) {                              // if in split view
        [self splitViewGraphViewController].program = self.brain.program;   // just set program in detail
    } else {
        [self performSegueWithIdentifier:@"showGraph" sender:self];         // else segue using showGraph
    }
}

- (IBAction)undoPressed {
    
    if(self.userIsInTheMiddleOfEnteringANumber){
        self.display.text = [self.display.text substringToIndex:self.display.text.length -1];
        if ([self.display.text isEqualToString:@""]) {
            self.display.text = @"0";
            self.userIsInTheMiddleOfEnteringANumber = NO;
        }
    }else{
        [self.brain removeLastItemFromStack];
        [self runProgram];
        
    }
}

- (IBAction)clearPressed
{
    self.display.text = @"0";
    self.calculationDisplay.text = @"";
    [self.brain clearOperandStack];
}

- (IBAction)digitPressed:(UIButton *)sender
{
    NSString *digit = sender.currentTitle;
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self updateDisplay:digit byAppendingString:YES];
    } else {
        [self updateDisplay:digit];
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
}

- (IBAction)variablePressed:(UIButton *)sender
{
    NSString *variable = sender.currentTitle;
    if (self.userIsInTheMiddleOfEnteringANumber) [self enterPressed];
    [self updateDisplay:variable];
    [self.brain pushVariable:variable];
}

- (IBAction)operationPressed:(UIButton *)sender
{
    if (self.userIsInTheMiddleOfEnteringANumber) [self enterPressed];
    [self.brain pushOperation:sender.currentTitle];
    [self runProgram];
}

- (IBAction)enterPressed
{
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.userIsInTheMiddleOfEnteringANumber = NO;
}

- (IBAction)decimalPressed:(id)sender
{
    NSRange range = [self.display.text rangeOfString:@"."];
    if (range.location == NSNotFound) {
        self.userIsInTheMiddleOfEnteringANumber = YES;
        [self updateDisplay:@"." byAppendingString:YES];
    }
}

- (IBAction)plusMinusPressed:(UIButton *)sender
{
    if (self.userIsInTheMiddleOfEnteringANumber) {
        double result = [self.display.text doubleValue];
        [self updateDisplay:[NSString stringWithFormat:@"%g", result * -1]];
    } else {
        [self operationPressed:sender];
    }
}

@end
