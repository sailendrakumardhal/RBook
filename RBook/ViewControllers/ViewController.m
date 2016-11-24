//
//  ViewController.m
//  RBook
//
//  Created by Andola on 24/08/16.
//  Copyright © 2016 Andola. All rights reserved.
//

#import "ViewController.h"
#import "Constant.h"
#import "URLRequest.h"
#import "RecipeDataBO.h"
#import "ReceipeDetailViewController.h"
#import "ReceipeCell.h"
#import "FirebaseManager.h"
#import "AppDelegate.h"
#import "ProfileViewController.h"

@interface ViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>
{
    CGFloat width, height;
    UIBarButtonItem *btnSearchBarBtn, *btnSort;
    UISearchBar *searchBar;
    UIView *viewLoader;
    UIView *viewBottomLoader;
    UIRefreshControl *refreshControl;
    NSInteger pages;
    UITableView *tblMenu;
    BOOL isMenuOpen;
}

@end

@implementation ViewController

NSString *const kResetPasswordConfigKey = @"ResetPassword";
NSString *const kSignOutConfigKey       = @"SignOut";
NSString *const kProfileConfigKey       = @"Profile";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
        
    if (self.isFromCreateAccount) {
        // Present the Profile VC
        
        ProfileViewController *rcpDtlVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ProfileVC"];
        [self.navigationController presentViewController:rcpDtlVC animated:YES completion:nil];
    }
    
    self.navigationItem.hidesBackButton = YES;
    pages = 1;
    
    // Menu bar
    isMenuOpen = NO;
    tblMenu = [[UITableView alloc] init];
    tblMenu.frame = CGRectMake(0.0, 0.0, 150.0, 132.0);
    tblMenu.delegate = self;
    tblMenu.dataSource = self;
    tblMenu.bounces = NO;
    [self.view addSubview:tblMenu];
    [self closeMenu];
    
    self.arrrecepiData = [NSMutableArray new];
        
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar.png"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationItem.title = @"Top Recipes";
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
        
    [self searchBarDesign];
    [self setupLayout];
    
    [[FirebaseManager sharedInstance] dbReferenceWithChild:@"recipes" andSuperChild:[NSString stringWithFormat:@"%ld", (long)pages]];
    [[FirebaseManager sharedInstance] retrieveDatawithCompleteBlock:^(id object, NSError *error) {
        if (object) {
            NSArray *arrResponse = (NSArray *)object;
            for (NSDictionary *dictRecipe in arrResponse) {
                
                RecipeDataBO *recipeBO = [[RecipeDataBO alloc] initWithDictionary:dictRecipe error:nil];
                [self.arrrecepiData addObject:recipeBO];
            }
            [self.foodCollection reloadData];
        } else
            [self getRecipeListingsWithQuery:@"all" andPages:[NSString stringWithFormat:@"%ld", (long)pages] AndIsLoadMore:NO];
    }];
}

-(void)designCustomLoader {
    if (viewLoader != nil) {
        return;
    }
    
    viewLoader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    viewLoader.center = self.view.center;
    viewLoader.backgroundColor = [UIColor clearColor];
    [self.view addSubview:viewLoader];
    
    UIImageView *imgVwDish = [[UIImageView alloc] initWithFrame:CGRectMake(viewLoader.frame.size.width/2 - 25, viewLoader.frame.size.height/2 - 25 - 32, 50, 50)];
    imgVwDish.image = [UIImage imageNamed:@"Dish.png"];
    imgVwDish.backgroundColor = [UIColor clearColor];
    imgVwDish.contentMode = UIViewContentModeScaleAspectFit;
    [viewLoader addSubview:imgVwDish];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = [NSNumber numberWithFloat:0];
    animation.toValue = [NSNumber numberWithFloat:2 * M_PI];
    animation.duration = 1.0;
    animation.repeatCount = HUGE_VALF;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [imgVwDish.layer addAnimation:animation forKey:@"rotationAnimation"];
}
 
- (void)removeCustomLoader
{
    if (viewLoader) {
        [viewLoader removeFromSuperview];
        viewLoader = nil;
    }
}

-(void)searchBarDesign
{
    // create the magnifying glass button
    btnSearchBarBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"searchIcon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(searchButtonTapped:)];
    self.navigationItem.rightBarButtonItem = btnSearchBarBtn;
    
    // create sort button
    btnSort = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings.png"] style:UIBarButtonItemStylePlain target:self action:@selector(sortButtonTapped:)];
    self.navigationItem.leftBarButtonItem = btnSort;
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    searchBar = [[UISearchBar alloc] init];
    searchBar.showsCancelButton = YES;
    searchBar.placeholder = @"Search recipe...                                   ";
    searchBar.delegate = self;
}

