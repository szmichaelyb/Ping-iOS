//
//  GCReviewViewController.m
//  GoCandid
//
//  Created by Rishabh Tayal on 9/13/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "GCReviewViewController.h"
#import <AviarySDK/AviarySDK.h>
#import "PGPingViewController.h"
#import "GCReviewCell.h"
#import <UIAlertView+Blocks/UIAlertView+Blocks.h>

static NSString * const kAFAviaryAPIKey = @"a2095a01a8bde2f7";
static NSString * const kAFAviarySecret = @"a50ce6288a3d78f1";

@interface GCReviewViewController ()<AFPhotoEditorControllerDelegate>

@property (nonatomic, strong) IBOutlet UICollectionView* collectionView;
@property (nonatomic, strong) NSIndexPath* selectedIndexPath;

@end

@implementation GCReviewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(gotoNextView:)]];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)gotoNextView:(id)sender
{
    PGPingViewController* pingVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PGPingViewController"];
    pingVC.images = _images;
    pingVC.delegate = _delegate;
    [self.navigationController pushViewController:pingVC animated:YES];
}

- (IBAction)backbuttonClicked:(id)sender
{
    [UIAlertView showWithTitle:@"Start over" message:@"Are you sure? This will discard the current picture." cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Yes"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

#pragma mark - UICollectionView Datasource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _images.count;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GCReviewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.imageView.image = _images[indexPath.item];
    return cell;
}

#pragma mark - UICollectionView Delegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedIndexPath = indexPath;
    
    [self launchPhotoEditorWithImage:_images[indexPath.item] highResolutionImage:nil];
}

#pragma mark - Photo Editor Creation and Presentation
- (void) launchPhotoEditorWithImage:(UIImage *)editingResImage highResolutionImage:(UIImage *)highResImage
{
    // Customize the editor's apperance. The customization options really only need to be set once in this case since they are never changing, so we used dispatch once here.
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setPhotoEditorCustomizationOptions];
    });
    
    // Initialize the photo editor and set its delegate
    AFPhotoEditorController * photoEditor = [[AFPhotoEditorController alloc] initWithImage:editingResImage];
    [photoEditor setDelegate:self];
    
    // If a high res image is passed, create the high res context with the image and the photo editor.
    //    if (highResImage) {
    //        [self setupHighResContextForPhotoEditor:photoEditor withImage:highResImage];
    //    }
    
    // Present the photo editor.
    [self presentViewController:photoEditor animated:YES completion:nil];
    //    [self.navigationController pushViewController:photoEditor animated:YES];
}

- (void) photoEditor:(AFPhotoEditorController *)editor finishedWithImage:(UIImage *)image
{
    
    //    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    //    if (_overalayImage) {
    
    //Create GIF from _overlayimage and image
    
    //    [self.navigationController pushViewController:pingVC animated:YES];
    //    [[self imagePreviewView] setImage:image];
    //    [[self imagePreviewView] setContentMode:UIViewContentModeScaleAspectFit];
    //
    
    _images[_selectedIndexPath.item] = image;
    
    [self.collectionView reloadItemsAtIndexPaths:@[_selectedIndexPath]];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

// This is called when the user taps "Cancel" in the photo editor.
- (void) photoEditorCanceled:(AFPhotoEditorController *)editor
{
    //    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Photo Editor Customization

- (void) setPhotoEditorCustomizationOptions
{
    // Set API Key and Secret
    [AFPhotoEditorController setAPIKey:kAFAviaryAPIKey secret:kAFAviarySecret];
    
    // Set Tool Order
    NSArray * toolOrder = @[kAFEffects, kAFFocus, kAFFrames, kAFStickers, kAFEnhance, kAFOrientation, kAFAdjustments, kAFSplash, kAFDraw, kAFText, kAFRedeye, kAFWhiten, kAFBlemish, kAFMeme];
    [AFPhotoEditorCustomization setToolOrder:toolOrder];
    
    // Set Custom Crop Sizes
    [AFPhotoEditorCustomization setCropToolOriginalEnabled:NO];
    [AFPhotoEditorCustomization setCropToolCustomEnabled:NO];
    NSDictionary * fourBySix = @{kAFCropPresetHeight : @(4.0f), kAFCropPresetWidth : @(6.0f)};
    NSDictionary * fiveBySeven = @{kAFCropPresetHeight : @(5.0f), kAFCropPresetWidth : @(7.0f)};
    NSDictionary * square = @{kAFCropPresetName: @"Square", kAFCropPresetHeight : @(1.0f), kAFCropPresetWidth : @(1.0f)};
    [AFPhotoEditorCustomization setCropToolPresets:@[fourBySix, fiveBySeven, square]];
    
    [AFPhotoEditorCustomization setNavBarImage:[UIImage imageNamed:@"navbar"]];
    
    [AFPhotoEditorCustomization setLeftNavigationBarButtonTitle:kAFLeftNavigationTitlePresetBack];
    
    // Set Supported Orientations
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        NSArray * supportedOrientations = @[@(UIInterfaceOrientationPortrait), @(UIInterfaceOrientationPortraitUpsideDown), @(UIInterfaceOrientationLandscapeLeft), @(UIInterfaceOrientationLandscapeRight)];
        [AFPhotoEditorCustomization setSupportedIpadOrientations:supportedOrientations];
    }
}
@end
