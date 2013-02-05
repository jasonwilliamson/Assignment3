//
//  GraphViewController.m
//  Calculator
//
//  Created by Jason Williamson on 2013-01-23.
//  Copyright (c) 2013 Jason Williamson. All rights reserved.
//

#import "GraphViewController.h"
#import "GraphView.h"
#import "CalculatorBrain.h"
#import "CalculatorProgramsTableViewController.h"

@interface GraphViewController () <GraphViewDataSource, CalculatorProgramsTableViewControllerDelegate>
@property (nonatomic, weak) IBOutlet GraphView *graphView;
@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;
@property (nonatomic, weak) IBOutlet UISwitch *drawModeSwitch;
@property (nonatomic, strong) UIPopoverController *popoverController;
@end

@implementation GraphViewController
@synthesize program = _program;
@synthesize graphView = _graphView;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;
@synthesize toolbar = _toolbar;
@synthesize drawModeSwitch = _drawModeSwitch;
@synthesize popoverController;

#define FAVORITES_KEY @"GraphViewController.Favorites"

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    BOOL allowRotation;
    if (self.splitViewController) {
        allowRotation = YES;
    }else{
        allowRotation = (toInterfaceOrientation == UIInterfaceOrientationPortrait);
    }
    return allowRotation;
}

- (IBAction)addToFavorites:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *favorites = [[defaults objectForKey:FAVORITES_KEY] mutableCopy];
    if (!favorites) favorites = [NSMutableArray array];
    [favorites addObject:self.program];
    [defaults setObject:favorites forKey:FAVORITES_KEY];
    [defaults synchronize];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ( [segue.identifier isEqualToString:@"Show Favorite Graphs"]){
        
        // added to prevent multiple popovers
        if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]]) {
            UIStoryboardPopoverSegue *popoverSegue = (UIStoryboardPopoverSegue *)segue;
            [self.popoverController dismissPopoverAnimated:YES];
            self.popoverController = popoverSegue.popoverController;
        }
        
        NSArray *programs = [[NSUserDefaults standardUserDefaults] objectForKey:FAVORITES_KEY];
        [segue.destinationViewController setPrograms:programs];
        [segue.destinationViewController setDelegate:self];
    }
}

-(void)calculatorProgramsTableViewController:(CalculatorProgramsTableViewController *)sender choseProgram:(id)program
{
    self.program = program;
    
    //support iphone
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)calculatorProgramsTableViewController:(CalculatorProgramsTableViewController *)sender deletedProgram:(id)program
{
    NSString *deletedProgramDescription = [CalculatorBrain descriptionOfProgram:program];
    NSMutableArray *favorites = [NSMutableArray array];
    NSUserDefaults *defualts = [NSUserDefaults standardUserDefaults];
    for (id program in [defualts objectForKey:FAVORITES_KEY]) {
        if (![[CalculatorBrain descriptionOfProgram:program] isEqualToString:deletedProgramDescription]){
            [favorites addObject:program];
        }
    }
    [defualts setObject:favorites forKey:FAVORITES_KEY];
    [defualts synchronize];
    sender.programs = favorites;
}

-(void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if (_splitViewBarButtonItem != splitViewBarButtonItem) {
        NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
        if (_splitViewBarButtonItem) [toolbarItems removeObject:_splitViewBarButtonItem];
        if (splitViewBarButtonItem) [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
        self.toolbar.items = toolbarItems;
        _splitViewBarButtonItem = splitViewBarButtonItem;
    }
}

-(void)setProgram:(NSMutableArray *)program
{
    _program = program;
    
    self.navigationItem.title = [CalculatorBrain descriptionOfProgram:self.program];
    
    [self.graphView setNeedsDisplay];
}

-(void)setGraphView:(GraphView *)graphView
{
    _graphView = graphView;
    
    //enable gestures in GraphView
    [self.graphView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pinch:)]];
    [self.graphView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pan:)]];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(tap:)];
    tapRecognizer.numberOfTapsRequired = 3;
    [self.graphView addGestureRecognizer:tapRecognizer];
    
    self.graphView.dataSource = self;
    
    [self.drawModeSwitch addTarget:self.graphView action:@selector(switchChangeEvent:) forControlEvents:UIControlEventValueChanged ];
    [self.drawModeSwitch setOn:NO];
}

-(float)yAxisPositionForXValue:(float)xValue inGraphView:(GraphView *)sender
{
    float yFloat = 0;
    id yValue = [CalculatorBrain runProgram:self.program usingVariables:
                    [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:xValue] forKey:@"x"]];
    if ([yValue isKindOfClass:[NSNumber class]]) yFloat = [yValue floatValue];
    return yFloat;
}

@end
