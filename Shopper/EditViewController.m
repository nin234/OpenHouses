//
//  EditViewController.m
//  Shopper
//
//  Created by Ninan Thomas on 12/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "EditViewController.h"
#import "AlbumContentsViewController.h"
#import "AppDelegate.h"
#import "MainViewController.h"
#include <sys/types.h>
#include <dirent.h>
#import "MapViewController.h"
#import <MapKit/MkMapView.h>
#import <MapKit/MkTypes.h>
#import "NotesViewController.h"
#import <MapKit/MkMapView.h>
#import <MapKit/MkTypes.h>
#import "ImageIO/ImageIO.h"
#import "CoreFoundation/CoreFoundation.h"
#include <MobileCoreServices/UTCoreTypes.h>
#include <MobileCoreServices/UTType.h>
#import <MediaPlayer/MediaPlayer.h>
#include <sys/time.h>
#import "AVFoundation/AVAssetImageGenerator.h"
#import "AVFoundation/AVAsset.h"
#import "AVFoundation/AVTime.h"
#import "CoreMedia/CMTime.h"
#import "textdefs.h"

#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

@implementation EditViewController

@synthesize imagePickerController;
@synthesize pBarItem;
@synthesize pBarItem3;
@synthesize pSlider;
@synthesize nSmallest;
@synthesize bSliderPic;
@synthesize tnailurls;
@synthesize movurls;

- (NSMetadataQuery*) imagesQuery 
{
    NSMetadataQuery* aQuery = [[NSMetadataQuery alloc] init];
    if (aQuery) 
    {
        // Search the Documents subdirectory only.
        [aQuery setSearchScopes:[NSArray
                                 arrayWithObject:NSMetadataQueryUbiquitousDocumentsScope]];

        
        // Add a predicate for finding the documents.
        NSString* filePattern = @"*.jpg";
        [aQuery setPredicate:[NSPredicate predicateWithFormat:@"%K LIKE %@",
                              NSMetadataItemFSNameKey, filePattern]];
    }
    
    return aQuery;
}

-(void) queryStop
{
    processQuery = false;
    if (query != nil)
        [query stopQuery];
    
}

