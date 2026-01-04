//
//  AppDelegate.m
//  NSDiffableDataSource_test
//
//  Created by Gregory Casamento on 1/3/26.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@property (strong) IBOutlet NSDiffableDataSourceSnapshot<NSString *, NSString *> *snapshot;
@property (strong) IBOutlet NSWindow *window;
@property (strong) IBOutlet NSCollectionView *collectionView;
@property (strong) NSCollectionViewDiffableDataSource<NSString *, NSString *> *dataSource;
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

    NSUserInterfaceItemIdentifier const cellIdentifier = @"Cell";
    [self.collectionView registerClass:[NSCollectionViewItem class]
                forItemWithIdentifier:cellIdentifier];

    __weak typeof(self) weakSelf = self;
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
            label = [NSTextField labelWithString:identifier];
            label.translatesAutoresizingMaskIntoConstraints = NO;
            item.textField = label;
            [item.view addSubview:label];
            [NSLayoutConstraint activateConstraints:@[
                [label.centerXAnchor constraintEqualToAnchor:item.view.centerXAnchor],
                [label.centerYAnchor constraintEqualToAnchor:item.view.centerYAnchor]
            ]];
        }

        label.stringValue = identifier;
        label.font = [NSFont systemFontOfSize:15.0 weight:NSFontWeightSemibold];

        item.view.wantsLayer = YES;
        item.view.layer.backgroundColor = NSColor.windowBackgroundColor.CGColor;
        item.view.layer.cornerRadius = 8.0;
        item.view.layer.borderWidth = 1.0;
        item.view.layer.borderColor = NSColor.separatorColor.CGColor;

        return item;
    }];

    weakSelf.collectionView.dataSource = self.dataSource;
}

- (void)applyInitialSnapshot {
    if (self.dataSource == nil) {
        return; // Configure first
    }

    NSDiffableDataSourceSnapshot<NSString *, NSString *> *snapshot = [[NSDiffableDataSourceSnapshot alloc] init];
    NSArray<NSString *> *sections = @[ @"Fruits" ];
    NSArray<NSString *> *items = @[ @"Apple", @"Banana", @"Cherry", @"Date" ];

    [snapshot appendSectionsWithIdentifiers:sections];
    [snapshot appendItemsWithIdentifiers:items intoSectionWithIdentifier:@"Fruits"];

    self.snapshot = snapshot;
    [self.dataSource applySnapshot:snapshot animatingDifferences:YES];
}

@end
