//
//  AppDelegate.m
//  NSDiffableDataSource_test
//
//  Created by Gregory Casamento on 1/3/26.
//

#import "AppDelegate.h"
// #import <AppKit/NSDiffableDataSource.h>

@interface AppDelegate ()
@property (strong) IBOutlet NSDiffableDataSourceSnapshot *snapshot; // <NSString *, NSString *> *snapshot;
@property (strong) IBOutlet NSWindow *window;
@property (strong) IBOutlet NSCollectionView *collectionView;
@property (strong) IBOutlet NSTableView *tableView;

@property (strong) NSCollectionViewDiffableDataSource *dataSource; // <NSString *, NSString *> *dataSource;
@property (strong) NSTableViewDiffableDataSource *tableViewDataSource; // <NSString *, NSString *> *tableViewDataSource;
- (void)configureCollectionView;
- (void)configureTableView;
- (void)applyInitialSnapshot;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self configureCollectionView];
    [self configureTableView];
    [self applyInitialSnapshot];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}


#pragma mark - Diffable data source setup

- (void)configureCollectionView {
    if (self.collectionView == nil) {
        return; // Safety: outlet not wired in Interface Builder
    }

    // Simple flow layout to visualize items clearly
    NSCollectionViewFlowLayout *layout = [[NSCollectionViewFlowLayout alloc] init];
    layout.itemSize = NSMakeSize(140.0, 60.0);
    layout.minimumInteritemSpacing = 12.0;
    layout.minimumLineSpacing = 12.0;
    layout.sectionInset = NSEdgeInsetsMake(12.0, 12.0, 12.0, 12.0);
    self.collectionView.collectionViewLayout = layout;

    NSUserInterfaceItemIdentifier const cellIdentifier = @"Cell";
    [self.collectionView registerClass:[NSCollectionViewItem class]
                forItemWithIdentifier:cellIdentifier];

    __unsafe_unretained typeof(self) weakSelf = self; // weak references not available under manual ref counting
    self.dataSource = [[NSCollectionViewDiffableDataSource alloc]
        initWithCollectionView:self.collectionView
                  itemProvider:^NSCollectionViewItem * _Nullable(NSCollectionView *collectionView,
                                                                 NSIndexPath *indexPath,
                                                                 NSString *identifier) {
        NSCollectionViewItem *item = [collectionView makeItemWithIdentifier:cellIdentifier
                                                               forIndexPath:indexPath];

        // Configure a simple label for the item
        NSTextField *label = item.textField;
        if (label == nil) {
            // Create label with frame that fills the item view with some padding
            NSRect labelFrame = NSInsetRect(item.view.bounds, 10.0, 10.0);
            label = [[NSTextField alloc] initWithFrame:labelFrame];
            
            // Use autoresizing mask instead of constraints
            label.translatesAutoresizingMaskIntoConstraints = YES;
            label.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable | 
                                     NSViewMinXMargin | NSViewMaxXMargin | 
                                     NSViewMinYMargin | NSViewMaxYMargin;
            
            [label setEditable:NO];
            [label setBordered:NO];
            [label setBezeled:NO];
            [label setDrawsBackground:NO];
            [label setAlignment:NSTextAlignmentCenter];
            item.textField = label;
            [item.view addSubview:label];
        }

        label.stringValue = (identifier != nil) ? identifier : @"";
        label.font = [NSFont systemFontOfSize:15.0];

        return item;
    }];

    weakSelf.collectionView.dataSource = self.dataSource;
}

- (void)configureTableView {
    if (self.tableView == nil) {
        return; // Safety: outlet not wired in Interface Builder
    }

    // Configure table view column
    NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:@"MainColumn"];
    column.title = @"Items";
    column.width = 200.0;
    [self.tableView addTableColumn:column];

    __unsafe_unretained typeof(self) weakSelf = self; // weak references not available under manual ref counting
    self.tableViewDataSource = [[NSTableViewDiffableDataSource alloc]
        initWithTableView:self.tableView
             cellProvider:^NSView * _Nullable(NSTableView *tableView,
                                             NSTableColumn *tableColumn,
                                             NSInteger row,
                                             NSString *identifier) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"DataCell" owner:weakSelf];
        
        if (cellView == nil) {
            // Create a new cell view if one doesn't exist
            cellView = [[NSTableCellView alloc] init];
            cellView.identifier = @"DataCell";
            
            // Create and configure the text field
            NSTextField *textField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 180, 20)];
            textField.translatesAutoresizingMaskIntoConstraints = NO;
            textField.editable = NO;
            textField.bordered = NO;
            textField.drawsBackground = NO;
            
            [cellView addSubview:textField];
            cellView.textField = textField;
            
            // Add constraints
            [NSLayoutConstraint activateConstraints:@[
                [textField.leadingAnchor constraintEqualToAnchor:cellView.leadingAnchor constant:8],
                [textField.trailingAnchor constraintEqualToAnchor:cellView.trailingAnchor constant:-8],
                [textField.centerYAnchor constraintEqualToAnchor:cellView.centerYAnchor]
            ]];
        }
        
        cellView.textField.stringValue = (identifier != nil) ? identifier : @"";
        
        return cellView;
    }];

    self.tableView.dataSource = self.tableViewDataSource;
}

- (void)applyInitialSnapshot {
    if (self.dataSource == nil && self.tableViewDataSource == nil) {
        return; // Configure first
    }

    NSDiffableDataSourceSnapshot *snapshot = [[NSDiffableDataSourceSnapshot alloc] init];
    NSArray<NSString *> *sections = @[ @"Fruits" ];
    NSArray<NSString *> *items = @[ @"Apple", @"Banana", @"Cherry", @"Date", @"Elderberry", @"Fig" ];

    [snapshot appendSectionsWithIdentifiers:sections];
    [snapshot appendItemsWithIdentifiers:items intoSectionWithIdentifier:@"Fruits"];

    self.snapshot = snapshot;
    
    // Apply snapshot to collection view if configured
    if (self.dataSource != nil) {
        [self.dataSource applySnapshot:snapshot animatingDifferences:YES];
    }
    
    // Apply snapshot to table view if configured
    if (self.tableViewDataSource != nil) {
        [self.tableViewDataSource applySnapshot:snapshot animatingDifferences:YES];
    }
}

@end