- (void)processQueryResults:(NSNotification*)aNotification
{
    if (!processQuery)
        return;
    [query disableUpdates];
     AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *queryResults = [query results];
    NSLog(@"Processing iCloud query results no of items %lu for album %@\n", (unsigned long)[queryResults count], pDlg.pAlName);
    NSMutableArray *thumbindexes = [[NSMutableArray alloc] initWithCapacity:[queryResults count]];
    
    for (NSMetadataItem *result in queryResults) 
    {
        NSURL *fileURL = [result valueForAttribute:NSMetadataItemURLKey];
     //   NSLog(@"Processing item at URL %@ \n", fileURL);
        if ([[result valueForAttribute:NSMetadataUbiquitousItemIsDownloadedKey] boolValue] == NO)
            continue;
        
        NSNumber *aBool = nil;
        [fileURL getResourceValue:&aBool forKey:NSURLIsRegularFileKey error:nil];
        if (aBool && [aBool boolValue])
        {
            NSString *str = [fileURL absoluteString];
            NSRange found = [str rangeOfString:pDlg.pAlName options:NSBackwardsSearch];
            if (found.location == NSNotFound)
                continue;
            NSURL *pIsThumbnail = [fileURL URLByDeletingLastPathComponent];
            NSString *last = [pIsThumbnail lastPathComponent];
            if ([last isEqualToString:@"thumbnails"] == YES)
            {
                NSString *pFil = [fileURL lastPathComponent];
                char szFileNo[64];
                int size = (int)strcspn([pFil UTF8String], ".");
                if (size)
                {
                    strncpy(szFileNo, [pFil UTF8String], size);
                    szFileNo[size] = '\0';
                    int val = strtod(szFileNo, NULL);
                    [thumbindexes addObject:[NSNumber numberWithInt:val]];
                }
                
            }
        }
    }
    NSArray *tIndxes = [NSArray arrayWithArray:[thumbindexes sortedArrayUsingComparator: ^(id obj1, id obj2) {
        
        if ([obj1 integerValue] > [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if ([obj1 integerValue] < [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }]];
    
    
    NSUInteger tcnt = [tIndxes count];
    if (tcnt)
    {
        nSmallest = [[tIndxes objectAtIndex:0] intValue];
    }
    
    [self.tableView reloadData];
    [query enableUpdates];
    return;
}

- (void)setupAndStartQuery 
{
    // Create the query object if it does not exist.
    if (!query)
        query = [self imagesQuery];
    
    // Register for the metadata query notifications.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(processQueryResults:)
                                                 name:NSMetadataQueryDidFinishGatheringNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(processQueryResults:)
                                                 name:NSMetadataQueryDidUpdateNotification
                                               object:nil];
    
    // Start the query and let it run.
    NSLog(@"In set up and  start query %@\n", query);
    if (![query startQuery])
        NSLog(@"Failed to start query %@\n", query);
    if ([query isStarted])
        NSLog(@"Started query %@\n", query);
    if ([query isGathering])
        NSLog(@" query Gathering %@\n", query);

}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        imagePickerController = [[UIImagePickerController alloc] init];
       // tnailurls = [NSMutableArray arrayWithCapacity:100];
       // movurls = [NSMutableArray arrayWithCapacity:100];
        bInShowCam = false;
        processQuery = true;
        pBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(takePhoto) ];
        pBarItem.width = 30;
	pSlider = [[MySlider alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        pSlider.continuous = NO;
        bSliderPic = true;
        [pSlider addTarget:self action:@selector(sliderUpdate:) forControlEvents:UIControlEventValueChanged];
       pSlider.minimumValueImage = [UIImage imageNamed:@"camera1.png"];//stretchableImageWithLeftCapWidth: 9 topCapHeight: 0];
        
        pSlider.maximumValueImage = [UIImage imageNamed:@"video.png"];//stretchableImageWithLeftCapWidth: 9 topCapHeight: 0];
        pSlider.thumbTintColor = [UIColor whiteColor];
        pSlider.minimumTrackTintColor = [UIColor redColor];
        pSlider.maximumTrackTintColor = [UIColor redColor];
        pBarItem3 = [[UIBarButtonItem alloc] initWithCustomView:pSlider];
        bInPicCapture = false;
        bSaveLastPic = false;
        nSmallest = 0;
        
        AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	     NSString *pAlMoc = pDlg.pAlName;
	    printf("In DisplayViewController edit album name %s\n", [pAlMoc UTF8String]);
	    if (pAlMoc == nil)
            return self;
	    NSURL *albumurl = [NSURL URLWithString:pAlMoc];
	    [self findSmallest:albumurl];
    }
    return self;
}

-(void) findSmallest: (NSURL * ) albumurl
{
    char szFileNo[64];
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
   // NSError *err;
	NSArray *keys = [NSArray arrayWithObject:NSURLIsRegularFileKey];
        NSArray *files = [pDlg.pFlMgr contentsOfDirectoryAtURL:albumurl includingPropertiesForKeys:keys options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
        NSUInteger cnt = [files count];
        for (NSUInteger i = 0; i < cnt; ++i)
        {
            NSURL *fileurl = [files objectAtIndex:i];
            NSError *error;
            NSNumber *isReg;
            if ([fileurl getResourceValue:&isReg forKey:NSURLIsRegularFileKey error:&error] == YES)
            {
                if ([isReg boolValue] == YES)
                {
                    NSString *pFil = [fileurl lastPathComponent];
                    int size = strcspn([pFil UTF8String], ".");
                    if (size)
                    {
                        strncpy(szFileNo, [pFil UTF8String], size);
                        szFileNo[size] = '\0';
                        int val = strtod(szFileNo, NULL);
                        if (val < nSmallest)
                            nSmallest = val;
                        if (nSmallest == 0)
                            nSmallest = val;
                    }
                    
                }
            }
            else
            {
                NSLog(@"Failed to get resource value %@\n", error);
            }
            
        }
        

	return;
}

- (void)sliderUpdate:(id)sender 
{
    UISlider *slider = (UISlider *)sender;
    float val = slider.value;
    NSLog(@"In slider update value %f\n", val);
    if (val < 0.5)
    {
        if (bInPicCapture)
        {
            [slider setValue:1.0 animated:YES];
            return;
        }
        if (pBarItem.enabled == NO)
        {
            if (!bSliderPic)
            {
                [slider setValue:1.0 animated:YES];
                return;
            }
        }
        
        pBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(takePhoto) ];
        CGFloat barY, barHeight;
        NSLog(@"Setting camera toolbar bounds %f\n" , imagePickerController.cameraOverlayView.bounds.size.height);
        if (imagePickerController.cameraOverlayView.bounds.size.height > 500.00)
        {
            barY = imagePickerController.cameraOverlayView.bounds.size.height - 95;
            barHeight = 95;
        }
        else
        {
            barY = imagePickerController.cameraOverlayView.bounds.size.height - 55;
            barHeight = 55;
        }
        
        UIToolbar *bar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, barY, 325, barHeight)];
        
        
        UIBarButtonItem *pBarItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(photosDone) ];
        UIBarButtonItem *pBarItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil ];
        // pBarItem2.width = 100;
        UIBarButtonItem *pBarItem4 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil ];
        NSArray *baritems = [NSArray arrayWithObjects:pBarItem1, pBarItem2, pBarItem, pBarItem4, pBarItem3, nil];
        [bar setItems:baritems];
        [imagePickerController.cameraOverlayView addSubview:bar];
        imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        gettimeofday(&last_mode_change, 0);
    }
    else 
    {
        
        if (pBarItem.enabled == NO)
        {
            if (bSliderPic)
            {
                [slider setValue:0.0 animated:YES];
                return;
            }
        }
        pBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Record-Button-off.png"] style:UIBarButtonItemStylePlain target:self action:@selector(takePhoto)];
        CGFloat barY, barHeight;
        NSLog(@"Setting camera toolbar bounds %f\n" , imagePickerController.cameraOverlayView.bounds.size.height);
        barY = imagePickerController.cameraOverlayView.bounds.size.height - 55;
        barHeight = 55;
        
        UIToolbar *bar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, barY, 325, barHeight)];
        UIBarButtonItem *pBarItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(photosDone) ];
        UIBarButtonItem *pBarItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil ];
        // pBarItem2.width = 100;
        UIBarButtonItem *pBarItem4 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil ];
        NSArray *baritems = [NSArray arrayWithObjects:pBarItem1, pBarItem2, pBarItem, pBarItem4, pBarItem3, nil];
        [bar setItems:baritems];
        NSArray *pVws = [imagePickerController.cameraOverlayView subviews];
        int cnt = [pVws count];
        for (NSUInteger i=0; i < cnt; ++i)
        {
            [[pVws objectAtIndex:i] removeFromSuperview];
        }
        [imagePickerController.cameraOverlayView addSubview:bar];
        imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
        gettimeofday(&last_mode_change, 0);

    }
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

