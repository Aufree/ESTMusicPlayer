//
//  NAKPlaybackIndicatorView.m
//  PlaybackIndicator
//
//  Created by Yuji Nakayama on 1/27/14.
//  Copyright (c) 2014 Yuji Nakayama. All rights reserved.
//

#import "NAKPlaybackIndicatorView.h"
#import "NAKPlaybackIndicatorContentView.h"

@interface NAKPlaybackIndicatorView ()

@property (nonatomic, readonly) NAKPlaybackIndicatorContentView* contentView;
@property (nonatomic, assign) BOOL hasInstalledConstraints;

@end

@implementation NAKPlaybackIndicatorView

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.layer.masksToBounds = YES;

    _contentView = [[NAKPlaybackIndicatorContentView alloc] init];
    [self addSubview:_contentView];

    [self prepareLayoutPriorities];
    [self setNeedsUpdateConstraints];

    self.state = NAKPlaybackIndicatorViewStateStopped;
    self.hidesWhenStopped = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)prepareLayoutPriorities
{
    // Custom views should set default values for both orientations on creation,
    // based on their content, typically to NSLayoutPriorityDefaultLow or NSLayoutPriorityDefaultHigh.
    [self setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];

    [self setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Auto Layout

- (void)updateConstraints
{
    if (!self.hasInstalledConstraints) {
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.contentView
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.0
                                                          constant:0.0]];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.contentView
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0
                                                          constant:0.0]];

        self.hasInstalledConstraints = YES;
    }

    [super updateConstraints];
}

- (CGSize)intrinsicContentSize
{
    return [self.contentView intrinsicContentSize];
}

- (UIView*)viewForBaselineLayout
{
    return self.contentView;
}

#pragma mark - Frame-Based Layout

- (CGSize)sizeThatFits:(CGSize)size
{
    return [self intrinsicContentSize];
}

#pragma mark - Properties

- (void)setHidesWhenStopped:(BOOL)hidesWhenStopped
{
    _hidesWhenStopped = hidesWhenStopped;

    if (self.state == NAKPlaybackIndicatorViewStateStopped) {
        self.hidden = self.hidesWhenStopped;
    }
}

- (void)setState:(NAKPlaybackIndicatorViewState)state
{
    _state = state;

    if (self.state == NAKPlaybackIndicatorViewStateStopped) {
        [self stopAnimating];
        if (self.hidesWhenStopped) {
            self.hidden = YES;
        }
    } else {
        if (self.state == NAKPlaybackIndicatorViewStatePlaying) {
            [self startAnimating];
        } else if (self.state == NAKPlaybackIndicatorViewStatePaused) {
            [self stopAnimating];
        }
        self.hidden = NO;
    }
}

#pragma mark - Helpers

- (void)startAnimating
{
    if (self.contentView.isOscillating) {
        return;
    }

    [self.contentView stopDecay];
    [self.contentView startOscillation];
}

- (void)stopAnimating
{
    if (!self.contentView.isOscillating) {
        return;
    }

    [self.contentView stopOscillation];
    [self.contentView startDecay];
}

#pragma mark - Notification

- (void)applicationWillEnterForeground:(NSNotification*)notification
{
    // When an app entered background, UIKit removes all animations
    // even if it's an infinite animation.
    // So we restart the animation here if it should be when the app came back to foreground.
    if (self.state == NAKPlaybackIndicatorViewStatePlaying) {
        [self startAnimating];
    }
}

@end
