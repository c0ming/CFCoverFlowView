//
//  CFViewController.h
//  CFCoverFlowViewDemo
//
//  Created by c0ming on 14-5-30.
//  Copyright (c) 2014年 c0ming. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CFCoverFlowView;

@interface CFViewController : UIViewController

@property (weak, nonatomic) IBOutlet CFCoverFlowView *coverFlowView1;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
- (IBAction)pageControlAction:(id)sender;

@end