-(void) loadView
{
    [super loadView];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"DisplayViewController will appear\n");
    if (query != nil)
    {
        
        if (![query isStarted])
        {
            NSLog(@"Start query in EditViewController\n");
            [query startQuery];
            processQuery = true;
        }
    }

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"DisplayViewController will disappear\n");
    if (query != nil)
    {
        
        if (![query isStopped])
        {
            NSLog(@"Stop query in EditViewController\n");
            [query stopQuery];
            processQuery = false;
        }
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
     AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *pBarItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:pDlg action:@selector(itemEditCancel)];
    self.navigationItem.leftBarButtonItem = pBarItem1;
    NSString *title = @"Edit Info";
    self.navigationItem.title = [NSString stringWithString:title];
    UIBarButtonItem *pBarItemEditDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:pDlg action:@selector(itemEditDone)];
    self.navigationItem.rightBarButtonItem = pBarItemEditDone;
    

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    if (query != nil)
    {
        NSLog(@"Stop query in EditViewController\n");
        [query stopQuery];
    }
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 1;
}

-(void) takePhoto
{
   
    NSLog(@"Slider value %f\n", pSlider.value);
    struct timeval tv;
    gettimeofday(&tv, 0);
    if (tv.tv_sec - last_mode_change.tv_sec < 2)
    {
        NSLog(@"too near the last mode change ignoring\n");
        return;
    }

    if (pSlider.value < 0.5)
    {
        if (bInPicCapture)
        {
            [imagePickerController stopVideoCapture];
            NSLog(@"Stopping video capture\n");
       //     pBarItem.enabled = NO;
            bInPicCapture = false;
        }
        else
        {
            
            [imagePickerController takePicture];
   //         pBarItem.enabled = NO;
            pBarItem.tintColor =  [UIColor redColor];
            NSLog(@"Taking picture\n");
        }
    }
    else
    {
        //Show video camera icon
        if (bInPicCapture)
        {
            
            [imagePickerController stopVideoCapture];
            NSLog(@"Stopping video capture\n");
            pBarItem.tintColor = [UIColor blueColor];
            pBarItem.enabled = NO;
            bInPicCapture = false;
        }
        else
        {
          
            
            
            if ([imagePickerController startVideoCapture] == YES)
            {
                NSLog(@"Starting video capture\n");
               // pBarItem.tintColor = [UIColor redColor];
               
                pBarItem.tintColor =  [UIColor redColor];
                pBarItem.enabled = YES;
                bInPicCapture = true;
            }
            else 
                NSLog(@"Start video capture failed\n");
        }
        
    }
    
}

-(void) saveThumbNails:(UIImage *) img
{
    NSUInteger tcnt = [tnailurls count];
    NSUInteger mcnt = [movurls count];
    NSLog(@"Saving thumbnails tcnt %d mcnt %d\n", tcnt, mcnt);
    
    if (tcnt != mcnt || !tcnt)
        return;
    
    
     
    for (NSUInteger i =0; i < mcnt; ++i)
    {
        NSLog(@"Trying to save thumbnail %@ for movie %@\n", [tnailurls objectAtIndex:i], [movurls objectAtIndex:i]);
       // if (i != 0)
         //   pMovP.contentURL = [movurls objectAtIndex:i];
         MPMoviePlayerController *pMovP = [[MPMoviePlayerController alloc] initWithContentURL:[movurls objectAtIndex:i]];
   
        [pMovP pause];
    
        UIImage *thumbnail = [pMovP thumbnailImageAtTime:0 timeOption:MPMovieTimeOptionNearestKeyFrame];
        [pMovP pause];
        NSData *thumbnaildata = UIImageJPEGRepresentation(thumbnail, 0.3);

        if ([thumbnaildata writeToURL:[tnailurls objectAtIndex:i] atomically:YES] == NO)
        {
            NSLog(@"Failed to write to thumbnail file %@\n", [tnailurls objectAtIndex:i]);
        }
        else
        {
            NSLog(@"Save thumbnail file %@\n", [tnailurls objectAtIndex:i]);
        }
     
    }    
    [movurls removeAllObjects];
    [tnailurls removeAllObjects];
    [self.tableView reloadData];
    if (bInShowCam)
    {
        [imagePickerController dismissModalViewControllerAnimated:NO];
          
        NSLog(@"Dismissed  imagePickerController about to show it again in Save thumbnails\n");
        [self presentModalViewController:imagePickerController animated:YES];
    }
    return;
}

-(void) photosDone
{
    if (bInPicCapture)
    {
        
        [imagePickerController stopVideoCapture];
        NSLog(@"Stopping video capture\n");
        pBarItem.enabled = YES;
        bInPicCapture = false;
         pBarItem.tintColor =  [UIColor blueColor];
        bSaveLastPic = true;
        return;
    }
   /* 
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIImage *img;
    NSInvocationOperation* theOp = [[NSInvocationOperation alloc] initWithTarget:self
                                                                        selector:@selector(saveThumbNails:) object:img];
    NSLog(@"Add save thumbnail to queue\n");
    [pDlg.saveQ addOperation:theOp];
*/
    [imagePickerController dismissModalViewControllerAnimated:NO];
    [self.tableView reloadData];
    bInShowCam = false;
}

-(void) AddPicture
{
    
    printf ("Show Camera\n");
    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear] == NO)
        return;

    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
	imagePickerController.editing = YES;
    imagePickerController.delegate = (id)self;
    imagePickerController.showsCameraControls = NO;
    imagePickerController.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypeCamera];
    CGFloat barY, barHeight;
    NSLog(@"Setting camera toolbar bounds %f\n" , imagePickerController.cameraOverlayView.bounds.size.height);
    if (imagePickerController.cameraOverlayView.bounds.size.height > 500.00 && pSlider.value < 0.5)
    {
        barY = imagePickerController.cameraOverlayView.bounds.size.height - 95;
        barHeight = 95;
    }
    else
    {
        barY = imagePickerController.cameraOverlayView.bounds.size.height - 55;
        barHeight = 55;
    }
    
    UIToolbar *bar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, barY, 325, barHeight)];
       

     UIBarButtonItem *pBarItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(photosDone) ];
    UIBarButtonItem *pBarItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil ];
   // pBarItem2.width = 100;
    UIBarButtonItem *pBarItem4 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil ];
    NSArray *baritems = [NSArray arrayWithObjects:pBarItem1, pBarItem2, pBarItem, pBarItem4, pBarItem3, nil];
    [bar setItems:baritems];
   
    [imagePickerController.cameraOverlayView addSubview:bar];
    if(pSlider.value < 0.5)
        imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    else 
        imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
    [self presentModalViewController:imagePickerController animated:YES];
    bInShowCam = true;
}

