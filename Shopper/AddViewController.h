//
//  AddViewController.h
//  Shopper
//
//  Created by Ninan Thomas on 12/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AssetsLibrary/AssetsLibrary.h>
#import "Foundation/NSOperation.h"
#import <MapKit/MapKit.h>
#import "common/MySlider.h"
#include <sys/time.h>
#import "LocalItem.h"
#import "common/AlbumContentsViewController.h"

@interface AddViewController : UITableViewController <UIImagePickerControllerDelegate, UITextFieldDelegate, UITableViewDelegate, MKMapViewDelegate, AlbumContentsViewControllerDelegate>
{
 //   ALAssetsLibrary *assetsLibrary;
    
  //   MKReverseGeocoder *reverseGeocoder;
    CLGeocoder *geocoder;
    bool bInPicCapture;
    bool bSaveLastPic;
     NSDate *locationManagerStartDate;
    MKMapView *mapView;
    bool bInShowCam;
    struct timeval last_mode_change;
    bool ingeorevcoding;
    NSMutableArray *locArry;
}


-(void) AddPicture;
- (void)textChanged:(id)sender;
-(void) updatePlaceMark:(CLPlacemark *)placemark;
-(void) revGeoCodeNextPoint;
- (void)sliderUpdate:(id)sender;
- (void) setLocation:(CLLocation *)loc;
-(void) saveImage:(UIImage *)image;
-(void) saveMovie:(NSURL *)movie;

@property int nLargest;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;
@property (strong, nonatomic) UIBarButtonItem *pBarItem;
@property (strong, nonatomic) UIBarButtonItem *pBarItem3;
@property (nonatomic, retain) MySlider *pSlider;
@property (nonatomic, retain) LocalItem *pNewItem;
//@property (nonatomic, retain) MKMapView *mapView;

@property bool bSliderPic;
@property int locCnt;
@end
