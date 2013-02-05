//
//  CalculatorProgramsTableViewController.m
//  Calculator
//
//  Created by Jason Williamson on 2013-02-04.
//  Copyright (c) 2013 Jason Williamson. All rights reserved.
//

#import "CalculatorProgramsTableViewController.h"
#import "CalculatorBrain.h"

@interface CalculatorProgramsTableViewController ()

@end

@implementation CalculatorProgramsTableViewController

@synthesize programs = _programs;
@synthesize delegate = _delegate;

-(void)setPrograms:(NSArray *)programs
{
    _programs = programs;
    [self.tableView reloadData];
}

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

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [self.programs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Calculator Program Description";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    id program = [self.programs objectAtIndex:indexPath.row];
    cell.textLabel.text = [@"y = " stringByAppendingString:[CalculatorBrain descriptionOfProgram:program]];
    
    return cell;
}




// delegates deletion
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        id program = [self.programs objectAtIndex:indexPath.row];
        [self.delegate calculatorProgramsTableViewController:self deletedProgram:program];
    }
}


// don't allow deletion if the delegate doesn't support it too!
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.delegate respondsToSelector:@selector(calculatorProgramsTableViewController:deletedProgram:)];
}




#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id program = [self.programs objectAtIndex:indexPath.row];
    [self.delegate calculatorProgramsTableViewController:self choseProgram:program];
}

@end