-(void) saveMovie:(NSURL *)movie
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    struct timeval tv;
    gettimeofday(&tv, 0);
    int filno = tv.tv_sec/2;

    NSString *pFlName = [[NSNumber numberWithInt:filno] stringValue];
    NSString *pImgFlName = [pFlName stringByAppendingString:@".jpg"];
    
    pFlName = [pFlName stringByAppendingString:@".MOV"];
    
    NSData *data = [NSData dataWithContentsOfURL:movie];
    
    NSURL *pFlUrl;
    NSError *err;
    NSURL *albumurl = [NSURL URLWithString:pDlg.pAlName];
    if (albumurl != nil && [albumurl checkResourceIsReachableAndReturnError:&err])
    {
        
        pFlUrl = [albumurl URLByAppendingPathComponent:pFlName isDirectory:NO];
    }
    else 
    {
        
        pFlUrl = [pDlg.cloudDocsURL URLByAppendingPathComponent:@"albums" isDirectory:YES];
        pFlUrl = [pFlUrl URLByAppendingPathComponent:pDlg.pAlName isDirectory:YES];
        pFlUrl = [pFlUrl URLByAppendingPathComponent:pFlName isDirectory:NO];
    }
    
    NSDictionary *dict = [pDlg.pFlMgr attributesOfItemAtPath:[pFlUrl path] error:&err];
    if (dict != nil)
        NSLog (@"Loading image in DisplayViewController %@ file size %lld\n", pFlUrl, [dict fileSize]);
    else 
        NSLog (@"Loading image in DisplayViewController %@ file size not obtained\n", pFlUrl);
    
    
    if ([data writeToURL:pFlUrl atomically:YES] == NO)
    {
        printf("Failed to write to file %d\n", filno);
        // --nAlNo;
        
    }
    else
    {
        printf("Save file %d in album %s\n", filno, [pDlg.editItem.album_name UTF8String]);
        ++pDlg.editItem.pic_cnt;
    }

    //[movurls addObject:pFlUrl];
    
    
    
    
    
   NSURL *movurl = pFlUrl; 
    pFlUrl = [pFlUrl URLByDeletingLastPathComponent];
    pFlUrl = [pFlUrl URLByAppendingPathComponent:@"thumbnails" isDirectory:YES];
    pFlUrl = [pFlUrl URLByAppendingPathComponent:pImgFlName isDirectory:NO];
//    [tnailurls addObject:pFlUrl];
	AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:[AVAsset assetWithURL:movurl]];
    
    
    
    CMTime thumbTime = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    
    CGImageRef startImage = [generator copyCGImageAtTime:thumbTime actualTime:&actualTime error:&error];
    UIImage *image = [UIImage imageWithCGImage:startImage];
    
    CGSize oImgSize;
    oImgSize.height = 71;
    oImgSize.width = 71;
    UIGraphicsBeginImageContext(oImgSize);
    [image drawInRect:CGRectMake(0, 0, oImgSize.width, oImgSize.height)];
    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //  CGImageRef thumbnailImageRef = MyCreateThumbnailImageFromData (data, 5);
    // UIImage *thumbnail = [UIImage imageWithCGImage:thumbnailImageRef];
    CGSize pImgSiz = [thumbnail size];
    NSLog(@"Added thumbnail Image height = %f width=%f \n", pImgSiz.height, pImgSiz.width);
    
        NSData *thumbnaildata = UIImageJPEGRepresentation(thumbnail, 0.3);
        
        if ([thumbnaildata writeToURL:pFlUrl atomically:YES] == NO)
        {
            NSLog(@"Failed to write to thumbnail file %d thumburl %@\n", filno, pFlUrl);
            // --nAlNo;
            
        }
        else
        {
            NSLog(@"Save thumbnail file %@\n", pFlUrl);
        }

     
    return;
}