- (void)sortButtonTapped:(id)sender
{
    if (tblMenu) {
        if (isMenuOpen) {
            [self closeMenu];
        } else {
            [self openMenu];
        }
        return;
    }
    
    tblMenu = [[UITableView alloc] init];
    tblMenu.frame = CGRectMake(0.0, 0.0, 150.0, 132.0);
    tblMenu.delegate = self;
    tblMenu.dataSource = self;
    tblMenu.bounces = NO;
    [self.view addSubview:tblMenu];
    [self openMenu];
    [tblMenu reloadData];
}

- (void)openMenu
{
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         CGRect frame = tblMenu.frame;
                         frame.size.height = 132;
                         tblMenu.frame = frame;
                     }
                     completion:^(BOOL finished){
                         isMenuOpen = YES;
                     }];
}

- (void)closeMenu
{
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         CGRect frame = tblMenu.frame;
                         frame.size.height = 0;
                         tblMenu.frame = frame;
                     }
                     completion:^(BOOL finished){
                         isMenuOpen = NO;
                     }];
}

- (void)searchButtonTapped:(id)sender {
    
    [UIView animateWithDuration:0.5 animations:^{
        
    } completion:^(BOOL finished) {
        
        // remove the search button
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.leftBarButtonItem = nil;
        // add the search bar (which will start out hidden).
        self.navigationItem.titleView = searchBar;
        searchBar.alpha = 0.0;
        
        [UIView animateWithDuration:0.5
                         animations:^{
                             searchBar.alpha = 1.0;
                         } completion:^(BOOL finished) {
                             [searchBar becomeFirstResponder];
                         }];
    }];
}

#pragma mark - UISearchBarDelegate methods
// called when cancel button pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchedBar {
    
    [UIView animateWithDuration:0.5f animations:^{
        searchBar.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.navigationItem.titleView = nil;
        self.navigationItem.rightBarButtonItem = btnSearchBarBtn;
        self.navigationItem.leftBarButtonItem = btnSort;
        [UIView animateWithDuration:0.5f animations:^ {
        }];
    }];
}

- (void)setupLayout
{
    //Added Refresh controll for pull to refresh
    refreshControl = [[UIRefreshControl alloc]init];
    [self.foodCollection addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
}

- (void)refreshTable {
    [refreshControl endRefreshing];
    [self.foodCollection reloadData];
}

#pragma mark - Add Loader view in the bottom of the view
-(void)addLoaderViewAtBottom {
    viewBottomLoader = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-40, self.view.frame.size.width, 40)];
    [viewBottomLoader setBackgroundColor:[UIColor lightGrayColor]];
    [self.view addSubview:viewBottomLoader];
    
    UIImageView *imgVwDish = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_SIZE.width/2) - 15, viewBottomLoader.frame.size.height/2 - 15, 30, 30)];
    imgVwDish.image = [UIImage imageNamed:@"Dish.png"];
    imgVwDish.backgroundColor = [UIColor clearColor];
    imgVwDish.contentMode = UIViewContentModeScaleAspectFit;
    [viewBottomLoader addSubview:imgVwDish];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = [NSNumber numberWithFloat:0];
    animation.toValue = [NSNumber numberWithFloat:2 * M_PI];
    animation.duration = 1.0;
    animation.repeatCount = HUGE_VALF;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [imgVwDish.layer addAnimation:animation forKey:@"rotationAnimation"];
}

-(void)hideLoaderView {
    [UIView animateWithDuration:1
                     animations:^(void) {
                         [viewBottomLoader setFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 40)];
                         if (viewBottomLoader) {
                             [viewBottomLoader removeFromSuperview];
                             viewBottomLoader = nil;
                         }
                     }];
}

