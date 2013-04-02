#import <UIKit/UIKit.h>

@interface PNCNavigationItemPicker : UITableViewController {
	id _delegate;
	NSArray *_navigationItems;
	NSInteger _minimumIndex;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, copy) NSArray *navigationItems;

@end