-(void) saveImage:(UIImage *)image
{
     AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    struct timeval tv;
    gettimeofday(&tv, 0);
    int filno = tv.tv_sec/2;
    NSString *pFlName = [[NSNumber numberWithInt:filno] stringValue];
    
    pFlName = [pFlName stringByAppendingString:@".jpg"];
    
    
    NSURL *pFlUrl;
    NSError *err;
    NSURL *albumurl = [NSURL URLWithString:pDlg.pAlName];
    if (albumurl != nil && [albumurl checkResourceIsReachableAndReturnError:&err])
    {

        pFlUrl = [albumurl URLByAppendingPathComponent:pFlName isDirectory:NO];
    }
    else 
    {
        
        pFlUrl = [pDlg.cloudDocsURL URLByAppendingPathComponent:@"albums" isDirectory:YES];
        pFlUrl = [pFlUrl URLByAppendingPathComponent:pDlg.pAlName isDirectory:YES];
        pFlUrl = [pFlUrl URLByAppendingPathComponent:pFlName isDirectory:NO];
    }
    
    NSDictionary *dict = [pDlg.pFlMgr attributesOfItemAtPath:[pFlUrl path] error:&err];
    if (dict != nil)
        NSLog (@"Loading image in DisplayViewController %@ file size %lld\n", pFlUrl, [dict fileSize]);
    else 
        NSLog (@"Loading image in DisplayViewController %@ file size not obtained\n", pFlUrl);
    
    
    
    
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    if ([data writeToURL:pFlUrl atomically:YES] == NO)
    {
        NSLog(@"Failed to write to file %d %@\n", filno, pFlUrl);
        // --nAlNo;
        
    }
    else
    {
        printf("Save file %d in album %s\n", filno, [pDlg.editItem.album_name UTF8String]);
    }
    CGSize oImgSize;
    oImgSize.height = 71;
    oImgSize.width = 71;
    UIGraphicsBeginImageContext(oImgSize);
    [image drawInRect:CGRectMake(0, 0, oImgSize.width, oImgSize.height)];
    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //  CGImageRef thumbnailImageRef = MyCreateThumbnailImageFromData (data, 5);
    // UIImage *thumbnail = [UIImage imageWithCGImage:thumbnailImageRef];
    CGSize pImgSiz = [thumbnail size];
    NSLog(@"Added thumbnail Image height = %f width=%f \n", pImgSiz.height, pImgSiz.width);
    
    NSData *thumbnaildata = UIImageJPEGRepresentation(thumbnail, 0.3);
    pFlUrl = [pFlUrl URLByDeletingLastPathComponent];
    pFlUrl = [pFlUrl URLByAppendingPathComponent:@"thumbnails" isDirectory:YES];
    pFlUrl = [pFlUrl URLByAppendingPathComponent:pFlName isDirectory:NO];
    if ([thumbnaildata writeToURL:pFlUrl atomically:YES] == NO)
    {
        NSLog (@"Failed to write to thumbnail file %d %@\n", filno, pFlUrl);
        // --nAlNo;
        
    }
    else
    {
        printf("Save thumbnail file %d in album %s\n", filno, [pDlg.editItem.album_name UTF8String]);
        ++pDlg.editItem.pic_cnt;
    }
    
    
    
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    printf("printing album names\n");
    int nLargest;
    if (pDlg.editItem.album_name == nil)
    {
        
        nLargest = 0;
        
        // pDlg.pFlMgr = [[NSFileManager alloc] init];
        NSString *pHdir = NSHomeDirectory();
        NSString *pAlbums = @"/Documents/albums";
        NSString *pAlbumsDir = [pHdir stringByAppendingString:pAlbums];
        printf("create new album name %d in directory %s\n", nLargest, [pAlbumsDir UTF8String]);
        DIR *dirp = opendir([pAlbumsDir UTF8String]);
        struct dirent *dp;
        if (dirp)
        {
            while ((dp = readdir(dirp)) != NULL) 
            {
                if (dp->d_namlen)
                {
                    printf ("file name= %s\n", dp->d_name);
                    int val = strtod(dp->d_name, NULL);
                    if (nLargest < val)
                        nLargest = val;
                }
            }
        }
        ++nLargest;
        printf("Incremented nLargest to %d\n", nLargest);
        NSString *intStr = [[NSNumber numberWithInt:nLargest] stringValue];
        pAlbumsDir = [pAlbumsDir stringByAppendingString:@"/"];
        NSString *pNewAlbum = [pAlbumsDir stringByAppendingString:intStr];
        pDlg.editItem.album_name = intStr;
        pDlg.pAlName = pNewAlbum;
        NSString *pThumpnail = [pNewAlbum stringByAppendingPathComponent:@"thumbnails"];
        BOOL  bDirCr = [pDlg.pFlMgr createDirectoryAtPath:pThumpnail withIntermediateDirectories:YES attributes:nil error:nil];
        if(bDirCr == YES)
        {
            printf ("Created new album %s\n", [pThumpnail UTF8String]);
        }
        else
        {
            return;
        }
    }
     NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
        
    // Handle a still image capture
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) 
    {
        
        UIImage* image = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
    
        NSInvocationOperation* theOp = [[NSInvocationOperation alloc] initWithTarget:self
                                                                         selector:@selector(saveImage:) object:image];
        [pDlg.saveQ addOperation:theOp];
        pBarItem.enabled = YES;
        pBarItem.tintColor =  [UIColor blueColor];
    }
     else if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0)
        == kCFCompareEqualTo) 
     {
         NSLog(@"Saving movie \n");
         
         NSInvocationOperation* theOp = [[NSInvocationOperation alloc] initWithTarget:self
                                                                             selector:@selector(saveMovie:) object:[info objectForKey:UIImagePickerControllerMediaURL]];
         [pDlg.saveQ addOperation:theOp];

         pBarItem.enabled = YES;
         pBarItem.tintColor =  [UIColor blueColor];
         //[imagePickerController dismissModalViewControllerAnimated:NO];
         if (bSaveLastPic)
         {
             bSaveLastPic = false;
             bInShowCam = false;
             [imagePickerController dismissModalViewControllerAnimated:NO];
             return;
             
         }
         //[self presentModalViewController:imagePickerController animated:YES];
     }
    return;
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    printf("Clicked button at index %d\n", buttonIndex);
    if (buttonIndex == 0)
    {
        AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSError *err;
    	NSURL *pFlUrl;
        NSURL *albumurl = [NSURL URLWithString:pDlg.pAlName];
    	if (albumurl != nil && [albumurl checkResourceIsReachableAndReturnError:&err])
    	{
            if ([pDlg.pFlMgr removeItemAtURL:albumurl error:&err])
                NSLog(@"Removed album %@\n", albumurl);
            else 
                NSLog(@"Failed to remove album %@\n", albumurl);
        }
        else
        {

        	pFlUrl = [pDlg.cloudDocsURL URLByAppendingPathComponent:@"albums" isDirectory:YES];
        	pFlUrl = [pFlUrl URLByAppendingPathComponent:pDlg.pAlName isDirectory:YES];
            if (pFlUrl != nil && [pFlUrl checkResourceIsReachableAndReturnError:&err])
            {
                if ([pDlg.pFlMgr removeItemAtURL:pFlUrl error:&err])
                    NSLog(@"Removed album %@\n", pFlUrl);
                else 
                    NSLog(@"Failed to remove album %@\n", pFlUrl);
            }

        }
        
        [pDlg.navViewController popViewControllerAnimated:NO];
        [pDlg.navViewController popViewControllerAnimated:NO];
        
       
    
        [pDlg.dataSync deletedItem:pDlg.editItem];
        
       
        [pDlg popView];
        [pDlg popView];
        
        
    }
    
    
    
}

