//
//  CFCoverFlowView.m
//  CFCoverFlowViewDemo
//
//  Created by c0ming on 14-7-6.
//  Copyright (c) 2014 c0ming. All rights reserved.
//

#import "CFCoverFlowView.h"

@import QuartzCore;

@interface CFCoverFlowView () {
    CGFloat _width;
    CGFloat _height;

    CGFloat _pageItemSpace;
    NSInteger _pageItemCount;
    CGFloat _lastPointX;

    UIView *_shadowView1;
    UIView *_shadowView2;
    CGFloat _shadowRadius;
    CGFloat _shadowOffset;

    CALayer *_selectionMaskLayer;
}

@property (nonatomic, strong) NSArray *views;

@end

@implementation CFCoverFlowView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark - Setup

- (void)setup {
    _width = self.bounds.size.width;
    _height = self.bounds.size.height;

    _autoAnimation = NO;
    _animationDuration = 5.0;

    _pageItemWidth = _width / 2.0;
    _pageItemHeight = _height;
    _pageItemCoverWidth = 0.0;
    _pageItemCornerRadius = 0.0;
    _lastPointX = 0.0;

    _shadowRadius = 20.0;
    _shadowOffset = 0.0;

    self.multipleTouchEnabled = NO;
    self.clipsToBounds = YES;
    [self setupSublayerTransform];
}

- (void)setupSublayerTransform {
    CATransform3D subTransform = CATransform3DIdentity;
    subTransform.m34 = -1.0 / 1000.0; // perspective transform
    self.layer.sublayerTransform = subTransform;
}

- (void)setupSelectionMaskLayer {
    _selectionMaskLayer = [CALayer layer];
    _selectionMaskLayer.frame = CGRectMake(0.0, 0.0, _pageItemWidth, _pageItemHeight);
    _selectionMaskLayer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5].CGColor;
}

- (void)addShadowViews {
    _shadowView1 = [self createShadowView];
    _shadowView2 = [self createShadowView];

    [self addSubview:_shadowView1];
    [self addSubview:_shadowView2];
}

- (UIView *)createShadowView {
    UIView *shadowView = [[UIView alloc] init];
    shadowView.userInteractionEnabled = NO;
    shadowView.center = CGPointMake(_width / 2.0, _height / 2.0);
    shadowView.bounds = CGRectMake(0, 0, _pageItemWidth, _pageItemHeight);

    shadowView.backgroundColor = [UIColor clearColor];
    shadowView.layer.masksToBounds = YES;
    shadowView.layer.cornerRadius = _pageItemCornerRadius;

    shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
    shadowView.layer.shadowOffset = CGSizeMake(_pageItemWidth / 2, 0);
    shadowView.layer.shadowRadius = _shadowRadius;
    shadowView.layer.shadowOpacity = 0.45;
    shadowView.layer.shadowPath = [UIBezierPath bezierPathWithRect:shadowView.bounds].CGPath;

    return shadowView;
}

- (void)setPageItemsWithImageNames:(NSArray *)imageNames {
    // page items count > 3
    assert(imageNames != nil && [imageNames count] > 3);

    _pageItemSpace = _pageItemWidth - _pageItemCoverWidth;
    _pageItemCount = [imageNames count];
    for (NSInteger i = 0; i < _pageItemCount; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.backgroundColor = [UIColor darkGrayColor];
        imageView.center = CGPointMake(_width / 2.0, _height / 2.0);
        imageView.bounds = CGRectMake(0, 0, _pageItemWidth, _pageItemHeight);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", imageNames[i]]];
        imageView.userInteractionEnabled = YES;
        imageView.layer.cornerRadius = _pageItemCornerRadius;
        imageView.layer.masksToBounds = YES;
        imageView.layer.shouldRasterize = YES;
        imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        imageView.tag = i;

        // add long press gesture as tap gesture
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressHandler:)];
        longPressGesture.minimumPressDuration = 0.05;
        longPressGesture.cancelsTouchesInView = NO;
        [imageView addGestureRecognizer:longPressGesture];

        [self addSubview:imageView];

        CATransform3D transform = CATransform3DMakeTranslation(i * _pageItemSpace, 0, 0);
        imageView.layer.transform = transform;
    }

    self.views = self.subviews;

    // add two shadow views
    [self addShadowViews];
    
    [self setupSelectionMaskLayer];

    // init page items's transform
    [self transformPageItemsWithDistance:0.0];
    [self transformShadowView1WithDistance:-_pageItemSpace];
    [self transformShadowView2WithDistance:_pageItemSpace];
}

//
//- (void)setPageItemsWithImageURLs:(NSArray *)urls placeholderImage:(UIImage *)placeholder {
//}

#pragma mark - Auto Animation

- (void)setAnimationDuration:(NSTimeInterval)animationDuration {
    _animationDuration = animationDuration < 3.0 ? 3.0 : animationDuration;
}

