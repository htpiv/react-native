/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "RCTPicker.h"

#import "RCTConvert.h"
#import "RCTUtils.h"

@interface RCTPicker()
#if !TARGET_OS_OSX
  <UIPickerViewDataSource, UIPickerViewDelegate>
#else
  <NSComboBoxDataSource, NSComboBoxDelegate>
#endif
@end

@implementation RCTPicker

- (instancetype)initWithFrame:(CGRect)frame
{
  if ((self = [super initWithFrame:frame])) {
    _color = [UIColor blackColor];
#if !TARGET_OS_OSX
    _font = [UIFont systemFontOfSize:21]; // TODO: selected title default should be 23.5
#else
    _font = [UIFont systemFontOfSize:11];
#endif
    _selectedIndex = NSNotFound;
    _textAlign = NSTextAlignmentCenter;
    self.delegate = self;
    
#if TARGET_OS_OSX
    self.controlSize = NSControlSizeRegular;
    self.editable = NO;
    self.drawsBackground = NO;
    self.usesDataSource = YES;
    self.dataSource = self;
#endif
  }
  return self;
}

RCT_NOT_IMPLEMENTED(- (instancetype)initWithCoder:(NSCoder *)aDecoder)

- (void)setItems:(NSArray<NSDictionary *> *)items
{
#if !TARGET_OS_OSX
  _items = [items copy];
  [self setNeedsLayout];
#else
  CGFloat maxHeight = 0.0;
  NSMutableParagraphStyle *mutableParagraphStyle = [[NSMutableParagraphStyle alloc] init];
  mutableParagraphStyle.alignment = _textAlign;
  NSParagraphStyle *paragraphStyle = [mutableParagraphStyle copy];
  NSMutableArray *mutableItems = [[NSMutableArray alloc] initWithCapacity:items.count];
  for (NSDictionary *item in items) {
    NSMutableDictionary *mutableItem = item.mutableCopy;
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:[RCTConvert NSString:item[@"label"]]
                                                                     attributes:@{NSForegroundColorAttributeName : [RCTConvert UIColor:item[@"textColor"]] ?: _color,
                                                                                  NSFontAttributeName: _font,
                                                                                  NSParagraphStyleAttributeName: paragraphStyle}];
    NSSize size = attrString.size;
    if (size.height > maxHeight) {
      maxHeight = size.height;
    }
    mutableItem[@"label"] = attrString;
    [mutableItems addObject:mutableItem.copy];
  }
  self.itemHeight = maxHeight;
  _items = mutableItems.copy;
  self.needsLayout = YES;
#endif
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
  if (_selectedIndex != selectedIndex) {
#if !TARGET_OS_OSX
    BOOL animated = _selectedIndex != NSNotFound; // Don't animate the initial value
#endif
    _selectedIndex = selectedIndex;
    dispatch_async(dispatch_get_main_queue(), ^{
#if !TARGET_OS_OSX
      [self selectRow:selectedIndex inComponent:0 animated:animated];
#else
      self.delegate = nil;
      [self selectItemAtIndex:selectedIndex];
      self.attributedStringValue = _items[selectedIndex][@"label"];
      self.delegate = self;
#endif
    });
  }
}

#if !TARGET_OS_OSX

#pragma mark - UIPickerViewDataSource protocol

- (NSInteger)numberOfComponentsInPickerView:(__unused UIPickerView *)pickerView
{
  return 1;
}

- (NSInteger)pickerView:(__unused UIPickerView *)pickerView
numberOfRowsInComponent:(__unused NSInteger)component
{
  return _items.count;
}

#pragma mark - UIPickerViewDelegate methods

- (NSString *)pickerView:(__unused UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(__unused NSInteger)component
{
  return [RCTConvert NSString:_items[row][@"label"]];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
  return _font.pointSize + 19;
}

- (UIView *)pickerView:(UIPickerView *)pickerView
            viewForRow:(NSInteger)row
          forComponent:(NSInteger)component
           reusingView:(UILabel *)label
{
  if (!label) {
    label = [[UILabel alloc] initWithFrame:(CGRect){
      CGPointZero,
      {
        [pickerView rowSizeForComponent:component].width,
        [pickerView rowSizeForComponent:component].height,
      }
    }];
  }

  label.font = _font;

  label.textColor = [RCTConvert UIColor:_items[row][@"textColor"]] ?: _color;

  label.textAlignment = _textAlign;
  label.text = [self pickerView:pickerView titleForRow:row forComponent:component];
  return label;
}

- (void)pickerView:(__unused UIPickerView *)pickerView
      didSelectRow:(NSInteger)row inComponent:(__unused NSInteger)component
{
  [self didSelectRowAtIndex:row];
}

#else

#pragma mark - NSComboBoxDataSource protocol

- (BOOL)usesDataSource
{
  return YES;
}

- (NSInteger)numberOfItemsInComboBox:(__unused NSComboBox *)theComboBox
{
  return _items.count;
}

- (id)comboBox:(__unused NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
  return index >= 0 ? _items[index][@"label"] : nil;
}

#pragma mark - NSComboBoxDelegate methods

- (void)comboBoxSelectionDidChange:(__unused NSNotification *)notification
{
  [self didSelectRowAtIndex:self.indexOfSelectedItem];
}

#endif

- (void)didSelectRowAtIndex:(NSInteger)idx
{
  _selectedIndex = idx;
  if (_onChange && _items.count > (NSUInteger)idx) {
    _onChange(@{
                @"newIndex": @(idx),
                @"newValue": RCTNullIfNil(_items[idx][@"value"]),
                });
  }
}

@end
