//
//  AppDelegate.h
//  Shopper
//
//  Created by Ninan Thomas on 12/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"
#import <Foundation/Foundation.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MapKit/MapKit.h>
#import "common/MySlider.h"
#import "AddViewController.h"
#import "DataOps.h"
#import "LocalItem.h"
#import <CoreLocation/CLLocationManager.h>
#import "common/KeychainItemWrapper.h"
#import "InAppPurchase.h"
#import "OpenHousesShareMgr.h"


#define   PHOTOREQSOURCE_FB 1
#define  PHOTOREQSOURCE_EMAIL 0
#define PHOTOREQSOURCE_SHARE 2
#define AWS_OPENHOUSES_APPID 2

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MKMapViewDelegate, UIAlertViewDelegate, CLLocationManagerDelegate>
{
    NSMetadataQuery *query;
    MKMapView    *mapView;
    CLLocationManager *locmgr;
    AddViewController *aVw;
    NSUbiquitousKeyValueStore *kvstore;
    bool bKvInit;
    bool bFirstActive;
    bool bPersistError;
    bool bUpgradeAlert;
    bool bUpgradeAction;
    bool bSystemAbrt;
    bool bShrMgrStarted;
}

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) OpenHousesShareMgr *pShrMgr;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
@property (nonatomic, retain) IBOutlet UINavigationController *navViewController;
@property (nonatomic, retain)  UITabBarController  *tabBarController;
@property (nonatomic, retain) LocalItem* selectedItem;
@property (nonatomic, retain) LocalItem* editItem;
@property (nonatomic, retain) NSString *pSearchStr;
@property (nonatomic, retain) NSString *pAlName;
@property (nonatomic, retain) NSURL *cloudURL;
@property (nonatomic, retain) NSURL *cloudDocsURL;
@property (strong, nonatomic) NSOperationQueue *saveQ;
@property (nonatomic, retain) CLLocation *loc;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *passWord;
@property (nonatomic, strong) NSString *friendList;
@property (nonatomic, retain) DataOps *dataSync;
@property (nonatomic, retain) KeychainItemWrapper *kchain;
@property (nonatomic, retain) InAppPurchase *inapp;
@property bool unlocked;
@property int attchmnts;
@property int editIndx;
@property int selectIndx;
@property int sortIndx;
@property bool bDateAsc;
@property bool bPriceAsc;
@property bool bAreaAsc;
@property bool bYearAsc;
@property bool bBedsAsc;
@property bool bBathsAsc;
@property bool biCloudAvail;
@property bool bEmailConfirm;
@property bool bPtoPShare;
@property int toggle;
@property bool bInitRefresh;
@property dispatch_queue_t fetchQueue;
@property long long COUNT;
@property long long totcount;
@property int toDownLoad;
@property CGFloat photo_scale;
@property double sysver;
@property bool bNoICloudAlrt;
@property bool bFBAction;
@property bool bRegistered;
@property bool bPassword;
@property bool bShare;
@property BOOL bTokPut;
@property double oneMonth;
@property bool bSharingDisabled;
@property bool bShareAction;
@property bool bChkdFrndLst;
@property bool bInBackGround;
@property bool bFromShareAction;
@property bool beingLoggedIn;
@property bool purchased;

@property (nonatomic, retain) NSFileManager *pFlMgr;

- (void)itemAdd;
- (void)itemAddDone;
-(void) iCloudOrEmail;
- (void) itemAddCancel;
-(void) itemEdit;
-(void) setPurchsd;
-(void) itemEditDone;
-(void) itemEditCancel;
-(void) popView;
-(void) emailRightNow;
-(void) fbshareRightNow;
-(void) shareSelFrnds;
-(void) shareRightNow;
- (void) launchWithSearchStr;
- (void)initializeiCloudAccess;
-(void) reloadFetchedResults:(NSNotification*)note;
-(void) reloadMainScreen:(NSNotification*)note;
-(void) stopLocUpdate;
-(void) addToCount;
-(void) addToTotCount;
-(void) addToTotCountNoR;
-(void) storeInKeyChain;
-(void) storeFriends;
-(NSString *) getPassword;
-(void) showShareView;
-(void) addToDownLoadItems:(NSArray *)dwldItems;
-(NSArray *)itemsToDownLoad;
-(void) removeFromDownLoadItems:(NSString *)item;
-(void) removeAllDownLoadItems;
-(void) friendsAddDelDone;
-(void) switchRootView;

@end