- (void)setAutoAnimation:(BOOL)autoAnimation {
    _autoAnimation = autoAnimation;

    [self startAutoAnimating];
}

- (void)startAutoAnimating {
    if (_autoAnimation) {
        [self performSelector:@selector(coverFlowViewAnimation) withObject:nil afterDelay:_animationDuration];
    }
}

- (void)stopAutoAnimating {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(coverFlowViewAnimation) object:nil];
}

- (void)coverFlowViewAnimation {
    [self stopAutoAnimating];

    // transform with 1 point first for avoiding shadow view flash.
    CGFloat offset = 1.0;
    [self transformWithDistance:-offset];
    [self animationWithDistance:-_pageItemSpace + offset duration:0.25];

    [self respondsToDidScrollPageToIndex];
}

#pragma mark - Touches Event

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];

    UITouch *touch = (UITouch *)[touches anyObject];
    CGPoint point = [touch locationInView:self];
    _lastPointX = point.x;

    // pause auto animation
    [self stopAutoAnimating];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];

    UITouch *touch = (UITouch *)[touches anyObject];
    CGPoint point = [touch locationInView:self];
    CGFloat moveX = point.x - _lastPointX;

    [self transformWithDistance:moveX];

    _lastPointX = point.x;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];

    // when touches ended animate to the center
    [self animateToCenter];
    [self respondsToDidScrollPageToIndex];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];

    [self animateToCenter];
}

#pragma mark - Animation

- (void)animateToCenter {
    // find the center offset
    CGFloat distance = ((long)((UIView *)self.views[0]).layer.transform.m41) % ((long)_pageItemSpace);
    distance = (long)(_pageItemSpace - distance) % (long)_pageItemSpace;
    if (distance > _pageItemSpace / 2.0) {
        distance -= _pageItemSpace;
    }

    [self animationWithDistance:distance duration:0.2];
}

- (void)animationWithDistance:(CGFloat)distance duration:(CFTimeInterval)duration {
    [CATransaction begin];
    [CATransaction setAnimationDuration:duration];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];

    [self animationPageItemsWithDistance:distance];
    [self animationShadow1WithDistance:distance];
    [self animationShadow2WithDistance:distance];

    [CATransaction commit];

    // repeat it if auto animation
    [self startAutoAnimating];
}

- (void)animationPageItemsWithDistance:(CGFloat)distance {
    for (NSInteger i = 0; i < _pageItemCount; i++) {
        UIImageView *item = self.views[i];

        CGFloat position = [self positionForPageItemsPosition:item.layer.transform.m41 + distance];
        CATransform3D originTransfrom = item.layer.transform;
        item.layer.transform = [self transformForPosition:position];

        CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        basicAnimation.removedOnCompletion = YES;
        basicAnimation.fromValue = [NSValue valueWithCATransform3D:originTransfrom];
        [item.layer addAnimation:basicAnimation forKey:@"transform"];
    }
}

- (void)animationShadow1WithDistance:(CGFloat)distance {
    CGFloat position = [self positionForShadowView1Position:_shadowView1.layer.transform.m41 + distance];
    CATransform3D originTransfrom = _shadowView1.layer.transform;
    _shadowView1.layer.transform = [self transformForPosition:position];

    CGSize originShadowOffset = _shadowView1.layer.shadowOffset;
    _shadowView1.layer.shadowOffset = [self shadowOffsetForShadowView1:position];

    CAAnimationGroup *groupAnimation = [self groupAnimationWithOriginTransform:originTransfrom originShadowOffset:originShadowOffset];
    [_shadowView1.layer addAnimation:groupAnimation forKey:@"shadow"];
}

- (void)animationShadow2WithDistance:(CGFloat)distance {
    CGFloat position = [self positionForShadowView2Position:_shadowView2.layer.transform.m41 + distance];

    CATransform3D originTransfrom = _shadowView2.layer.transform;
    _shadowView2.layer.transform = [self transformForPosition:position];

    CGSize originShadowOffset = _shadowView2.layer.shadowOffset;
    _shadowView2.layer.shadowOffset = [self shadowOffsetForShadowView2:position];

    CAAnimationGroup *groupAnimation = [self groupAnimationWithOriginTransform:originTransfrom originShadowOffset:originShadowOffset];
    [_shadowView2.layer addAnimation:groupAnimation forKey:@"shadow"];
}

#pragma mark - Transform

- (void)transformWithDistance:(CGFloat)distance {
    [self transformPageItemsWithDistance:distance];
    [self transformShadowView1WithDistance:distance];
    [self transformShadowView2WithDistance:distance];
}

- (void)transformPageItemsWithDistance:(CGFloat)distance {
    for (NSInteger i = 0; i < _pageItemCount; i++) {
        UIImageView *item = self.views[i];

        CGFloat position = [self positionForPageItemsPosition:item.layer.transform.m41 + distance];
        item.layer.transform = [self transformForPosition:position];
    }
}

