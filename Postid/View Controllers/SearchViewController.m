//
//  SearchViewController.m
//  Postid
//
//  Created by Philip Bale on 8/30/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import "SearchViewController.h"
#import "PostidManager.h"
#import "User.h"
#import "SearchCell.h"
#import "PostidApi.h"
#import "Realm.h"

@interface SearchViewController () <UISearchControllerDelegate, UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate>
{
    
}

@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, strong) NSArray *generalSearchResults;
@end

static BOOL phoneAuthenticated;

@implementation SearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    if ([[PostidManager sharedManager] currentUser].phoneNumber.length == 0) {
        [DigitsKit logOut];
        self.resultsTableView.hidden = YES;
        self.authenticateButton = [DGTAuthenticateButton buttonWithAuthenticationCompletion:^(DGTSession *session, NSError *error) {
            User *currentUser = [[PostidManager sharedManager] currentUser];
            if ([session.phoneNumber length])
            {
                __weak typeof(self) weakSelf = self;
                [currentUser setPhoneNumber:session.phoneNumber];
                [PostidApi updatePhoneNumber:session.phoneNumber forToken:currentUser.token completion:^(BOOL success, User *user) {
                    if (success)
                    {
                        [[PostidManager sharedManager] setCurrentUser:user];
                        [weakSelf.authenticateButton setHidden:YES];
                        [weakSelf.authenticateButton removeFromSuperview];
                        phoneAuthenticated = true;
                        [weakSelf generalViewLoad];
                        [weakSelf viewDidAppear:YES];
                    }
                }];
            }
        }];
        
        self.authenticateButton.layer.borderColor = PRIMARY_COLOR.CGColor;
        self.authenticateButton.layer.borderWidth = 2;
        self.authenticateButton.layer.cornerRadius = 5;
        self.authenticateButton.center = self.view.center;
        [self.authenticateButton setTitleColor:PRIMARY_COLOR forState:UIControlStateNormal];
        [self.authenticateButton setBackgroundColor:[UIColor clearColor]];
        [self.authenticateButton setTitle:@"Authenticate Phone to Search" forState:UIControlStateNormal];
        [self.view addSubview:self.authenticateButton];
    } else {
        phoneAuthenticated = YES;
        [self generalViewLoad];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.searchController dismissViewControllerAnimated:NO completion:nil];
}

- (void)generalViewLoad
{
    self.resultsTableView.hidden = NO;
    self.resultsTableView.dataSource = self;
    self.resultsTableView.delegate = self;
    
    self.searchController = [[FriendSearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchController.searchBar.showsCancelButton = NO;
    
    
    
    //[[UITextField appearanceWhenContainedInInstancesOfClasses:[UISearchBar class]] setDefaultTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    self.navigationItem.titleView = self.searchController.searchBar;
    [self refreshGeneralSearchResults];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (phoneAuthenticated)
    {
        UITextField *searchField = [self.searchController.searchBar valueForKey:@"_searchField"];
        
        // Change magnifying class color
        if ([searchField.leftView isKindOfClass:[UIImageView class]])
        {
            UIImageView* imgView = (UIImageView*)searchField.leftView;
            UIImage* searchImg = [imgView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            imgView.image = searchImg;
            [imgView setTintColor: [UIColor whiteColor]];
        }
        
        if ([searchField conformsToProtocol:@protocol(UITextInputTraits)])
        {
            [searchField setClearButtonMode:UITextFieldViewModeNever];
        }
        
        [searchField setTextColor:[UIColor whiteColor]];
    }
    
    [self refreshGeneralSearchResults];
    [self.resultsTableView reloadData];
    
}

- (void)refreshGeneralSearchResults
{
    User *currentUser = [[PostidManager sharedManager] currentUserFromRealm];
    //self.generalSearchResults = [[User objectsWhere:@"userId != %@", [NSNumber numberWithInteger:currentUser.userId]] sortedResultsUsingProperty:@"firstName" ascending:YES];
    NSMutableArray *allUsers = [[NSMutableArray alloc] init];
    
    for (User *user in currentUser.pendingFriends)
    {
        [allUsers addObject:user];
    }
    for (User *user in currentUser.friends)
    {
       [allUsers addObject:user];
    }
    
    allUsers = [[allUsers sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        User *first = obj1;
        User *second = obj2;
        
        if ([first.name isEqualToString:second.name])
        {
            return NSOrderedSame;
        } else {
            return [first.name compare:obj2];
        }
    }] mutableCopy];
    
    self.generalSearchResults = allUsers;
    
    [self.resultsTableView reloadData];
    
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText length] == 0) {
        [searchBar performSelectorOnMainThread:@selector(resignFirstResponder) withObject:nil waitUntilDone:NO];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    //[self.searchBar resignFirstResponder];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = searchController.searchBar.text;
    if ([searchString isEqualToString:@""]) return;
    [PostidApi searchForFriends:searchString forToken:[PostidManager sharedManager].currentUser.token  completion:^(BOOL success, NSArray *results) {
        if (success) {
            User* currentUser = [[PostidManager sharedManager] currentUserFromRealm];
            
            [[RLMRealm defaultRealm] beginWriteTransaction];
            {
                for (User *user in results)
                {
                    [User createOrUpdateInDefaultRealmWithValue:user];
                    if (![user inUserCache] && ![user pendingFriendsWithPrimaryUser]) {
                        [currentUser.userCache addObject:user];
                    }
                }
                [User createOrUpdateInDefaultRealmWithValue:currentUser];
            }
            
            [[RLMRealm defaultRealm] commitWriteTransaction];
            self.searchResults = results;
            [self.resultsTableView reloadData];
        }
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchController.isActive && !self.searchController.isBeingDismissed && ![self.searchController.searchBar.text isEqualToString:@""])
    {
        return [self.searchResults count];
    } else {
        NSLog(@"Pulling from general");
        return [self.generalSearchResults count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchCell" forIndexPath:indexPath];
    User *user;
    if (self.searchController.isActive && !self.searchController.isBeingDismissed && ![self.searchController.searchBar.text isEqualToString:@""])
    {
        user = [self.searchResults objectAtIndex:indexPath.row];
    } else {
        user = [self.generalSearchResults objectAtIndex:indexPath.row];
    }
    
    cell.userFullName.text = user.name;
    cell.userUsername.text = user.username;
    cell.userId = user.userId;
    
    if ([user friendsWithPrimaryUser])
    {
        [cell.rightWidget setTitle:@"" forState:UIControlStateNormal];
        [cell.rightWidget setEnabled:NO];
    }
    else if ([user pendingFriendsWithPrimaryUser])
    {
        [cell.rightWidget setTitle:@"Pending" forState:UIControlStateNormal];
        [cell.rightWidget setEnabled:NO];
    }
    else
    {
        [cell.rightWidget setTitle:@"Add" forState:UIControlStateNormal];
        [cell.rightWidget setEnabled:YES];
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.searchResults = nil;
    [self.resultsTableView reloadData];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    self.searchResults = nil;
    [self.resultsTableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
