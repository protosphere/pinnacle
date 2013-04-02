#import "PNCNavigationItemPicker.h"
#import "PNCNavigationItemPickerDelegate.h"

@interface UIViewController (Private)
- (id)_popoverController;
@end	

@implementation PNCNavigationItemPicker

@synthesize delegate = _delegate;
@synthesize navigationItems = _navigationItems;

- (id)init
{
	self = [super init];

	if (self) {
		[self setTitle:@"History"];

		UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTapped:)];
		[[self navigationItem] setRightBarButtonItem:cancelButton];
		[cancelButton release];
	}
	
	return self;
}

- (void)dealloc
{
	[_navigationItems release];

	[super dealloc];
}

- (void)setNavigationItems:(NSArray *)navigationItems
{
	[_navigationItems release];
	_navigationItems = [navigationItems copy];

	for (int i = 0; i < [_navigationItems count]; i++) {
		UINavigationItem *item = [_navigationItems objectAtIndex:i];

		if ([item hidesBackButton]) {
			_minimumIndex = i;
		}
	}

	[self setContentSizeForViewInPopover:CGSizeMake(320, MAX(352, [_navigationItems count] * 44))];
}

- (void)cancelTapped:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];	
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellIdentifier = @"NavigationItemCell";

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
	}

	UINavigationItem *navigationItem = [[self navigationItems] objectAtIndex:([[self navigationItems] count] - [indexPath row] - 2)];
	[[cell textLabel] setText:([navigationItem title] ?: @"(No Title)")];

	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[self navigationItems] count] - _minimumIndex - 1;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([[self delegate] respondsToSelector:@selector(navigationItemPicker:didPickItemAtIndex:)]) {
		[[self delegate] navigationItemPicker:self didPickItemAtIndex:([[self navigationItems] count] - [indexPath row] - 2)];
	}

	[[self _popoverController] dismissPopoverAnimated:YES];
	[self dismissModalViewControllerAnimated:YES];
}

@end