- (void)transformShadowView1WithDistance:(CGFloat)distance {
    CGFloat position = [self positionForShadowView1Position:_shadowView1.layer.transform.m41 + distance];
    _shadowView1.layer.transform = [self transformForPosition:position];
    _shadowView1.layer.shadowOffset = [self shadowOffsetForShadowView1:position];
}

- (void)transformShadowView2WithDistance:(CGFloat)distance {
    CGFloat position = [self positionForShadowView2Position:_shadowView2.layer.transform.m41 + distance];
    _shadowView2.layer.transform = [self transformForPosition:position];
    _shadowView2.layer.shadowOffset = [self shadowOffsetForShadowView2:position];
}

#pragma mark - Delegate Response

- (void)longPressHandler:(UIGestureRecognizer *)recognizer {
    UIGestureRecognizerState state = recognizer.state;
    if (state == UIGestureRecognizerStateBegan) {
        [recognizer.view.layer addSublayer:_selectionMaskLayer];
    } else if (state == UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(coverFlowView:didSelectPageItemAtIndex:)]) {
            [self.delegate coverFlowView:self didSelectPageItemAtIndex:recognizer.view.tag];
        }

        [_selectionMaskLayer removeFromSuperlayer];
    } else {
        // if recognizer's state == UIGestureRecognizerStateChanged,cancel it.
        recognizer.enabled = NO;
        recognizer.enabled = YES;

        [_selectionMaskLayer removeFromSuperlayer];
    }
}

- (void)respondsToDidScrollPageToIndex {
    static NSInteger lastScrollIndex = 0;
    NSInteger currentScrollIndex = 0;

    // find the top level item
    CGFloat zPosition = -FLT_MAX;
    for (NSInteger i = 0; i < _pageItemCount; i++) {
        UIView *item = self.views[i];
        if (item.layer.transform.m43 > zPosition) {
            currentScrollIndex = i;

            zPosition = item.layer.transform.m43;
        }
    }

    if (currentScrollIndex != lastScrollIndex && self.delegate != nil && [self.delegate respondsToSelector:@selector(coverFlowView:didScrollPageItemToIndex:)]) {
        [self.delegate coverFlowView:self didScrollPageItemToIndex:currentScrollIndex];
    }

    lastScrollIndex = currentScrollIndex;
}

#pragma mark - Compute view's position

- (CGFloat)positionForPageItemsPosition:(CGFloat)position {
    if (position < -_pageItemSpace * 2.0) {
        position += _pageItemSpace * _pageItemCount;
    } else if (position > _pageItemSpace * (_pageItemCount - 2)) {
        position -= _pageItemSpace * _pageItemCount;
    }
    return position;
}

- (CGFloat)positionForShadowView1Position:(CGFloat)position {
    if (position < (-_pageItemSpace * 1.5 - _shadowOffset)) {
        position += _pageItemSpace;
    } else if (position > (-_pageItemSpace / 2.0 - _shadowOffset)) {
        position -= _pageItemSpace;
    }
    return position;
}

- (CGFloat)positionForShadowView2Position:(CGFloat)position {
    if (position < (_pageItemSpace * 0.5 + _shadowOffset)) {
        position += _pageItemSpace;
    } else if (position > (_pageItemSpace * 1.5 + _shadowOffset)) {
        position -= _pageItemSpace;
    }
    return position;
}

- (CGSize)shadowOffsetForShadowView1:(CGFloat)position {
    return CGSizeMake(position + _pageItemSpace * 1.5 + _shadowRadius * 2.0, 0);
}

- (CGSize)shadowOffsetForShadowView2:(CGFloat)position {
    return CGSizeMake(position - _pageItemSpace * 1.5 - _shadowRadius * 2.0, 0);
}

- (CATransform3D)transformForPosition:(CGFloat)position {
    CATransform3D translationTransform = CATransform3DMakeTranslation(position, 0.0, fabs(position / _pageItemSpace) * -200.0);
    CATransform3D transform = CATransform3DRotate(translationTransform, -(M_PI * (position / (_pageItemSpace / 45.0)) / 180.0), 0, 1, 0);
    return transform;
}

- (CAAnimationGroup *)groupAnimationWithOriginTransform:(CATransform3D)originTransfrom originShadowOffset:(CGSize)originShadowOffset {
    CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    transformAnimation.fromValue = [NSValue valueWithCATransform3D:originTransfrom];

    CABasicAnimation *shadowAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOffset"];
    shadowAnimation.fromValue = [NSValue valueWithCGSize:originShadowOffset];

    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[transformAnimation, shadowAnimation];
    group.removedOnCompletion = YES;
    return group;
}

#pragma mark - Life cycle

- (void)removeFromSuperview {
    [self stopAutoAnimating];
    
    [super removeFromSuperview];
}

- (void)dealloc {
    self.views = nil;
}

@end
