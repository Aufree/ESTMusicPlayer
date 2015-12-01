//
//  NAKPlaybackIndicatorContentView.m
//  PlaybackIndicator
//
//  Created by Yuji Nakayama on 1/28/14.
//  Copyright (c) 2014 Yuji Nakayama. All rights reserved.
//

#import "NAKPlaybackIndicatorContentView.h"

static const NSInteger kBarCount = 3;

static const CGFloat kBarWidth = 3.0;
static const CGFloat kBarIdleHeight = 3.0;

static const CGFloat kHorizontalBarSpacing = 2.0; // Measured on iPad 2 (non-Retina)
static const CGFloat kRetinaHorizontalBarSpacing = 1.5; // Measured on iPhone 5s (Retina)

static const CGFloat kBarMinPeakHeight = 6.0;
static const CGFloat kBarMaxPeakHeight = 12.0;

static const CFTimeInterval kMinBaseOscillationPeriod = 0.6;
static const CFTimeInterval kMaxBaseOscillationPeriod = 0.8;

static NSString* const kOscillationAnimationKey = @"oscillation";

static const CFTimeInterval kDecayDuration = 0.3;
static NSString* const kDecayAnimationKey = @"decay";

@interface NAKPlaybackIndicatorContentView ()

@property (nonatomic, readonly) NSArray* barLayers;
@property (nonatomic, assign) BOOL hasInstalledConstraints;

@end

@implementation NAKPlaybackIndicatorContentView

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self prepareBarLayers];
        [self tintColorDidChange];
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)prepareBarLayers
{
    NSMutableArray* barLayers = [NSMutableArray array];
    CGFloat xOffset = 0.0;

    for (NSInteger i = 0; i < kBarCount; i++) {
        CALayer* layer = [self createBarLayerWithXOffset:xOffset layerIndex:i + 1];
        [barLayers addObject:layer];
        [self.layer addSublayer:layer];
        xOffset = CGRectGetMaxX(layer.frame) + [self horizontalBarSpacing];
    }

    _barLayers = barLayers;
}

- (CALayer*)createBarLayerWithXOffset:(CGFloat)xOffset layerIndex:(NSInteger)layerIndex
{
    CALayer* layer = [CALayer layer];

    layer.anchorPoint = CGPointMake(0.0, 1.0); // At the bottom-left corner
    layer.position = CGPointMake(xOffset, kBarMaxPeakHeight); // In superview's coordinate
    layer.bounds = CGRectMake(0.0, 0.0, kBarWidth, (layerIndex * kBarMaxPeakHeight/kBarCount));// In its own coordinate
    return layer;
}

- (CGFloat)horizontalBarSpacing
{
    if ([UIScreen mainScreen].scale == 2.0) {
        return kRetinaHorizontalBarSpacing;
    } else {
        return kHorizontalBarSpacing;
    }
}

#pragma mark - Tint Color

- (void)tintColorDidChange
{
    for (CALayer* layer in self.barLayers) {
        layer.backgroundColor = self.tintColor.CGColor;
    }
}

#pragma mark - Auto Layout

- (CGSize)intrinsicContentSize
{
    CGRect unionFrame = CGRectZero;

    for (CALayer* layer in self.barLayers) {
        unionFrame = CGRectUnion(unionFrame, layer.frame);
    }

    return unionFrame.size;
}

- (void)updateConstraints
{
    if (!self.hasInstalledConstraints) {
        CGSize size = [self intrinsicContentSize];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:0.0
                                                          constant:size.width]];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:0.0
                                                          constant:size.height]];

        self.hasInstalledConstraints = YES;
    }

    [super updateConstraints];
}

#pragma mark - Animations

- (BOOL)isOscillating
{
    CAAnimation* animation = [self.barLayers.firstObject animationForKey:kOscillationAnimationKey];
    return (animation != nil);
}

- (void)startOscillation
{
    CFTimeInterval basePeriod = kMinBaseOscillationPeriod + (drand48() * (kMaxBaseOscillationPeriod - kMinBaseOscillationPeriod));

    for (CALayer* layer in self.barLayers) {
        [self startOscillatingBarLayer:layer basePeriod:basePeriod];
    }
}

- (void)stopDecay
{
    for (CALayer* layer in self.barLayers) {
        [layer removeAnimationForKey:kDecayAnimationKey];
    }
}

- (void)stopOscillation
{
    for (CALayer* layer in self.barLayers) {
        [layer removeAnimationForKey:kOscillationAnimationKey];
    }
}

- (void)startDecay
{
    for (CALayer* layer in self.barLayers) {
        [self startDecayingBarLayer:layer];
    }
    
}

- (void)startOscillatingBarLayer:(CALayer*)layer basePeriod:(CFTimeInterval)basePeriod
{
    // arc4random_uniform() will return a uniformly distributed random number **less** upper_bound.
    CGFloat peakHeight = kBarMinPeakHeight + arc4random_uniform(kBarMaxPeakHeight - kBarMinPeakHeight + 1);
    
    CGRect fromBouns = layer.bounds;
    fromBouns.size.height = kBarIdleHeight;
    
    CGRect toBounds = layer.bounds;
    toBounds.size.height = peakHeight;

    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    animation.fromValue = [NSValue valueWithCGRect:fromBouns];
    animation.toValue = [NSValue valueWithCGRect:toBounds];
    animation.repeatCount = HUGE_VALF; // Forever
    animation.autoreverses = YES;
    animation.duration = (basePeriod / 2) * (kBarMaxPeakHeight / peakHeight);
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];

    [layer addAnimation:animation forKey:kOscillationAnimationKey];
}

- (void)startDecayingBarLayer:(CALayer*)layer
{
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    animation.fromValue = [NSValue valueWithCGRect:((CALayer*)layer.presentationLayer).bounds];
    animation.toValue = [NSValue valueWithCGRect:layer.bounds];
    animation.duration = kDecayDuration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];

    [layer addAnimation:animation forKey:kDecayAnimationKey];
}

@end
