//
//  EditViewController.h
//  Shopper
//
//  Created by Ninan Thomas on 12/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "common/MySlider.h"
#import "common/AlbumContentsViewController.h"

@interface EditViewController : UITableViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, AlbumContentsViewControllerDelegate>
{
    bool bInPicCapture;
    NSMetadataQuery *query;
    bool bSaveLastPic;
    bool bInShowCam;
    struct timeval last_mode_change;
    bool processQuery;
}
 

@property (strong, nonatomic) UIImagePickerController *imagePickerController;
@property (strong, nonatomic) UIBarButtonItem *pBarItem;
@property (strong, nonatomic) UIBarButtonItem *pBarItem3;
@property (nonatomic, retain) MySlider *pSlider;
@property int nSmallest;
@property bool bSliderPic;
- (void)sliderUpdate:(id)sender;


-(void) DeleteConfirm;
-(void) AddPicture;
-(void) queryStop;
-(void) saveImage:(UIImage *)image;
-(void) saveMovie:(NSURL *)movie;

@property (nonatomic, retain) NSMutableArray *tnailurls;
@property (nonatomic, retain) NSMutableArray *movurls;

@end
