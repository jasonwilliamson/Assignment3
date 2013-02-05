//
//  RotatableViewController.m
//  Calculator
//
//  Created by Jason Williamson on 2013-01-31.
//  Copyright (c) 2013 Jason Williamson. All rights reserved.
//

#import "RotatableViewController.h"
#import "SplitViewBarButtonItemPresenter.h"

@interface RotatableViewController ()

@end

@implementation RotatableViewController

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.splitViewController.delegate = self;
}

- (id <SplitViewBarButtonItemPresenter>)splitViewBarButtonItemPresenter
{
    id detailVC = [self.splitViewController.viewControllers lastObject];
    if (![detailVC conformsToProtocol:@protocol(SplitViewBarButtonItemPresenter)]) {
        detailVC = nil;
    }
    return detailVC;
}

- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation
{
    return [self splitViewBarButtonItemPresenter] ? UIInterfaceOrientationIsPortrait(orientation) : NO;
}

-(void)splitViewController:(UISplitViewController *)svc
    willHideViewController:(UIViewController *)aViewController
         withBarButtonItem:(UIBarButtonItem *)barButtonItem
      forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = self.navigationItem.title;
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = barButtonItem;
}

-(void)splitViewController:(UISplitViewController *)svc
    willShowViewController:(UIViewController *)aViewController
 invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = nil;
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


@end
