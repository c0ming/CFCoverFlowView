//
//  CFViewController.m
//  CFCoverFlowViewDemo
//
//  Created by c0ming on 14-5-30.
//  Copyright (c) 2014年 c0ming. All rights reserved.
//

#import "CFViewController.h"

#import "CFCoverFlowView.h"

@interface CFViewController () <CFCoverFlowViewDelegate>

@end

@implementation CFViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.coverFlowView1.delegate = self;
    self.coverFlowView1.pageItemWidth = 400.0;
    self.coverFlowView1.pageItemHeight = 200.0;
    self.coverFlowView1.pageItemCoverWidth = 25.0;
    self.coverFlowView1.pageItemCornerRadius = 15.0;
    self.coverFlowView1.autoAnimation = YES;
    self.coverFlowView1.animationDuration = 6.0;
    [self.coverFlowView1 setPageItemsWithImageNames:@[@"1", @"2", @"3", @"4", @"5", @"6"]];

    CFCoverFlowView *coverFlowView2 = [[CFCoverFlowView alloc] initWithFrame:CGRectMake(224, 400.0, 320.0, 120)];
    coverFlowView2.backgroundColor = [UIColor groupTableViewBackgroundColor];
    coverFlowView2.pageItemWidth = 180;
    coverFlowView2.pageItemCoverWidth = 10.0;
    coverFlowView2.pageItemHeight = 100.0;
    coverFlowView2.pageItemCornerRadius = 5.0;
    [coverFlowView2 setPageItemsWithImageNames:@[@"1", @"2", @"3", @"4", @"5", @"6"]];
    [self.view addSubview:coverFlowView2];
}

- (void)coverFlowView:(CFCoverFlowView *)coverFlowView didScrollPageItemToIndex:(NSInteger)index {
    NSLog(@"didScrollPageItemToIndex >>> %@", @(index));

    self.pageControl.currentPage = index;
}

- (void)coverFlowView:(CFCoverFlowView *)coverFlowView didSelectPageItemAtIndex:(NSInteger)index {
    NSLog(@"didSelectPageItemAtIndex >>> %@", @(index));
}

- (IBAction)pageControlAction:(UIPageControl *)sender {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
