//
//  ViewController.m
//  Photos_Framework_Example
//
//  Created by Arpit.
//  Copyright © 2016 ArpitOnTheWay. All rights reserved.
//

#import "ViewController.h"
#import "CustomCellForLibrary.h"
#import <MediaPlayer/MediaPlayer.h>

@import Photos;

@interface ViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,PHPhotoLibraryChangeObserver>

{
    NSMutableArray *localIdentifierArray;
    NSMutableArray *utiString;
    NSMutableArray *imageArray;
    NSMutableArray *assetUrl;
    NSMutableArray *durationArray;
    MPMoviePlayerViewController *movieController;

}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) PHCachingImageManager *imageManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            [PHPhotoLibrary.sharedPhotoLibrary registerChangeObserver:self];
        }
    }];
    
    [self getDataForLibrary];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark: New Library

-(void)getDataForLibrary
{
    self.imageManager = [[PHCachingImageManager alloc] init];
    localIdentifierArray=[[NSMutableArray alloc]init];
    imageArray=[[NSMutableArray alloc] init];
    durationArray=[[NSMutableArray alloc]init];
    utiString=[[NSMutableArray alloc]init];
    assetUrl=[[NSMutableArray alloc]init];

    PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:nil];
    
    __block UIImage *image1;
    for (PHAsset *asset in result) {

        NSString *uti= [asset valueForKey:@"uniformTypeIdentifier"];
        [utiString addObject:uti]; // Array Containing Uniform Type Identifier
        
        
        NSString *localIdentifier=asset.localIdentifier; // Local Identifier

        localIdentifier=[localIdentifier substringToIndex:36];
        [localIdentifierArray addObject:localIdentifier]; // Array Containing Local Identifier
        

// IF YOU WANT ASSETURL:
      
        NSString *startString= [NSString stringWithFormat:@"assets-library://asset/asset.mov?id="];
        NSString *endString=[NSString stringWithFormat:@"&ext=mov"];
        localIdentifier=[localIdentifier stringByAppendingString:endString];
        NSString *assetString = [startString stringByAppendingString:localIdentifier];
        
        [assetUrl addObject:assetString];  // Array Containing Asset URLs of Videos
       
        
        float duration=asset.duration; //returns Duration Of Video
       
        
//For obtaining Duration in proper format, use this:
        
        CMTime duration1 = CMTimeMake(duration, 1);
        NSUInteger dTotalSeconds = CMTimeGetSeconds(duration1);
        NSUInteger dHours = floor(dTotalSeconds / 3600);
        NSUInteger dMinutes = floor(dTotalSeconds % 3600 / 60);
        NSUInteger dSeconds = floor(dTotalSeconds % 3600 % 60);
        NSString *videoDurationText = [NSString stringWithFormat:@"%lu:%02lu:%02lu",(unsigned long)dHours, (unsigned long)dMinutes, (unsigned long)dSeconds];
        
        [durationArray addObject:videoDurationText]; // Array Containing Duration of Videos
     
        
//To find out if the video is Landscape or Portrait, use this:
        NSInteger height=  asset.pixelHeight; // Pixel Height Of Video
        NSInteger width=  asset.pixelWidth;   // Pixel Width Of Video
       
        
        
        if (height > width)
        {
            
       // Video is Portrait
            
        }
        else if (height < width)
        {
            // Video is Landscape

        }
        else
        {
            // Video is Square
        }
        
//For obtaining thumbnails of Videos:
        PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
        requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        requestOptions.synchronous = true;
        NSMutableArray *images = [NSMutableArray arrayWithCapacity:[result count]];

        CGSize targetSize = CGSizeMake(400, 400);
        [self.imageManager requestImageForAsset:asset
                                     targetSize:targetSize
                                    contentMode:PHImageContentModeAspectFill
                                        options:requestOptions
                                  resultHandler:^void(UIImage *image, NSDictionary *info) {
                                    
                                      if(image!=nil)
                                      {
                                      image1 = image;
                                      [images addObject:image1];
                                      [imageArray addObject:image]; //Array Containing Thumbnails of Videos
                                      }
                                  }];
    }
    
    [self.collectionView reloadData];
}

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    [self getDataForLibrary];
}

#pragma mark: Collection View Data Source & Delegates


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [imageArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"customCell";
    
    CustomCellForLibrary *cell=[self.collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell)
    {
        cell = [[CustomCellForLibrary alloc]init];
    }
    
    [cell.imageView setImage:[imageArray objectAtIndex:indexPath.row]];
    
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.imageView.clipsToBounds = YES;
    cell.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    //NOTE: You can also show Duration on cell using "durationArray"
    
    
    
    return  cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(1,0, 1, 0); // top, left, bottom, right
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.2;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.8;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((collectionView.frame.size.width/2.004),(collectionView.frame.size.width/2.02));
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // For playing videos on click
   
    NSString *stringForVideo=[assetUrl objectAtIndex:indexPath.row];
    NSURL *urlForVideo=[NSURL URLWithString:stringForVideo];
  
    movieController = [[MPMoviePlayerViewController alloc] initWithContentURL:urlForVideo];
    movieController.modalPresentationStyle=UIModalTransitionStyleCrossDissolve;
    
    [self presentMoviePlayerViewControllerAnimated:movieController];
    [movieController.moviePlayer play];
}

@end
