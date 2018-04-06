/**
 * Copyright (C) 2009 bdferris <bdferris@onebusaway.org>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *         http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "OBAEditStopBookmarkViewController.h"
#import "OBATextFieldTableViewCell.h"
#import "OBAStopViewController.h"
#import "UITableViewCell+oba_Additions.h"
@import OBAKit;
#import "OneBusAway-Swift.h"

static NSString * const kBookmarkNameKey = @"BookmarkNameKey";

@interface OBAEditStopBookmarkViewController ()
@property(nonatomic,copy) OBABookmarkV2 *bookmark;
@property(nonatomic,strong) OBABookmarkGroup *selectedGroup;
@property(nonatomic,strong) NSMutableDictionary *fieldData;
@end

@implementation OBAEditStopBookmarkViewController

- (instancetype)initWithBookmark:(OBABookmarkV2 *)bookmark {
    self = [super init];

    if (self) {
        _bookmark = [bookmark copy];
        _selectedGroup = [_bookmark.group copy];

        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];

        self.navigationItem.title = NSLocalizedString(@"msg_edit_bookmark", @"OBABookmarkEditExisting");
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self loadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell<OBATableCell> *cell = (UITableViewCell<OBATableCell> *)[self.tableView cellForRowAtIndexPath:indexPath];
    if ([cell.tableRow.dataKey isEqual:kBookmarkNameKey]) {
        [((OBATextFieldCell*)cell).textField becomeFirstResponder];
    }
}

#pragma mark - Lazy Loading

- (OBAModelDAO*)modelDAO {
    if (!_modelDAO) {
        _modelDAO = [OBAApplication sharedApplication].modelDao;
    }
    return _modelDAO;
}

- (OBAModelService*)modelService {
    if (!_modelService) {
        _modelService = [OBAApplication sharedApplication].modelService;
    }
    return _modelService;
}

#pragma mark - Table Data

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.row == 1) {
//        OBABookmarkGroupsViewController *groups = [[OBABookmarkGroupsViewController alloc] init];
//        groups.enableGroupEditing = NO;
//        groups.delegate = self;
//        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:groups];
//
//        // Sometimes cannot edit the name of a bookmark when creating it
//        // see #933
//        [self.view endEditing:YES];
//        self.bookmark.name = self.textField.text;
//
//        [self presentViewController:nav animated:YES completion:nil];
//    }
//}

- (void)loadData {
    OBATextFieldRow *nameRow = [[OBATextFieldRow alloc] initWithLabelText:nil textFieldText:self.bookmark.name];
    nameRow.dataKey = kBookmarkNameKey;
    OBATableSection *nameSection = [[OBATableSection alloc] initWithTitle:@"Bookmark name" rows:@[nameRow]];

    OBATableSection *groupsSection = [[OBATableSection alloc] initWithTitle:@"Select a Group" rows:nil];
    for (OBABookmarkGroup *group in self.modelDAO.bookmarkGroups) {
        OBATableRow *tableRow = [[OBATableRow alloc] initWithTitle:group.name action:^(OBABaseRow *row) {
            self.selectedGroup = group;
            [self loadData];
        }];

        if ([self.selectedGroup.UUID isEqual:group.UUID]) {
            tableRow.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            tableRow.accessoryType = UITableViewCellAccessoryNone;
        }

        [groupsSection addRow:tableRow];
    }

    OBATableRow *noGroupRow = [[OBATableRow alloc] initWithTitle:@"(none)" action:^(OBABaseRow *row) {
        self.selectedGroup = nil;
        [self loadData];
    }];
    [groupsSection addRow:noGroupRow];
    if (!self.selectedGroup) {
        noGroupRow.accessoryType = UITableViewCellAccessoryCheckmark;
    }

    self.sections = @[nameSection, groupsSection];
    [self.tableView reloadData];
}

- (void)didSetBookmarkGroup:(OBABookmarkGroup *)group {
    self.selectedGroup = group;
}

#pragma mark - Actions

- (void)cancel:(id)sender {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)save:(id)sender {
    [self.view endEditing:YES];

    self.bookmark.name = self.fieldData[kBookmarkNameKey];

    if (![self.bookmark isValidModel]) {
        [AlertPresenter showWarning:NSLocalizedString(@"msg_cant_create_bookmark", @"Title of the alert shown when a bookmark can't be created") body:NSLocalizedString(@"msg_alert_bookmarks_must_have_name", @"Body of the alert shown when a bookmark can't be created.")];
        return;
    }

    if (!self.bookmark.group && !self.selectedGroup) {
        [self.modelDAO saveBookmark:self.bookmark];
    }
    else {
        [self.modelDAO moveBookmark:self.bookmark toGroup:self.selectedGroup];
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
