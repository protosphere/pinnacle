#import <Foundation/Foundation.h>

@class PNCNavigationItemPicker;

@protocol PNCNavigationItemPickerDelegate

- (void)navigationItemPicker:(PNCNavigationItemPicker *)picker didPickItemAtIndex:(NSInteger)index;

@end
