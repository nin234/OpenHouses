//
//  HomeViewController.m
//  EasyGrocList
//
//  Created by Ninan Thomas on 11/9/15.
//  Copyright © 2015 Ninan Thomas. All rights reserved.
//

#import "HomeViewController.h"
#import "AppDelegate.h"

@implementation HomeViewController


-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [pDlg switchRootView];
    
}

/*

-(void) viewDidLoad
{
    [super viewDidLoad];
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [pDlg switchRootView];
    
}
 
 */

@end
