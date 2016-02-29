//
//  MainListViewController.h
//  Shopper
//
//  Created by Ninan Thomas on 12/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "common/AlbumContentsViewController.h"
#import "LocalItem.h"

@interface MainListViewController : UITableViewController<AlbumContentsViewControllerDelegate>
{
    NSThread *updateThread;
    int photoreqsource;
    
}



- (NSString *) getMessage:(int) source;
-(LocalItem *) getSelectedItem;
- (void) getPhotos:(int)startIndx  source:(int)source;
- (void) shareSelectedtoOH;
-(void)resetSelectedItems;
-(void)photoSelDone;
-(void)photoSelCancel;
-(void) attchmentsInit;
-(void) attchmentsClear;
-(void) lockItems;
-(void) unlockItems;
-(void) cleanUp:(int) indx;
-(bool) itemsSelected;
@property bool bAttchmentsInit;
@property bool bInICloudSync;
@property bool bInEmail;
@property int currPhotoSelIndx;
@property int actionNow;


@property (nonatomic, retain) NSMutableArray *seletedItems;
@property (nonatomic, retain) NSMutableArray *indexes;
@property (nonatomic, retain) NSMutableArray *itemNames;

@property (nonatomic, retain) NSMutableArray *attchments;
@property (nonatomic, retain) NSMutableArray *movOrImg;
@property (nonatomic, retain) AlbumContentsViewController *albumContentsViewController;
@property bool bUpdated;
@property bool bUpdating;
@property bool redrawTable;

@end
