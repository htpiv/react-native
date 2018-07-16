/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "RCTActivityIndicatorView.h"

#if TARGET_OS_OSX
#import <QuartzCore/QuartzCore.h>

@interface RCTActivityIndicatorView ()
@property (nonatomic, readwrite, getter=isAnimating) BOOL animating;
@end
#endif

@implementation RCTActivityIndicatorView

#if TARGET_OS_OSX
- (instancetype)initWithFrame:(CGRect)frame
{
  if ((self = [super initWithFrame:frame])) {
    self.displayedWhenStopped = NO;
    self.style = NSProgressIndicatorSpinningStyle;
  }
  return self;
}

- (void)startAnimating
{
  [self startAnimation:self];
}

- (void)stopAnimating
{
  [self stopAnimation:self];
}

- (void)startAnimation:(id)sender
{
  [super startAnimation:sender];
  self.animating = YES;
}

- (void)stopAnimation:(id)sender
{
  [super stopAnimation:sender];
  self.animating = NO;
}

- (void)setActivityIndicatorViewStyle:(UIActivityIndicatorViewStyle)activityIndicatorViewStyle
{
  _activityIndicatorViewStyle = activityIndicatorViewStyle;
  
  switch (activityIndicatorViewStyle) {
    case UIActivityIndicatorViewStyleWhiteLarge:
      self.controlSize = NSControlSizeRegular;
      break;
    case UIActivityIndicatorViewStyleWhite:
      self.controlSize = NSControlSizeSmall;
      break;
    default:
      break;
  }
}

- (void)setColor:(UIColor*)color
{
  _color = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
  CIFilter *colorPoly = [CIFilter filterWithName:@"CIColorPolynomial"];
  [colorPoly setDefaults];
  CIVector *redVector = [CIVector vectorWithX:color.redComponent Y:0 Z:0 W:0];
  CIVector *greenVector = [CIVector vectorWithX:color.greenComponent Y:0 Z:0 W:0];
  CIVector *blueVector = [CIVector vectorWithX:color.blueComponent Y:0 Z:0 W:0];
  [colorPoly setValue:redVector forKey:@"inputRedCoefficients"];
  [colorPoly setValue:greenVector forKey:@"inputGreenCoefficients"];
  [colorPoly setValue:blueVector forKey:@"inputBlueCoefficients"];
  self.contentFilters = @[colorPoly];
}

- (void)setHidesWhenStopped:(BOOL)hidesWhenStopped
{
  self.displayedWhenStopped = !hidesWhenStopped;
}

- (BOOL)hidesWhenStopped
{
  return !self.displayedWhenStopped;
}

#endif

- (void)setHidden:(BOOL)hidden
{
  if ([self hidesWhenStopped] && ![self isAnimating]) {
    [super setHidden: YES];
  } else {
    [super setHidden: hidden];
  }
}




@end
