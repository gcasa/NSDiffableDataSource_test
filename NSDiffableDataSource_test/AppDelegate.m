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
@property (strong) NSCollectionViewDiffableDataSource *dataSource; // <NSString *, NSString *> *dataSource;
- (void)configureCollectionView;
- (void)applyInitialSnapshot;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self configureCollectionView];
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

    NSUserInterfaceItemIdentifier const cellIdentifier = RETAIN(@"Cell");
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
            label = [[NSTextField alloc] initWithFrame:NSZeroRect];
            label.translatesAutoresizingMaskIntoConstraints = NO;
            [label setEditable:NO];
            [label setBordered:NO];
            [label setBezeled:NO];
            [label setDrawsBackground:NO];
            item.textField = label;
            [item.view addSubview:label];
            [NSLayoutConstraint activateConstraints:@[
                [NSLayoutConstraint constraintWithItem:label
                                             attribute:NSLayoutAttributeCenterX
                                             relatedBy:NSLayoutRelationEqual
                                                toItem:item.view
                                             attribute:NSLayoutAttributeCenterX
                                            multiplier:1.0
                                              constant:0.0],
                [NSLayoutConstraint constraintWithItem:label
                                             attribute:NSLayoutAttributeCenterY
                                             relatedBy:NSLayoutRelationEqual
                                                toItem:item.view
                                             attribute:NSLayoutAttributeCenterY
                                            multiplier:1.0
                                              constant:0.0]
            ]];
        }

        label.stringValue = (identifier != nil) ? identifier : @"";
        label.font = [NSFont systemFontOfSize:15.0];

        return item;
    }];

    weakSelf.collectionView.dataSource = self.dataSource;
}

- (void)applyInitialSnapshot {
    if (self.dataSource == nil) {
        return; // Configure first
    }

    NSDiffableDataSourceSnapshot *snapshot = [[NSDiffableDataSourceSnapshot alloc] init];
    NSArray<NSString *> *sections = @[ @"Fruits" ];
    NSArray<NSString *> *items = @[ @"Apple", @"Banana", @"Cherry", @"Date" ];

    [snapshot appendSectionsWithIdentifiers:sections];
    [snapshot appendItemsWithIdentifiers:items intoSectionWithIdentifier:@"Fruits"];

    self.snapshot = snapshot;
    [self.dataSource applySnapshot:snapshot animatingDifferences:YES];
}

@end