-(void) DeleteConfirm
{
    
    //printf("Launch UIActionSheet");
    UIActionSheet *pSh = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete House" otherButtonTitles:nil];
    [pSh showInView:self.tableView];
    [pSh setDelegate:self];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    return 15;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSLog(@"Text field should change character %s %d\n", [textField.text UTF8String], textField.tag);
    
    switch (textField.tag)
    {
        case HOUSE_PRICE:
        case HOUSE_AREA:
        case HOUSE_BATHS:
        case HOUSE_BEDS:
        case HOUSE_YEAR:
            break;
            
        default:
            return YES;
            break;
    }

    static NSString *numbers = @"0123456789";
    static NSString *numbersPeriod = @"01234567890.";
    
    
    //NSLog(@"%d %d %@", range.location, range.length, string);
    if (range.length > 0 && [string length] == 0) {
        // enable delete
        return YES;
    }
    
    // NSString *symbol = [[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator];
    NSString *symbol = @".";
    if (range.location == 0 && [string isEqualToString:symbol]) {
        // decimalseparator should not be first
        return NO;
    }
    NSCharacterSet *characterSet;
    if (textField.tag == HOUSE_YEAR)
    {
        if (range.location >= 4)
            return NO;
        characterSet = [[NSCharacterSet characterSetWithCharactersInString:numbers] invertedSet];   
    }
    else
    {
        
        NSRange separatorRange = [textField.text rangeOfString:symbol];
        if (separatorRange.location == NSNotFound)
        {
            //  if ([symbol isEqualToString:@"."]) {
            characterSet = [[NSCharacterSet characterSetWithCharactersInString:numbersPeriod] invertedSet];
            //}
            // else {
            //  characterSet = [[NSCharacterSet characterSetWithCharactersInString:numbersComma] invertedSet];              
            //}
        }
        else 
        {
            // allow 2 characters after the decimal separator
            if (range.location > (separatorRange.location + 2)) 
            {
                return NO;
            }
            characterSet = [[NSCharacterSet characterSetWithCharactersInString:numbers] invertedSet];               
        }
    }
    return ([[string stringByTrimmingCharactersInSet:characterSet] length] > 0);
    //  return NO;
}

- (void) populateValues:(UITextField *)textField
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    switch (textField.tag)
    {
        case HOUSE_NAME:
            pDlg.editItem.name = textField.text;
        break;
            
        case HOUSE_PRICE:
        {
            
            NSString *pr = [textField.text stringByTrimmingCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet]];
            pDlg.editItem.price = [NSNumber  numberWithDouble:strtod([pr UTF8String], NULL)];
            
        }
            break;
            
            
        case HOUSE_AREA:
        {
            NSString *pr = [textField.text stringByTrimmingCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet]];
            pDlg.editItem.area = [NSNumber  numberWithDouble:strtod([pr UTF8String], NULL)];
        }
            break;
            
        case HOUSE_YEAR:
        {
            NSString *pr = [textField.text stringByTrimmingCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]];
            pDlg.editItem.year = atoi([pr UTF8String]);
        }
            break;
            
        case HOUSE_BEDS:
        {
            NSString *pr = [textField.text stringByTrimmingCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet]];
            pDlg.editItem.beds = [NSNumber  numberWithDouble:strtod([pr UTF8String], NULL)];
        }
        break;
            
        case HOUSE_BATHS:
        {
            NSString *pr = [textField.text stringByTrimmingCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet]];
            pDlg.editItem.baths = [NSNumber  numberWithDouble:strtod([pr UTF8String], NULL)];
        }
        break;
            
        case HOUSE_STREET:
            pDlg.editItem.street = textField.text;
        break;
            
        case HOUSE_CITY:
            pDlg.editItem.city = textField.text;
        break;
            
        case HOUSE_STATE:
            pDlg.editItem.state = textField.text;
        break;
            
        case HOUSE_COUNTRY:
            pDlg.editItem.country = textField.text;
        break;
            
        case HOUSE_ZIP:
            pDlg.editItem.zip = textField.text;
        break;
            
        default:
            break;
            
    }
}

