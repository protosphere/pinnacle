#import <UIKit/UIKit.h>
#import "PNCNavigationItemPicker.h"

@interface UINavigationController (Pinnacle)
- (void)pinnaclePopToViewControllerAtIndex:(NSInteger)index;
@end

@interface UINavigationBar (Private)
- (id)currentBackButton;
- (id)navigationItems;
@end

#define PNCRectContainsPoint(rect, point) (point.x >= rect.origin.x && point.x <= rect.size.width && point.y >= rect.origin.y && point.y <= rect.size.height)

static char kPNCPinnacleGestureRecognizerKey;
static NSDictionary *preferences = nil;

static void reloadPreferences()
{
	NSString *preferencesFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.protosphere.pinnacle.plist"];

	[preferences release];
	preferences = [[NSDictionary alloc] initWithContentsOfFile:preferencesFilePath];
}

%hook UINavigationBar

- (id)initWithFrame:(CGRect)frame
{
	self = %orig;

	if (self) {
		UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pinnacleHandleHold:)];
		[longPressRecognizer setDelegate:(id<UILongPressGestureRecognizerDelegate>)self];

		[self addGestureRecognizer:longPressRecognizer];

		objc_setAssociatedObject(self, &kPNCPinnacleGestureRecognizerKey, longPressRecognizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

		[longPressRecognizer release];
	}

	return self;
}

%new
- (void)pinnacleHandleHold:(UIGestureRecognizer *)gestureRecognizer
{
	id backButton = [self currentBackButton];
	
	if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
		if ([[self delegate] respondsToSelector:@selector(pinnaclePopToViewControllerAtIndex:)]) {
			BOOL shouldShowMenu = ([preferences objectForKey:@"showmenu"] ? [[preferences objectForKey:@"showmenu"] boolValue] : NO);

			if (shouldShowMenu) {
				PNCNavigationItemPicker *itemPicker = [[PNCNavigationItemPicker alloc] init];
				[itemPicker setDelegate:self];
				[itemPicker setNavigationItems:[self navigationItems]];

				if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
					UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:itemPicker];
					[popover setDelegate:(id<UIPopoverControllerDelegate>)self];
					[popover presentPopoverFromRect:[backButton frame] inView:backButton permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
				} else {
					UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:itemPicker];
					[[self delegate] presentModalViewController:navigationController animated:YES];

					[navigationController release];
				}

				[itemPicker release];
			} else {
				[[self delegate] pinnaclePopToViewControllerAtIndex:0];
			}
		}
	}
}

- (BOOL)_gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
	if (gestureRecognizer == objc_getAssociatedObject(self, &kPNCPinnacleGestureRecognizerKey)) {
		BOOL enabled = ([preferences objectForKey:@"enabled"] ? [[preferences objectForKey:@"enabled"] boolValue] : YES);

		id backButton = [self currentBackButton];
		CGPoint touchLocation = [gestureRecognizer locationInView:self];

		// The back button appears to have a minimum touchable area of 100pt * navbar height. 
		CGRect validTouchArea = CGRectMake(0, 0, MAX(100, CGRectGetWidth([backButton bounds])), CGRectGetHeight([self bounds]));
		BOOL isValidTouch = PNCRectContainsPoint(validTouchArea, touchLocation);
		
		return (enabled && backButton && isValidTouch);
	} else {
		return %orig;
	}
}

%new
- (void)navigationItemPicker:(PNCNavigationItemPicker *)picker didPickItemAtIndex:(NSInteger)index
{
	if ([[self delegate] respondsToSelector:@selector(pinnaclePopToViewControllerAtIndex:)]) {
		[[self delegate] pinnaclePopToViewControllerAtIndex:index];
	}
}

%new
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [popoverController release];
}

%end

%hook UINavigationController

%new
- (void)pinnaclePopToViewControllerAtIndex:(NSInteger)index
{
	UIViewController *viewController = [[self viewControllers] objectAtIndex:index];
	[self popToViewController:viewController animated:YES];
}

%end

%ctor
{
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, reloadPreferences, CFSTR("com.protosphere.pinnacle.settingsupdated"), NULL, 0);
	reloadPreferences();
}