#pragma mark - Service call
-(void)getRecipeListingsWithQuery:(NSString *)query andPages:(NSString *)page AndIsLoadMore:(BOOL)isLoadMore
{
    if (isLoadMore) {
        [self addLoaderViewAtBottom];
    }
    else
    {
        [self designCustomLoader];
    }
    NSString *postParameters = [NSString stringWithFormat:@"key=%@&q=%@&sort=%@&page=%@", API_KEY, query, SORTINGBYRATING, page];
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[URLRequest sharedInstance] APIPostReauestWithService:SEARCH_RECIPES withParameter:postParameters andHTTPMethod:POST withCompleteBlock:^(id object, NSError *error) {
            if (error == nil) {
                NSMutableArray *arrResponse = [[NSMutableArray alloc] init];
                arrResponse = [object objectForKey:@"recipes"];
                
                // Save data in Firebase DB
                // Create a reference to a Firebase database URL
                [[FirebaseManager sharedInstance] dbReferenceWithChild:@"recipes" andSuperChild:[NSString stringWithFormat:@"%ld", (long)pages]];
                [[FirebaseManager sharedInstance] saveDataWithValue:arrResponse withCompleteBlock:^(id object, NSError *error) {
                    
                }];
                
                for (NSDictionary *dictRecipe in arrResponse) {
                    
                    RecipeDataBO *recipeBO = [[RecipeDataBO alloc] initWithDictionary:dictRecipe error:nil];
                    [self.arrrecepiData addObject:recipeBO];
                }
                pages ++;
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (isLoadMore) {
                        [self hideLoaderView];
                    }else{
                        [self removeCustomLoader];
                    }
                    [self.foodCollection reloadData];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (isLoadMore) {
                        [self hideLoaderView];
                    }else{
                        [self removeCustomLoader];
                    }
                });
            }
        }];
    });
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.arrrecepiData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"FoodCell";
    ReceipeCell *cell = (ReceipeCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.2];
    
    RecipeDataBO *recepiData = [self.arrrecepiData objectAtIndex: indexPath.row];
    
    [cell.imgVwReceipe sd_setImageWithURL:[NSURL URLWithString:recepiData.image_url] placeholderImage:[UIImage imageNamed:@"loadingPlaceholder.jpg"] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType,NSURL *imageurl) {
        
    }];
    cell.lblSocialRating.text = [NSString stringWithFormat:@"Rank: %@", [[recepiData.social_rank componentsSeparatedByString:@"."] firstObject]];
    cell.lblSocialRating.layer.masksToBounds = YES;
    cell.lblSocialRating.layer.cornerRadius = 10.0f;
    
    cell.lblTitlercp.text = recepiData.title;
    
    if (indexPath.row == [self.arrrecepiData count] - 1)
    {
         [self getRecipeListingsWithQuery:@"all" andPages:[NSString stringWithFormat:@"%ld", (long)pages] AndIsLoadMore:YES];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    if (indexPath.item % 3 == 0) {
        float cellWidth = (CGRectGetWidth(collectionView.frame) - (flowLayout.sectionInset.left + flowLayout.sectionInset.right));
        return CGSizeMake(cellWidth, cellWidth / 2 + 50);
    } else {
        float cellWidth = (CGRectGetWidth(collectionView.frame) - (flowLayout.sectionInset.left + flowLayout.sectionInset.right) - flowLayout.minimumInteritemSpacing) / 2;
        return CGSizeMake(cellWidth, cellWidth);
    }
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    RecipeDataBO *recepiData = [self.arrrecepiData objectAtIndex: indexPath.row];

    ReceipeDetailViewController *rcpDtlVC = (ReceipeDetailViewController *)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DetailVC"];
    rcpDtlVC.selectedReceipe = recepiData;
    [self.navigationController pushViewController:rcpDtlVC animated:YES];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"Cell"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    }
    if ([indexPath section] == 0) {
        if ([indexPath row] == 0) {
            cell.textLabel.text = APP_DELEGATE.configRef[kResetPasswordConfigKey].stringValue;
        }
        else if ([indexPath row] == 1) {
            cell.textLabel.text = APP_DELEGATE.configRef[kProfileConfigKey].stringValue;
        } else {
            cell.textLabel.text = APP_DELEGATE.configRef[kSignOutConfigKey].stringValue;
        }
    }
    else {
        
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        if ([indexPath row] == 0) {
            [[FirebaseManager sharedInstance] resetPasswordWithEmail:kGetUserDefault(@"UserEmail") withCompleteBlock:^(id object, NSError *error) {
                if (!error) {
                    [APP_DELEGATE displayMessageWithTitle:@"RBook" withMessage:@"Reset password link has been sent to your registered email id" andAlertType:ISAlertTypeSuccess];
                } else {
                    [APP_DELEGATE displayMessageWithTitle:@"RBook" withMessage:error.localizedDescription andAlertType:ISAlertTypeError];
                }
            }];
        }
        else if ([indexPath row] == 1) {
            ProfileViewController *rcpDtlVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ProfileVC"];
            rcpDtlVC.isViewProfile = YES;
            [self.navigationController presentViewController:rcpDtlVC animated:YES completion:nil];
        } else {
            [[FirebaseManager sharedInstance] signOutAccountWithCompleteBlock:^(id object, NSError *error) {
                if ([(NSString *)object isEqualToString:@"success"]) {
                    // Log out
                    kRemoveUserDefault(@"UserAuth");
                    kRemoveUserDefault(@"UserEmail");
                    [self.navigationController popToRootViewControllerAnimated:NO];
                }
            }];
        }
    }
    [self closeMenu];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Other
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
