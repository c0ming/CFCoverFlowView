CFCoverFlowView
===============

CFCoverFlowView is a CoverFlow view with PagingEnabled similar to App Store for iPad.

## Preview

![ScreenShot](https://raw.githubusercontent.com/c0ming/Preview/master/CFCoverFlowView/CFCoverFlowView_01.gif)

## Usage

Add CFCoverFlowView.h/m file into your project. You can create CFCoverFlowView programmatically or use it in your storyboard
with AutoLayout.


## Examples

```objc
CFCoverFlowView *coverFlowView = [[CFCoverFlowView alloc] initWithFrame:CGRectMake(0.0, 0.0, 768.0, 200.0)];
coverFlowView.delegate = self;
coverFlowView.pageItemWidth = 400.0;
coverFlowView.pageItemCoverWidth = 25.0;
coverFlowView.pageItemHeight = 190.0;
coverFlowView.pageItemCornerRadius = 15.0;
[coverFlowView setPageItemsWithImageNames:@[@"1", @"2", @"3", @"4", @"5", @"6"]];
[self.view addSubview:coverFlowView];

// delegate
- (void)coverFlowView:(CFCoverFlowView *)coverFlowView didScrollPageItemToIndex:(NSInteger)index;
- (void)coverFlowView:(CFCoverFlowView *)coverFlowView didSelectPageItemAtIndex:(NSInteger)index;
```

## License

The MIT License (MIT)

Copyright (c) 2014 c0ming

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
