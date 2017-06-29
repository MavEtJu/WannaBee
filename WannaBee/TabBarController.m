//
//  WannaBeenTabBarController.m
//  WannaBee
//
//  Created by Edwin Groothuis on 28/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@interface TabBarController ()

@end

@implementation TabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];

    //create a custom view for the tab bar
    CGRect frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, 48);
    UIView *v = [[UIView alloc] initWithFrame:frame];
    [v setBackgroundColor:[UIColor lightGrayColor]];
    [v setAlpha:0.5];
    [[self tabBar] addSubview:v];

    //set the tab bar title appearance for normal state
    [[UITabBarItem appearance]
     setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor darkGrayColor],
                              NSFontAttributeName:[UIFont boldSystemFontOfSize:16.0f]}
     forState:UIControlStateNormal];

    //set the tab bar title appearance for selected state
    [[UITabBarItem appearance]
     setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blueColor],
                              NSFontAttributeName:[UIFont boldSystemFontOfSize:16.0f]}
     forState:UIControlStateHighlighted];
}

@end
