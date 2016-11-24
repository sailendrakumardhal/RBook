//
//  ReceipeDetailViewController.m
//  RBook
//
//  Created by Andolasoft on 8/26/16.
//  Copyright © 2016 Andola. All rights reserved.
//

#import "ReceipeDetailViewController.h"
#import <MXParallaxHeader/MXScrollView.h>
#import "ReceipeParallexView.h"
#import "Constant.h"
#import "URLRequest.h"
#import "ReceipeDetailBO.h"
#import"UIImageView+WebCache.h"
#import <JTSImageViewController/JTSImageViewController.h>
#import "FirebaseManager.h"

@interface ReceipeDetailViewController ()<MXScrollViewDelegate>
{
    ReceipeParallexView *viewReceipe;
}
@property (nonatomic, strong) MXScrollView *scrollView;

@end

@implementation ReceipeDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    UINavigationBar *naviBarObj = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 1024, 110)];
    
    
    [self designTheReceipeDetailScreen];
    
    [[FirebaseManager sharedInstance] dbReferenceWithChild:@"recipe" andSuperChild:self.selectedReceipe.recipe_id];
    [[FirebaseManager sharedInstance] retrieveDatawithCompleteBlock:^(id object, NSError *error) {
        if (object) {
            NSDictionary *dictRecipe = (NSDictionary *)object;
            ReceipeDetailBO *recipeDtlBO = [[ReceipeDetailBO alloc] initWithDictionary:dictRecipe error:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                //Update screen
                [self updateDetailScreenWithdata:recipeDtlBO];
            });
        } else
            [self apiCallForReceipeDetail];
    }];
}

- (void)designTheReceipeDetailScreen
{
    self.title = self.selectedReceipe.title;
    
    // Parallax Header
    [self.view addSubview:self.scrollView];

    CGRect frame = self.view.frame;
    
    //Update scroll view frame and content size
    self.scrollView.frame = self.view.bounds;
    self.scrollView.contentSize = frame.size;
    
    viewReceipe = (ReceipeParallexView *)[NSBundle.mainBundle loadNibNamed:@"ReceipeParallexView" owner:self options:nil].firstObject;
    CGRect rectViewRecipe = viewReceipe.frame;
    rectViewRecipe.size.height = 350;
    viewReceipe.frame = rectViewRecipe;
        
    self.scrollView.parallaxHeader.view = viewReceipe; // You can set the parallax header view from a nib.
    self.scrollView.parallaxHeader.height = 300;
    self.scrollView.parallaxHeader.mode = MXParallaxHeaderModeFill;
    self.scrollView.parallaxHeader.minimumHeight = 20;

    UILabel *lblIngredients = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, SCREEN_SIZE.width-20, 30)];
    lblIngredients.text = @"Ingredients";
    lblIngredients.textAlignment = NSTextAlignmentLeft;
    lblIngredients.textColor = [UIColor purpleColor];
    lblIngredients.font = [UIFont fontWithName:@"Avenir" size:25];
    [self.scrollView addSubview:lblIngredients];
    
    UITextView *txtVwIngredient = [[UITextView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lblIngredients.frame), SCREEN_SIZE.width, 100)];
    txtVwIngredient.tag = 5400;
    txtVwIngredient.editable = NO;
    txtVwIngredient.font = [UIFont fontWithName:@"Avenir" size:15];
    txtVwIngredient.textAlignment = NSTextAlignmentLeft;
    [self.scrollView addSubview:txtVwIngredient];
    
    viewReceipe.imgVwBg.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tapGesture:)];
    tapGesture1.numberOfTapsRequired = 1;
    [viewReceipe.imgVwBg addGestureRecognizer:tapGesture1];
}

- (void)updateDetailScreenWithdata:(ReceipeDetailBO *)receipe
{
    [viewReceipe.imgVwBg sd_setImageWithURL:[NSURL URLWithString:receipe.image_url]];
    
    UITextView *txtVwIngrediaent = (UITextView *)[self.view viewWithTag:5400];
    NSString *strIngredients = [receipe.ingredients componentsJoinedByString:@"\n"];
    txtVwIngrediaent.text = strIngredients;
    
    CGSize size = [strIngredients boundingRectWithSize:CGSizeMake(txtVwIngrediaent.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:txtVwIngrediaent.font} context:nil].size;
    
    CGRect rectTxtVwIngredient = txtVwIngrediaent.frame;
    rectTxtVwIngredient.size.height = size.height + 30;
    txtVwIngrediaent.frame = rectTxtVwIngredient;
    
    float height = CGRectGetMaxY(txtVwIngrediaent.frame)>CGRectGetMaxY(self.view.frame)?CGRectGetMaxY(txtVwIngrediaent.frame):CGRectGetMaxY(self.view.frame);
                                                                                                                                            
    self.scrollView.contentSize = CGSizeMake(SCREEN_SIZE.width, height);
}

- (void)apiCallForReceipeDetail
{
    NSString *postParameters = [NSString stringWithFormat:@"key=%@&rId=%@", API_KEY, self.selectedReceipe.recipe_id];
    
    [[URLRequest sharedInstance] APIPostReauestWithService:GET_RECIPES withParameter:postParameters andHTTPMethod:POST withCompleteBlock:^(id object, NSError *error) {
        if (error == nil) {
            
            NSDictionary *dictRecipe = [object objectForKey:@"recipe"];
            
            [[FirebaseManager sharedInstance] dbReferenceWithChild:@"recipe" andSuperChild:self.selectedReceipe.recipe_id];
            [[FirebaseManager sharedInstance] saveDataWithValue:dictRecipe withCompleteBlock:^(id object, NSError *error) {
                
            }];

//            ReceipeDetailBO *recipeDtlBO = [[ReceipeDetailBO alloc] initWithDictionary:dictRecipe error:nil];
//
//            NSLog(@"recipeDtlBO = %@", recipeDtlBO.ingredients.description);
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                //Update screen
//                [self updateDetailScreenWithdata:recipeDtlBO];
//            });
        }
    }];
}

// In this example I use manual layout for peformances
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

#pragma mark Properties

- (MXScrollView *)scrollView {
    if(!_scrollView) {
        _scrollView = [[MXScrollView alloc] init];
        _scrollView.delegate = self;
    }
    return _scrollView;
}

#pragma mark <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"progress %f", self.scrollView.parallaxHeader.progress);
    if (self.scrollView.parallaxHeader.progress < 0) {
        viewReceipe.imgVwBg.alpha = 1.0 + (self.scrollView.parallaxHeader.progress);
    }
}

- (void) tapGesture: (id)sender
{
    //handle Tap...
    
    // Create image info
    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
    imageInfo.image = [viewReceipe.imgVwBg image];
    imageInfo.referenceRect = viewReceipe.imgVwBg.frame;
    imageInfo.referenceView = viewReceipe.imgVwBg.superview;
    
    // Setup view controller
    JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                           initWithImageInfo:imageInfo
                                           mode:JTSImageViewControllerMode_Image
                                           backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled];
    
    // Present the view controller.
    [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
