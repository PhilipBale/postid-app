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
#import "PostidApi.h"

@interface SearchViewController () <UISearchControllerDelegate, UISearchResultsUpdating>
{
    
}

@end

static BOOL phoneAuthenticated;

@implementation SearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    if ([[PostidManager sharedManager] currentUser].phoneNumber.length == 0) {
        [DigitsKit logOut];
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

- (void)generalViewLoad
{
    self.searchController = [[FriendSearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = YES;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    
    //[[UITextField appearanceWhenContainedInInstancesOfClasses:[UISearchBar class]] setDefaultTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    self.navigationItem.titleView = self.searchController.searchBar;
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
    }
    
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
    //[self searchForText:searchString scope:searchController.searchBar.selectedScopeButtonIndex];
    //[self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    [self updateSearchResultsForSearchController:self.searchController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