- (void)textChanged:(id)sender 
{
    UITextField *textField = (UITextField *)sender;
    NSLog(@"Text field changed editing %s %d\n", [textField.text UTF8String], textField.tag);
    [self populateValues:textField];
    
        return;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
    
    [theTextField resignFirstResponder];
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
     [textField resignFirstResponder];
      return YES;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{ 
    if (indexPath.row == 0)
        cell.backgroundColor = [UIColor yellowColor];
    return;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"editdetail";
    static NSArray* fieldNames = nil;
    if (!fieldNames)
    {
        fieldNames = [NSArray arrayWithObjects:@"Name", @"Price", @"Area", @"Beds", @"Camera", @"Notes", @"Pictures", @"Map", @"Street", @"City", @"State", @"Country", @"Postal Code", nil];
    }
    
    static NSArray *secondFieldNames = nil;
    
    if(!secondFieldNames)
    {
        secondFieldNames = [NSArray arrayWithObjects:@"Blank", @"Blank", @"Year", @"Baths", nil];
    }
    
    UITableViewCell *cell;
    NSUInteger row = indexPath.row;
	AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	if(indexPath.section == 0) 
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]; 
        }
        else
        {
            NSArray *pVws = [cell.contentView subviews];
            int cnt = [pVws count];
            for (NSUInteger i=0; i < cnt; ++i)
            {
                [[pVws objectAtIndex:i] removeFromSuperview];
            }
            cell.imageView.image = nil;
            cell.textLabel.text = nil;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        if (row ==2 || row == 3)
        {
            
            UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 75, 25)];
            CGRect textFrame;
            label.textAlignment = UITextAlignmentLeft;
            label.font = [UIFont boldSystemFontOfSize:14];
            [cell.contentView addSubview:label];
            textFrame = CGRectMake(75, 12, 85, 25);
            UITextField *textField = [[UITextField alloc] initWithFrame:textFrame];
            NSString* fieldName = [fieldNames objectAtIndex:row];
            label.text = fieldName;
            textField.delegate = self;
            [textField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
            textField.tag = 0;
            [cell.contentView addSubview:textField];
            UILabel* label1 = [[UILabel alloc] initWithFrame:CGRectMake(160, 10, 75, 25)];
            NSString *secName = [secondFieldNames objectAtIndex:row];
            label1.text = secName;
            label1.textAlignment = UITextAlignmentLeft;
            label1.font = [UIFont boldSystemFontOfSize:14];
            [cell.contentView addSubview:label1];
            textFrame = CGRectMake(235, 12, 85, 25);
            UITextField *textField1 = [[UITextField alloc] initWithFrame:textFrame];
            textField1.delegate = self;
            [textField1 addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
            textField1.tag =1;
            [cell.contentView addSubview:textField1];
            textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            switch (row) 
            {
                case 2:
                {
                    if ([pDlg.editItem.area  doubleValue] >= 0.0 )
                    {
                        char area1[64];
                        sprintf(area1, "%.0f", [pDlg.editItem.area floatValue]);
                        textField.text = [NSString stringWithUTF8String:area1];
                    }
                    textField.tag = HOUSE_AREA;
                    
                    if (pDlg.editItem.year != 3000)
                    {
                        char year1[64];
                        sprintf(year1, "%d", pDlg.editItem.year);
                        textField1.text = [NSString stringWithUTF8String:year1];
                    }
                    textField1.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
                    textField1.tag = HOUSE_YEAR;
                    
                }
                    break;
                    
                case 3:
                {
                    if ([pDlg.editItem.beds  doubleValue] >= 0.0 )
                    {
                        char beds1[64];
                        sprintf(beds1, "%.0f", [pDlg.editItem.beds floatValue]);
                        textField.text = [NSString stringWithUTF8String:beds1];
                    }
                    textField.tag = HOUSE_BEDS;
                    
                    if ([pDlg.editItem.baths  doubleValue] >= 0.0 )
                    {
                        char baths1[64];
                        sprintf(baths1, "%.1f", [pDlg.editItem.baths floatValue]);
                        textField1.text = [NSString stringWithUTF8String:baths1];
                    }
                    textField1.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
                    textField1.tag = HOUSE_BATHS;
                }
                    break;
                    
                default:
                    break;
            }
            
        }
        else if (row < 2 || (row > 7 && row < 13))
        {
            CGRect textFrame;
			
            // put a label and text field in the cell
            UILabel *label;
            if (row != 12)
                label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 75, 25)];
            else
                label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 105, 25)];
            label.textAlignment = NSTextAlignmentLeft;
            label.font = [UIFont boldSystemFontOfSize:14];
            if (row == 0)
            {
                cell.backgroundColor = [UIColor yellowColor];
                label.backgroundColor = [UIColor yellowColor];
            }
            [cell.contentView addSubview:label];
            if (row != 12)
                textFrame = CGRectMake(75, 12, 200, 25);
            else
                textFrame = CGRectMake(110, 12, 170, 25);
            UITextField *textField = [[UITextField alloc] initWithFrame:textFrame];
            switch (row) 
            {
                case 0:
                    textField.text = pDlg.editItem.name;
                    textField.tag = HOUSE_NAME;
                break;
                    
                case 1:
                {
                    if ([pDlg.editItem.price  doubleValue] >= 0.0 )
                    {
                        char price1[64];
                        sprintf(price1, "%.2f", [pDlg.editItem.price floatValue]);
                        textField.text = [NSString stringWithUTF8String:price1];
                    }
                    textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
                    textField.tag = HOUSE_PRICE;
                }
                    break;
                    
                case 8:
                    textField.text = pDlg.editItem.street;
                    textField.tag = HOUSE_STREET;
                    break;
                    
                case 9:
                {
                    textField.text = pDlg.editItem.city;
                    textField.tag = HOUSE_CITY;
                }
                    break;
                    
                case 10:
                    textField.text = pDlg.editItem.state;
                    textField.tag = HOUSE_STATE;
                    break;
                case 11:
                    textField.text = pDlg.editItem.country;
                    textField.tag = HOUSE_COUNTRY;
                    break;
                case 12:
                    textField.text = pDlg.editItem.zip;
                    textField.tag = HOUSE_ZIP;
                    break;
                    
                default:
                    break;
            }
            textField.delegate = self;
            [textField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
            [cell.contentView addSubview:textField];
            
            NSString* fieldName = [fieldNames objectAtIndex:row];
            label.text = fieldName;
        }
        else if (row == 4)
        {
            
            cell.imageView.image = [UIImage imageNamed:@"camera.png"];
            cell.textLabel.text = @"Camera";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        }
        else if (row == 5)
        {
            cell.imageView.image = [UIImage imageNamed:@"note.png"];
            cell.textLabel.text = @"Notes";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; 
        }
        else if (row == 6)
        {
            
            printf("Selected album name %s\n", [pDlg.editItem.album_name UTF8String]);
            NSError *err;
	    if (!nSmallest)
	    {
		NSURL *albumurl = [NSURL URLWithString:pDlg.pAlName];
		if (albumurl != nil && [albumurl checkResourceIsReachableAndReturnError:&err])
			[self findSmallest:albumurl];
		else
		{
		    albumurl = [pDlg.cloudDocsURL URLByAppendingPathComponent:@"albums" isDirectory:YES];
		     albumurl = [albumurl URLByAppendingPathComponent:pDlg.pAlName isDirectory:YES];
	        	[self findSmallest:albumurl];

		}

	    }

            if (nSmallest)
            {
                NSString *pFlName = [[NSNumber numberWithInt:nSmallest] stringValue];
                pFlName = [pFlName stringByAppendingString:@".jpg"];
		NSURL *pFlUrl;
		NSError *err;
		NSURL *albumurl = [NSURL URLWithString:pDlg.pAlName];
		if (albumurl != nil && [albumurl checkResourceIsReachableAndReturnError:&err])
		{
		    pFlUrl = [albumurl URLByAppendingPathComponent:@"thumbnails" isDirectory:YES];
		    pFlUrl = [pFlUrl URLByAppendingPathComponent:pFlName isDirectory:NO];
		}
		else 
		{
		   
		    pFlUrl = [pDlg.cloudDocsURL URLByAppendingPathComponent:@"albums" isDirectory:YES];
		     pFlUrl = [pFlUrl URLByAppendingPathComponent:pDlg.pAlName isDirectory:YES];
		    pFlUrl = [pFlUrl URLByAppendingPathComponent:@"thumbnails" isDirectory:YES];
		    pFlUrl = [pFlUrl URLByAppendingPathComponent:pFlName isDirectory:NO];
		}
	       
		NSDictionary *dict = [pDlg.pFlMgr attributesOfItemAtPath:[pFlUrl path] error:&err];
		if (dict != nil)
		    NSLog (@"Loading image in DisplayViewController %@ file size %lld\n", pFlUrl, [dict fileSize]);
		else 
		    NSLog (@"Loading image in DisplayViewController %@ file size not obtained\n", pFlUrl);
		UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:pFlUrl]];
                NSLog(@"Set icon image %@ in DisplayViewController\n", pFlUrl);
                cell.imageView.image = image;

            }
            cell.textLabel.text = @"Pictures";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; 
        }
        else if (row == 7)
        {
            
            cell.imageView.image = [UIImage imageNamed:@"map.png"];
            cell.textLabel.text = @"Map";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        }
        if (row == 14)
        {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 325, 44)];
            [button setBackgroundImage:[[UIImage imageNamed:@"delete_button.png"]
                                        stretchableImageWithLeftCapWidth:8.0f
                                        topCapHeight:0.0f]
                              forState:UIControlStateNormal];
            
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont boldSystemFontOfSize:20];
            button.titleLabel.shadowColor = [UIColor lightGrayColor];
            button.titleLabel.shadowOffset = CGSizeMake(0, -1);
            
            //button.titleLabel.text = @"Delete Item";
            // button.titleLabel.font = [UIFont systemFontOfSize: 35];
            // printf("Current title = %s", [button.currentTitle  UTF8String]);
            // button.currentTitle = @"Delete Item";
            // UIColor *pClr = [UIColor clearColor];
            //   button.backgroundColor = pClr;
            //UIColor *pTitClr = [UIColor whiteColor];
            [button setTitle:@"Delete House" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(DeleteConfirm) forControlEvents:UIControlEventTouchDown];
            [cell.contentView addSubview:button];
        }

        
        
    }
    else
    {
        
        return nil;
    }
    
    return cell;   
}




- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *title ;
    if (pDlg.editItem.street != nil)
        title = pDlg.editItem.street;
    else 
        title = @" ";
    if (indexPath.row == 6)
    {
        AlbumContentsViewController *albumContentsViewController = [[AlbumContentsViewController alloc] initWithNibName:@"AlbumContentsViewController" bundle:nil];
        NSLog(@"Pushing AlbumContents view controller %s %d\n" , __FILE__, __LINE__);
        //  albumContentsViewController.assetsGroup = group_;
        [albumContentsViewController setDelphoto:true];
        [self.navigationController pushViewController:albumContentsViewController animated:NO];
        [albumContentsViewController  setTitle:title];
        albumContentsViewController.pAddEditCntrl = self;
    }
    else if (indexPath.row == 7)
    {
        MKCoordinateSpan span;
        CLLocationCoordinate2D loc;
        loc.longitude = pDlg.editItem.longitude;
        loc.latitude = pDlg.editItem.latitude;
        span.latitudeDelta = 0.001;
        span.longitudeDelta = 0.001;
        if (fabs(loc.latitude) > 50.0)
            span.longitudeDelta = 0.002;
        MKCoordinateRegion reg = MKCoordinateRegionMake(loc, span);
        MapViewController *mapViewController = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
        NSLog(@"Setting region to %f %f %f %f\n", reg.center.latitude, reg.center.longitude, reg.span.longitudeDelta, reg.span.latitudeDelta);
        mapViewController.reg = reg;
        mapViewController.title = title;
        [self.navigationController pushViewController:mapViewController animated:NO];
    }
    else if (indexPath.row == 5)
    {
        NotesViewController *notesViewController = [[NotesViewController alloc] initWithNibName:@"NotesViewController" bundle:nil];
        NSLog(@"Pushing Notes view controller %s %d\n" , __FILE__, __LINE__);
        //  albumContentsViewController.assetsGroup = group_;
        notesViewController.title = title;
        [self.navigationController pushViewController:notesViewController animated:NO];   
    } 
    else if (indexPath.row == 4)
    {
            NSLog(@"Show camera selection\n");
            [self AddPicture ];
    }



   
}

@end
