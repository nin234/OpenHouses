//
//  DataOps.h
//  Shopper
//
//  Created by Ninan Thomas on 11/17/12.
//
//

#import <Foundation/Foundation.h>
#import "LocalItem.h"

@interface DataOps: NSThread<UIAlertViewDelegate> 
{
    NSMutableArray *newItems;
    NSCondition *workToDo;
    int itemsToAdd;
    int itemsEdited;
    int itemsDeleted;
    int itemsToShare;
    int itemsToDownloadOnStartUp;
    int itemsToDownload;
    NSMutableArray *editedItems;
    NSMutableArray *deletedItems;
     NSMutableArray *seletedItems;
    NSMutableArray *sharedItems;
    NSMutableArray *downloadIds;
     NSArray *indexes;
     NSMutableArray *itemNames;
    
    NSMutableArray *seletedItemsTmp;
    NSMutableArray *indexesTmp;
     NSArray *itemNamesTmp;
    bool bInitRefresh;
    bool forceRefresh;
    NSDate *refreshTime;
    dispatch_queue_t shareQ;
    bool bInUpload;
    bool bInDownload;
    bool bInStartUpDownload;
    bool bRedColor;
    int waitTime;
    bool bAnimateNow;
    bool bAnimateOnDwld;
    bool bAnimateOnStrtUp;
    bool bShowSelfHelp;
    UIBackgroundTaskIdentifier upldBkTaskId;
    UIBackgroundTaskIdentifier dwldBkTaskId;
    UIBackgroundTaskIdentifier dwldStrtUpTaskId;
    UIBackgroundTaskIdentifier loginTaskId;
}

-(void) main;

-(void) cleanUp: (int) indx;

@property(nonatomic) dispatch_queue_t shareQ;
@property (nonatomic) bool dontRefresh;
@property (nonatomic) bool refreshNow;
@property (nonatomic) bool updateNow;
@property (nonatomic) bool loginNow;
@property (nonatomic) bool updateNowSetDontRefresh;

-(void) lock;
-(void) unlock;
 

-(void) addItem:(LocalItem*)item;
-(void) editedItem:(LocalItem*)item;
-(void) deletedItem: (LocalItem*)item;
-(void) shareItem:(LocalItem*) item pictures:(NSArray *)pics friends:(NSArray *)frnds;
-(void) downloadItem:(NSString *)item;
-(void) downloadItemsOnStartUp;

@end
