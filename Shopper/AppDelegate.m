//
//  AppDelegate.m
//  Shopper
//
//  Created by Ninan Thomas on 12/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "AddViewController.h"
#import "EditViewController.h"
#import "DisplayViewController.h"
#import "Item.h"
#import <MapKit/MapKit.h>
#import <Social/SLComposeViewController.h>
#import <Social/SLServiceTypes.h>
#import <sharing/FriendDetails.h>
#import "SelectFriendViewController.h"
#import <sharing/AddFriendViewController.h>





@implementation AppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize navViewController = _navViewController;
@synthesize selectedItem;
@synthesize editItem;
@synthesize editIndx;
@synthesize selectIndx;
@synthesize sortIndx;
@synthesize pSearchStr;
@synthesize pAlName;
@synthesize pFlMgr;
@synthesize saveQ;
@synthesize bDateAsc;
@synthesize bPriceAsc;
@synthesize bAreaAsc;
@synthesize bBedsAsc;
@synthesize bYearAsc;
@synthesize bBathsAsc;
@synthesize biCloudAvail;
@synthesize cloudURL;
@synthesize cloudDocsURL;
@synthesize toggle;
@synthesize loc;
@synthesize attchmnts;
@synthesize bEmailConfirm;
@synthesize bPtoPShare;
@synthesize userName;
@synthesize passWord;
@synthesize dataSync;
@synthesize bInitRefresh;
@synthesize fetchQueue;
@synthesize COUNT;
@synthesize totcount;
@synthesize toDownLoad;
@synthesize photo_scale;
@synthesize sysver;
@synthesize bNoICloudAlrt;
@synthesize bFBAction;
@synthesize unlocked;
@synthesize bRegistered;
@synthesize bPassword;
@synthesize kchain;
@synthesize friendList;
@synthesize bShare;
@synthesize bTokPut;
@synthesize oneMonth;
@synthesize  bSharingDisabled;
@synthesize bShareAction;
@synthesize bChkdFrndLst;
@synthesize bInBackGround;
@synthesize bFromShareAction;
@synthesize beingLoggedIn;
@synthesize inapp;
@synthesize purchased;
@synthesize tabBarController;
@synthesize pShrMgr;

-(void) populateOneMonth
{
    oneMonth = 30*24*60*60*1000000;
    return;
}

-(void) switchRootView
{
    [self.window setRootViewController:self.navViewController];
    tabBarController.selectedIndex = 0;
}


-(void) popView
{
    //putchar('N');
    [self.navViewController popViewControllerAnimated:YES];
    
    
}

-(void) itemEdit
{
    //putchar('I');
    
    
    EditViewController *aViewController = [[EditViewController alloc]
                                           initWithNibName:nil bundle:nil];
    [self.navViewController pushViewController:aViewController animated:YES];
}

-(void) itemEditCancel
{
    NSLog(@"Clicked Edit cancel button\n");
    [self.navViewController popViewControllerAnimated:NO];
       return;
}

-(void) itemEditDone
{
    NSLog(@"Clicked Edit done button\n");
    LocalItem *modItem = self.editItem;
    EditViewController *pEdit = (EditViewController *)[self.navViewController topViewController];
    [pEdit queryStop];
    [self.navViewController popViewControllerAnimated:NO];
       self.selectedItem = modItem;
    struct timeval tv;
    gettimeofday(&tv, 0);
    long long sec = ((long long)tv.tv_sec)*1000000;
    long long usec =tv.tv_usec;
	self.editItem.val1 =  sec + usec ;

    [dataSync editedItem:self.editItem];
    DisplayViewController *pDisp = (DisplayViewController *)[self.navViewController topViewController];
    [pDisp.tableView reloadData];
    
}

-(void) stopLocUpdate
{
  mapView.showsUserLocation = NO;
  [locmgr stopUpdatingLocation];
}

-(void) itemAddCancel
{
    bEmailConfirm =false;
    UIAlertView *pAvw = [[UIAlertView alloc] initWithTitle:@"Discard Changes" message:@"" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    [pAvw show];   
}

-(void) itemAddCancelConfirm
{
    mapView.showsUserLocation = NO;
    [locmgr stopUpdatingLocation];
    aVw = nil;
  if ([pFlMgr removeItemAtPath:pAlName error:nil] == YES)
  {
      printf("Removed album %s \n", [pAlName UTF8String]);
  }
  else
  {
      printf("Failed to remove album %s \n", [pAlName UTF8String]);
  }
    self.pAlName = @"";
    [self.navViewController popViewControllerAnimated:YES];
}


- (void) itemAddDone
{
    mapView.showsUserLocation = NO;
    [locmgr stopUpdatingLocation];
    aVw = nil;
          
    AddViewController *pAddView = (AddViewController *)[self.navViewController popViewControllerAnimated:NO];
    struct timeval tv;
    gettimeofday(&tv, 0);
    long long sec = ((long long)tv.tv_sec)*1000000;
    long long usec =tv.tv_usec;

	pAddView.pNewItem.val1 = sec + usec;

    [dataSync addItem:pAddView.pNewItem];
    NSLog(@"New Item added %@\n", pAddView.pNewItem);
      selectedItem = pAddView.pNewItem;
    editItem = pAddView.pNewItem;
    
}

- (void)itemAdd
{    
  //  UIBarButtonItem *pBarItem1 = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(itemAddCancel) ];
    NSLog(@"Adding item purchase = %d COUNT = %lld", purchased, COUNT);
    
    if (!purchased)
    {
        if (COUNT >= 2)
        {
            NSLog(@"Cannot add a new item without upgrade COUNT=%lld", COUNT);
                bUpgradeAlert = true;
            UIAlertView *pAvw = [[UIAlertView alloc] initWithTitle:@"Upgrade now" message:@"Only two houses allowed with free version. Please upgrade now to add unlimited number of houses" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [pAvw show];
            return;

        }
    }
    NSLog(@"Authorization status %d", [CLLocationManager authorizationStatus]);
    UIDevice *dev = [UIDevice currentDevice];
    if (!([[dev systemVersion] doubleValue] < 8.0))
    {
    switch ([CLLocationManager authorizationStatus])
    {
        case kCLAuthorizationStatusNotDetermined:
            [locmgr requestWhenInUseAuthorization];
        break;
            
        default:
            break;
    }
    }
    MainViewController *pMainVwCntrl = [self.navViewController.viewControllers objectAtIndex:0];
    [locmgr startUpdatingLocation];
    pSearchStr = nil;
    pMainVwCntrl.pSearchBar.text = nil;
    [pMainVwCntrl.pSearchBar resignFirstResponder];
    AddViewController *aViewController = [[AddViewController alloc]
                                          initWithNibName:nil bundle:nil];
    aVw = aViewController;
    mapView.showsUserLocation = YES;
    [self.navViewController pushViewController:aViewController animated:YES];
  
}

- (void) launchWithSearchStr
{
      
    CGRect tableRect = CGRectMake(0, 50, 320, 1000);
    UITableView *pTVw = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStylePlain];
    //[self.view insertSubview:self.pAllItms.tableView atIndex:1];
        MainViewController *pMainVwCntrl = [self.navViewController.viewControllers objectAtIndex:0];
    pMainVwCntrl.pAllItms.tableView = pTVw;
 
    
}

-(void) iCloudEmailCancel
{
    
    MainViewController *pMainVwCntrl = [self.navViewController.viewControllers objectAtIndex:0];
    pMainVwCntrl.pAllItms.bInEmail = false;
    pMainVwCntrl.pAllItms.bInICloudSync = false;
    [pMainVwCntrl.pAllItms unlockItems];
    [pMainVwCntrl.pAllItms attchmentsClear];
    self.dataSync.dontRefresh = false;
    UIBarButtonItem *pBarItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(iCloudOrEmail)];
    pMainVwCntrl.pAllItms.tableView.tableFooterView = nil;
    
    self.navViewController.navigationBar.topItem.leftBarButtonItem = pBarItem1;

    self.dataSync.updateNow = true;
    [pMainVwCntrl.pAllItms resetSelectedItems];
    self.navViewController.toolbarHidden = YES;
    return;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"Clicked button at index %ld", (long)buttonIndex);
    if(bSystemAbrt)
    {
        bSystemAbrt = true;
        return;
    }
    if (bUpgradeAlert)
    {
        NSLog(@"Resetting bUpgradeAlert in alertview action");
        bUpgradeAlert = false;
        return;
    }
    
    if (bPersistError)
    {
        bPersistError = false;
      //  abort();
        return;
    }
    MainViewController *pMainVwCntrl = [self.navViewController.viewControllers objectAtIndex:0];
    attchmnts = (int)buttonIndex;
    
    if(bNoICloudAlrt)
    {
         [self iCloudEmailCancel];
        bNoICloudAlrt = false;
        return;
    }
    
    switch (attchmnts)
    {
        case 0:
            NSLog(@"Attaching no photos\n");
            if (bFBAction)
            {
                bFBAction = false;
                [self fbshareRightNow];
                return;
            }
            if (bShare)
            {
                bShare = false;
                [self shareSelFrnds];
            }
            if (bEmailConfirm)
            {
                bEmailConfirm = false;
                [self emailRightNow];
            }
            if (bShareAction)
            {
                bShareAction = false;
                bFromShareAction = true;
                [self.dataSync setLoginNow:true];
               
            }

            
            break;
            
        case 1:
        {
            NSLog(@"Attaching all the photos\n");
            if (bFBAction)
            {
                bFBAction = false;
                [pMainVwCntrl.pAllItms getPhotos:0 source:PHOTOREQSOURCE_FB];
                return;
            }
            
            if (bShare)
            {
                bShare = false;
                [pMainVwCntrl.pAllItms getPhotos:0 source:PHOTOREQSOURCE_SHARE];
                return;
            }
            
                        
            if(bEmailConfirm)
            {
                bEmailConfirm =false;
                [pMainVwCntrl.pAllItms getPhotos:0 source:PHOTOREQSOURCE_EMAIL];
            }
            else
            {
                [self itemAddCancelConfirm];
            }
        }
            break;
            
        default:
            break;
    }
    
    NSLog(@"Email selected items\n");
      return;
}

-(void) emailRightNow
{
    
    MainViewController *pMainVwCntrl = [self.navViewController.viewControllers objectAtIndex:0];  
     MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
     controller.mailComposeDelegate = self;
     [controller setSubject:@"House details"];
    [controller setMessageBody:[pMainVwCntrl.pAllItms getMessage:PHOTOREQSOURCE_EMAIL] isHTML:NO];
     
    NSUInteger cnt = [pMainVwCntrl.pAllItms.attchments count];
    NSLog (@"Attaching %lu images\n",(unsigned long)cnt);
    for (NSUInteger i=0; i < cnt; ++i) 
    {
        if ([[pMainVwCntrl.pAllItms.movOrImg objectAtIndex:i] boolValue])
        {
            [controller addAttachmentData:[NSData dataWithContentsOfURL:[pMainVwCntrl.pAllItms.attchments objectAtIndex:i]] mimeType:@"image/jpeg" fileName:@"photo"];
        }
        else 
        {
            [controller addAttachmentData:[NSData dataWithContentsOfURL:[pMainVwCntrl.pAllItms.attchments objectAtIndex:i]] mimeType:  @"video/quicktime" fileName:@"video"];    
        }
    }
    if (controller) 
        [pMainVwCntrl presentViewController:controller animated:YES completion:nil];
    [self iCloudEmailCancel];
    return;
}

-(void) fbshareNow
{
    MainViewController *pMainVwCntrl = [self.navViewController.viewControllers objectAtIndex:0];
    if(![pMainVwCntrl.pAllItms itemsSelected])
    {
        [self iCloudEmailCancel];
        return;
    }
    bFBAction = true;
    UIAlertView *pAvw = [[UIAlertView alloc] initWithTitle:@"Post Pictures" message:@"Only images can be posted. Movies cannot be posted" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    [pAvw show];

    return;
}

-(void) shareRightNow
{
     SelectFriendViewController *SelFrndView = (SelectFriendViewController *)[self.navViewController popViewControllerAnimated:NO];
    NSArray *selFrnds = [SelFrndView getSelectedFriends];
    if (![selFrnds count])
    {
        NSLog(@"No friend selected to share with");
         [self iCloudEmailCancel];
         return;
    }
    else
    {
        NSLog(@"%lu friends selected to share with", (unsigned long)[selFrnds count]);
    }
    MainViewController *pMainVwCntrl = [self.navViewController.viewControllers objectAtIndex:0];
    if(![pMainVwCntrl.pAllItms itemsSelected])
    {
        [self iCloudEmailCancel];
        return;
    }
    LocalItem *item = [pMainVwCntrl.pAllItms getSelectedItem];
    if (item == nil)
    {
        [self iCloudEmailCancel];
        return;
    }
   
    [self.dataSync shareItem:item pictures:pMainVwCntrl.pAllItms.attchments friends:selFrnds];
    [self iCloudEmailCancel];
       
     return;
}

-(void) shareSelFrnds
{
    kchain = [[KeychainItemWrapper alloc] initWithIdentifier:@"LoginData" accessGroup:@"3JEQ693MKL.com.rekhaninan.sinacama"];
    friendList = [kchain objectForKey:(__bridge id)kSecAttrComment];
    NSLog(@"Friendlist %@", friendList);
    
    NSMutableDictionary *frndDic = [[NSMutableDictionary alloc] init];
    
    if (friendList != nil && [friendList length] > 0)
    {
        NSArray *friends = [friendList componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@";"]];
        NSUInteger cnt = [friends count];
        if(cnt >1)
        {
            for (NSUInteger i=0; i < cnt-1; ++i)
            {
                NSString *frndStr = [friends objectAtIndex:i];
                if (frndStr != nil && [frndStr length] > 0)
                {
                    FriendDetails *frnd = [[FriendDetails alloc] initWithString:frndStr];
                    [frndDic setObject:frnd forKey:frnd.name];
                }
        
            }
        }
    }
    SelectFriendViewController *selctFrnd = [SelectFriendViewController alloc];
    selctFrnd.frndDic = frndDic;
    selctFrnd = [selctFrnd initWithNibName:nil bundle:nil];
    [self.navViewController pushViewController:selctFrnd animated:NO];
    return;
}

-(void) friendsAddDelDone
{
    
        return;
}



-(void) fbshareRightNow
{
     MainViewController *pMainVwCntrl = [self.navViewController.viewControllers objectAtIndex:0]; 
    SLComposeViewController *fbVwCntrl = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    if (fbVwCntrl != nil)
    {
        [fbVwCntrl setInitialText:[pMainVwCntrl.pAllItms getMessage:PHOTOREQSOURCE_FB]];
        NSUInteger cnt = [pMainVwCntrl.pAllItms.attchments count];
        NSLog (@"Attaching %lu images\n",(unsigned long)cnt);
        for (NSUInteger i=0; i < cnt; ++i)
        {
            [fbVwCntrl addImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[pMainVwCntrl.pAllItms.attchments objectAtIndex:i]]]];
        }
        [fbVwCntrl setCompletionHandler:^(SLComposeViewControllerResult result)
         {
            if (result == SLComposeViewControllerResultCancelled)
                NSLog(@"User cancelled fb post\n");
             else
                 NSLog(@"Posted to fb\n");
             [self iCloudEmailCancel];
         }
         ];
        [pMainVwCntrl presentViewController:fbVwCntrl animated:YES completion:nil];
    }
    return;
}

-(void) emailNow
{
    if ([MFMailComposeViewController canSendMail])
    {
        MainViewController *pMainVwCntrl = [self.navViewController.viewControllers objectAtIndex:0];
        if(![pMainVwCntrl.pAllItms itemsSelected])
        {
            [self iCloudEmailCancel];
            return;
        }
        bEmailConfirm = true;
        
        UIAlertView *pAvw = [[UIAlertView alloc] initWithTitle:@"Attach Pictures" message:@"" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        [pAvw show];
        
    }
   
    return;
}

-(void) syncNow
{
    NSLog(@"Syncing to iCloud selected items\n");
    MainViewController *pMainVwCntrl = [self.navViewController.viewControllers objectAtIndex:0];
    [pMainVwCntrl.pAllItms syncSelectedtoiCloud];
    [self iCloudEmailCancel];
    return;
}

-(void) shareNow
{
    NSLog(@"Sharing to openhouses\n");
    
    MainViewController *pMainVwCntrl = [self.navViewController.viewControllers objectAtIndex:0];
    if(![pMainVwCntrl.pAllItms itemsSelected])
    {
        [self iCloudEmailCancel];
        return;
    }
    bShare = true;
    UIAlertView *pAvw = [[UIAlertView alloc] initWithTitle:@"Share Pictures" message:@"" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    [pAvw show];

    return;
}

- (void)mailComposeController:(MFMailComposeViewController*)controller  
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error;
{
    MainViewController *pMainVwCntrl = [self.navViewController.viewControllers objectAtIndex:0];
    if (result == MFMailComposeResultSent) {
        NSLog(@"It's away!");
    }
    [pMainVwCntrl dismissViewControllerAnimated:YES completion:nil];
}

-(void) showShareView
{
    MainViewController *pMainVwCntrl = [self.navViewController.viewControllers objectAtIndex:0];
    UIBarButtonItem *pBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(iCloudEmailCancel) ];
    self.navViewController.navigationBar.topItem.leftBarButtonItem = pBarItem;
    self.navViewController.toolbarHidden = NO;
    
    UIBarButtonItem *flexibleSpaceButtonItem = [[UIBarButtonItem alloc]
                                                initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                target:nil action:nil];
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 45)];
	footer.backgroundColor = [UIColor clearColor];
	pMainVwCntrl.pAllItms.tableView.tableFooterView = footer;
    UIBarButtonItem *pBarItem1;
    pMainVwCntrl.pAllItms.bInEmail = true;
    self.dataSync.loginNow = true;
    pBarItem1 = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStylePlain target:self action:@selector(shareNow)];
    
    [pMainVwCntrl setToolbarItems:[NSArray arrayWithObjects:
                                   flexibleSpaceButtonItem,
                                   pBarItem1,
                                   flexibleSpaceButtonItem,
                                   nil]
                         animated:YES];
    self.dataSync.updateNowSetDontRefresh = true;
    return;
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
     MainViewController *pMainVwCntrl = [self.navViewController.viewControllers objectAtIndex:0];
    printf("Clicked button at index %ld\n", (long)buttonIndex);
    UIBarButtonItem *pBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(iCloudEmailCancel) ];
    self.navViewController.navigationBar.topItem.leftBarButtonItem = pBarItem;
     self.navViewController.toolbarHidden = NO;
   
    UIBarButtonItem *flexibleSpaceButtonItem = [[UIBarButtonItem alloc]
                                                initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                target:nil action:nil];
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 45)];
	footer.backgroundColor = [UIColor clearColor];
	pMainVwCntrl.pAllItms.tableView.tableFooterView = footer;
    UIBarButtonItem *pBarItem1;
    if (bUpgradeAction)
    {
        bUpgradeAction = false;
        switch (buttonIndex)
        {
            case 0:
                NSLog(@"Purchasing openhouses_unlocked");
                //purchased = false;
                if (!purchased)
                    [inapp start:true];
                else
                    NSLog(@"Already upgraded, ignoring");
                [self iCloudEmailCancel];
            break;
                
            case 1:
                NSLog(@"Restoring openhouses_unlocked");
                if (!purchased)
                    [inapp start:false];
                else
                    NSLog(@"Already upgraded, ignoring");
                [self iCloudEmailCancel];
                
            break;
                
            default:
                [self iCloudEmailCancel];
              
            break;
        }
        return;
    }
    
    if (buttonIndex == 0)
    {
        NSLog(@"In email \n");
        pMainVwCntrl.pAllItms.bInEmail = true;
        pMainVwCntrl.emailAction = true;
        pBarItem1 = [[UIBarButtonItem alloc] initWithTitle:@"Email" style:UIBarButtonItemStylePlain target:self action:@selector(emailNow)];
        
    }
    else if (buttonIndex == 1)
    {
        UIDevice *dev = [UIDevice currentDevice];
        if ([[dev systemVersion] doubleValue] < 6.0)
        {
            [self iCloudEmailCancel];
            return;
        }
        NSLog(@"In facebook share\n");
        pMainVwCntrl.pAllItms.bInEmail = true;
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
        {
            pBarItem1 = [[UIBarButtonItem alloc] initWithTitle:@"Facebook" style:UIBarButtonItemStylePlain target:self action:@selector(fbshareNow)];
            

        }
        else
        {
            UIAlertView *pAvw = [[UIAlertView alloc] initWithTitle:@"No Facebook Account" message:@"Please set up facebook account in settings. House details including pictures can be shared with selected group of friends on Facebook" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            bNoICloudAlrt = true;
            [pAvw show];
        }
    }
    else if (buttonIndex == 2)
    {
        
        [self iCloudEmailCancel];
        bUpgradeAction = true;
        UIActionSheet *pSh;
        
        pSh= [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Purchase", @"Restore Purchases", nil];
        
        MainViewController *pMainVwCntrl = [self.navViewController.viewControllers objectAtIndex:0];
        [pMainVwCntrl.pAllItms lockItems];
        [pSh setDelegate:self];
        [pSh showInView:pMainVwCntrl.pAllItms.tableView];
        

        
    }
    else
    {
        [self iCloudEmailCancel];
        return;
    }

    [pMainVwCntrl setToolbarItems:[NSArray arrayWithObjects:
                                   flexibleSpaceButtonItem,
                                   pBarItem1,
                                   flexibleSpaceButtonItem,
                                   nil]
                         animated:YES];   
     self.dataSync.updateNowSetDontRefresh = true;
    //[pMainVwCntrl.pAllItms.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationLeft];
        return;
    

}



-(void) iCloudOrEmail
{
    NSLog(@"Showing iCloud email action sheet \n");
    
    //Move files to iCloud, pull files from iCloud
    //how to reconcile
    //Album directory name by time of
    
    UIActionSheet *pSh;
    
    pSh= [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email", @"Facebook share", @"Upgrade", nil];
   
   MainViewController *pMainVwCntrl = [self.navViewController.viewControllers objectAtIndex:0];
    [pMainVwCntrl.pAllItms lockItems];
    [pSh setDelegate:self];
    [pSh showInView:pMainVwCntrl.pAllItms.tableView];
    
    


    return;
}

- (void)initializeiCloudAccess 
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *containerID = @"3JEQ693MKL.com.rekhaninan.OpenHouses";
        if ([[NSFileManager defaultManager]
             URLForUbiquityContainerIdentifier:containerID] != nil)
        {
            NSLog(@"iCloud is available\n");
            biCloudAvail = true;
        }
        else
            NSLog(@"iCloud,  is not available.\n");
    });
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"Got did update user location in AppDelegate latitude=%f longitude=%f\n", locmgr.location.coordinate.latitude, locmgr.location.coordinate.longitude);
    
    if (fabs([locmgr.location.timestamp timeIntervalSinceNow]) > 10.0)
    {
        NSLog(@"Stale location ignoring\n");
        return;
    }
    
    if (fabs(locmgr.location.coordinate.latitude) <= 0.0000001 && fabs(locmgr.location.coordinate.longitude) <= 0.000001  )
    {
        NSLog(@"0 degree longitude and 0 degree latitude, ignoring location\n");
        return;
    }
    
    if (aVw != nil)
        [aVw setLocation:locmgr.location];
    return;
}

- (void)mapView:(MKMapView *)mapViewL didUpdateUserLocation:(MKUserLocation *)userLocation
{
    UIDevice *dev = [UIDevice currentDevice];
    NSLog(@"system version %f", [[dev systemVersion] doubleValue]);
        loc = [userLocation location];
        NSLog(@"Got did update user location in AppDelegate latitude=%f longitude=%f\n", loc.coordinate.latitude, loc.coordinate.longitude);
        if (aVw != nil)
            [aVw setLocation:loc];
}

-(void) setPurchsd
{
    NSLog(@"Setting purchased to true");
    purchased = true;
    NSUserDefaults* kvlocal = [NSUserDefaults standardUserDefaults];
    [kvlocal setBool:YES forKey:@"Purchased"];
    if (kvstore)
        [kvstore setBool:YES forKey:@"Purchased"];
    if (!bShrMgrStarted)
    {
        pShrMgr = [[OpenHousesShareMgr alloc] init];
        [pShrMgr start];
        bShrMgrStarted = true;
    }

}


-(void) storeDidChange:(NSUbiquitousKeyValueStore *)kstore
{
    if (!bKvInit)
    {
        bKvInit = true;
        [kvstore synchronize];
        NSLog(@"Initialized kvstore\n");
        return;
    }
    COUNT = [kvstore longLongForKey:@"TotRows"];
    totcount = [kvstore longLongForKey:@"TotTrans"];
    NSLog(@"Got storeDidChange counts COUNT=%lld totcount=%lld\n", COUNT, totcount);
    if (!purchased)
    {
        BOOL purch = [kvstore boolForKey:@"Purchased"];
        if (purch == YES)
        {
            purchased = true;
            NSUserDefaults* kvlocal = [NSUserDefaults standardUserDefaults];
            [kvlocal setBool:YES forKey:@"Purchased"];
        }
        
    }

    
    if (userName == nil)
    {
        userName = [kvstore stringForKey:@"UserName"];
        if (userName != nil && [userName length] > 0)
            bRegistered = true;
        NSLog(@"Got username %@ from ubiquitous kvstore\n", userName);
     #ifdef CLEANUP   
       [kvstore removeObjectForKey:@"UserName"];
       [kvstore removeObjectForKey:@"Friends"];
        [kvstore setLongLong:0 forKey:@"TotRows"];
        [kvstore setLongLong:0 forKey:@"TotTrans"];
    #endif
    }

    return;
}

-(void) addToCount
{
    ++COUNT;
    ++totcount;
    if (kvstore)
    {
        [kvstore setLongLong:COUNT forKey:@"TotRows"];
        [kvstore setLongLong:totcount forKey:@"TotTrans"];
    }
    
        NSUserDefaults* kvlocal = [NSUserDefaults standardUserDefaults];
        [kvlocal setInteger:(NSInteger)COUNT  forKey:@"TotRows"];
        [kvlocal setInteger:(NSInteger)totcount forKey:@"TotTrans"];
    
    return;
}

-(void) addToTotCount
{
    ++totcount;
    if (kvstore)
    {
        [kvstore setLongLong:totcount forKey:@"TotTrans"];
    }
    else
    {
        NSUserDefaults* kvlocal = [NSUserDefaults standardUserDefaults];
        [kvlocal setInteger:(NSInteger)totcount forKey:@"TotTrans"];
    }
    return;
}

-(void) addToTotCountNoR
{
    ++totcount;
    if (kvstore)
    {
        [kvstore setLongLong:totcount forKey:@"TotTrans"];
    }
    else
    {
        NSUserDefaults* kvlocal = [NSUserDefaults standardUserDefaults];
        [kvlocal setInteger:(NSInteger)totcount forKey:@"TotTrans"];
    }
    return;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    NSLog(@"APPLICATION did receive memory warning\n");
    
}

-(NSString *) getPassword
{
    passWord = [kchain objectForKey:(__bridge id)kSecValueData];
    if (passWord != nil && [passWord length]>0)
    {
        bPassword = true;
        NSLog(@"Getting password %@\n", passWord);
        return passWord;
    }
    NSLog(@"Failed to get password\n");
    return  nil;
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
    
    return;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{

  @try
  {
    NSUserDefaults* kvlocal = [NSUserDefaults standardUserDefaults];
    NSData *tokenNow = [kvlocal dataForKey:@"NotToken"];
    NSLog(@"Did register for remote notification with token %@ tokenNow=%@", deviceToken, tokenNow);
    bool bChange = false;
    if (tokenNow == nil)
    {
        [kvlocal setObject:deviceToken forKey:@"NotToken"];
        bChange = true;
    }
    else
    {
            if (![deviceToken isEqualToData:tokenNow])
            {
                [kvlocal setObject:deviceToken forKey:@"NotToken"];
                bChange = true;
            }
    }
    
    NSLog(@"bRegistered=%s, bChange=%s bTokPut=%s", bRegistered?"true":"false", bChange?"true":"false", bTokPut?"YES":"NO");
       }
   @catch (NSException *exception)
   {
        NSLog(@" Caught %@: %@", [exception name], [exception reason]);
   }
   @finally
   {
       NSLog(@"Doing nothing");
   }
    return;
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Failed to register for remote notification %@\n", error);
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"Application did become active");
    if (bFirstActive)
    {
        NSLog(@"First time activation skipping download items on start up as it is called from application didFinishLaunchingWithOptions");
        bFirstActive = false;
        return;
    }
    
    if (!bRegistered)
    {
        NSString *unameInKChain = [kchain objectForKey:(__bridge id)kSecAttrAccount];
        if (unameInKChain != nil && [unameInKChain length] > 0)
        {
            NSLog(@"Login now as we got a registered signal");
            NSLog(@"Registered Never logged in before so popping up alert to allow push notifications for sharing and then login");
            bShareAction = true;
            userName = unameInKChain;

            UIAlertView *pAvw = [[UIAlertView alloc] initWithTitle:@"Enable Sharing" message:@"Notifications must be allowed for sharing. Please click OK when prompted for \"OpenHouses App would like to send notifications\" or enable notifications in the notification center." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [pAvw show];

        }
        else
        {
            //This case is to address the scenario  where Autospree app is started and put in background and openhouses did the registration. and now we have to reinitialize kchain object to sync it
             kchain = [[KeychainItemWrapper alloc] initWithIdentifier:@"LoginData" accessGroup:@"3JEQ693MKL.com.rekhaninan.sinacama"];
            unameInKChain = [kchain objectForKey:(__bridge id)kSecAttrAccount];
            if (unameInKChain != nil && [unameInKChain length] > 0)
            {
                NSLog(@"Login now as we got a registered signal");
                NSLog(@"Registered Never logged in before so popping up alert to allow push notifications for sharing and then login");
                bShareAction = true;
                userName = unameInKChain;
                UIAlertView *pAvw = [[UIAlertView alloc] initWithTitle:@"Enable Sharing" message:@"Notifications must be allowed for sharing. Please click OK when prompted for \"OpenHouses App would like to send notifications\" or enable notifications in the notification center." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [pAvw show];
                
            }

            //Now try once again
        }

    }
    return;
}

-(void) cleanUpEverything
{
    NSUserDefaults* kvlocal = [NSUserDefaults standardUserDefaults];
    kvstore = [NSUbiquitousKeyValueStore defaultStore];
    if(kvstore)
    {
        [kvstore removeObjectForKey:@"UserName"];
        [kvstore removeObjectForKey:@"Friends"];
        [kvstore setLongLong:0 forKey:@"TotRows"];
        [kvstore setLongLong:0 forKey:@"TotTrans"];
    }
    [kchain resetKeychainItem];
   
    [kvlocal setInteger:0 forKey:@"SelfHelp"];
    [kvlocal setInteger:0 forKey:@"TotRows"];
    [kvlocal setInteger:0 forKey:@"TotTrans"];
    [kvlocal removeObjectForKey:@"NotToken"];
    fetchQueue = dispatch_queue_create("com.rekhaninan.fetchQueue", NULL);
    if (kvstore)
    {
        [[NSNotificationCenter defaultCenter]
         addObserver: self
         selector: @selector (storeDidChange:)
         name: NSUbiquitousKeyValueStoreDidChangeExternallyNotification
         object: kvstore];
        dispatch_async(fetchQueue, ^{
            [self storeDidChange:kvstore];
        });
    }
    

    return;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    bShrMgrStarted = false;
    bFirstActive = true;
    pFlMgr = [[NSFileManager alloc] init];
    NSString *pHdir = NSHomeDirectory();
    sortIndx = 0;
    bUpgradeAlert = false;
    unlocked = false;
    bDateAsc = true;
    bPriceAsc = true;
    bAreaAsc = true;
    bYearAsc = true;
    bBedsAsc = true;
    bBathsAsc = true;
    biCloudAvail = false;
    bEmailConfirm = false;
    toggle = 0;
    bPtoPShare = false;
    bInitRefresh = true;
    photo_scale = 1.0;
    bNoICloudAlrt = false;
    bFBAction = false;
    bRegistered = false;
    bSharingDisabled = true;
    bShareAction = false;
    bChkdFrndLst = false;
    bPersistError = false;
    bInBackGround = false;
    bFromShareAction = false;
    beingLoggedIn = false;
    purchased = false;
    bUpgradeAction = false;
    bSystemAbrt = false;
    NSLog(@"Launching openhouses");
    inapp = [[InAppPurchase alloc] init];
    [inapp setDelegate:self];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:inapp];
    NSUserDefaults* kvlocal = [NSUserDefaults standardUserDefaults];
    [self populateOneMonth];
    kvstore = [NSUbiquitousKeyValueStore defaultStore];
      kchain = [[KeychainItemWrapper alloc] initWithIdentifier:@"LoginData" accessGroup:@"3JEQ693MKL.com.rekhaninan.sinacama"];
    
#ifdef CLEANUP
         [self cleanUpEverything];
          return YES ;
#endif
    
    NSError *error;
    dataSync = [[DataOps alloc] init];
    [dataSync start];
    
    NSString *pAlbumsDir = [pHdir stringByAppendingPathComponent:@"/Documents/albums"];
    saveQ = [[NSOperationQueue alloc] init];
    NSLog (@"initialized saveQ %s %d \n", __FILE__, __LINE__);
    if ([pFlMgr createDirectoryAtPath:pAlbumsDir withIntermediateDirectories:NO attributes:nil error:&error] == YES)
    {
       
        printf("Created album directory %s \n", [pAlbumsDir UTF8String]);
    }
    else
        printf("Fail to create album directory %s reason %s\n", [pAlbumsDir UTF8String], [[error localizedDescription] UTF8String]);
   // [self initializeiCloudAccess];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    MainViewController *aViewController = [[MainViewController alloc]
                                           initWithNibName:nil bundle:nil];
    aViewController.pAllItms.bInICloudSync = false;
    aViewController.pAllItms.bInEmail = false;
    aViewController.pAllItms.bAttchmentsInit = false;
    
    fetchQueue = dispatch_queue_create("com.rekhaninan.fetchQueue", NULL);
        userName = [kchain objectForKey:(__bridge id)kSecAttrAccount];
    if(userName != nil && [userName length] > 0)
    {
        NSLog(@"userName=%@\n", userName);
        bRegistered = true;
        
    }
    else
    {
        if(kvstore)
            userName = [kvstore stringForKey:@"UserName"];
        if(userName != nil && [userName length] > 0)
        {
            NSLog(@"userName=%@\n", userName);
            bRegistered = true;
        }
        else
        {
            NSLog(@"Not registered for sharing");
        }
            

    }

    
    bKvInit = false;
    
    if (kvstore)
    {
        [[NSNotificationCenter defaultCenter]
         addObserver: self
         selector: @selector (storeDidChange:)
         name: NSUbiquitousKeyValueStoreDidChangeExternallyNotification
         object: kvstore];
        dispatch_async(fetchQueue, ^{
            [self storeDidChange:kvstore];
        });
    }
    COUNT = [kvlocal integerForKey:@"TotRows"];
    totcount = [kvlocal integerForKey:@"TotTrans"];
        
    bTokPut = [kvlocal boolForKey:@"TokInAws"];
    
    BOOL purch = [kvlocal boolForKey:@"Purchased"];
    if (purch == YES)
        purchased = true;
    
        // Override point for customization after application launch.
    UINavigationController *navCntrl = [[UINavigationController alloc] initWithRootViewController:aViewController];
    self.navViewController = navCntrl;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window addSubview:self.navViewController.view];
    [self.window makeKeyAndVisible];
     CGRect mapFrame = CGRectMake(90, 12, 200, 25);
    mapView = [[MKMapView alloc] initWithFrame:mapFrame];
    mapView.showsUserLocation = NO;
    mapView.delegate = self;
    locmgr = [[CLLocationManager alloc] init];
    locmgr.delegate = self;
    UIDevice *dev = [UIDevice currentDevice];
    sysver = [[dev systemVersion] doubleValue];
    
    
    if (sysver >= 6.0)
    {
        NSLog(@"Not pausing location updates automatically\n");
        locmgr.pausesLocationUpdatesAutomatically = NO;
    }
    [locmgr stopUpdatingLocation];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMainScreen:) name:@"RefetchAllDatabaseData" object:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadFetchedResults:) name:@"RefreshAllViews" object:self];
    
    if (biCloudAvail)
        NSLog (@"iCloud available\n");
    else
        NSLog (@"iCloud NOT available at this point\n");
    self.window.backgroundColor = [UIColor whiteColor];
    //[self.window addSubview:self.navViewController.view];
    [self.window setRootViewController:self.navViewController];
    [self.window makeKeyAndVisible];
    return YES;
}



-(NSArray *)itemsToDownLoad
{
     NSUserDefaults* kvlocal = [NSUserDefaults standardUserDefaults];
    return [kvlocal arrayForKey:@"DownLoadItems"];
}

-(void) removeAllDownLoadItems
{
    NSUserDefaults* kvlocal = [NSUserDefaults standardUserDefaults];
    [kvlocal removeObjectForKey:@"DownLoadItems"];
    [kvlocal setInteger:0 forKey:@"ToDownLoad"];
    
    return;
}

-(void) removeFromDownLoadItems:(NSString *)item
{
    NSUserDefaults* kvlocal = [NSUserDefaults standardUserDefaults];
    NSArray *dwldArr = [kvlocal arrayForKey:@"DownLoadItems"];
    if (dwldArr == nil || ![dwldArr count])
        return;
    NSMutableArray *dwldNewArr =[[NSMutableArray alloc] initWithCapacity:[dwldArr count]];
    for (NSString *dwldItem in dwldArr)
    {
        if ([item isEqualToString:dwldItem])
        {
            if (toDownLoad >0)
            {
                toDownLoad -= 1;
            }
            [kvlocal setInteger:toDownLoad forKey:@"ToDownLoad"];
            continue;
        }
        [dwldNewArr addObject:dwldItem];
    }
    if (![dwldNewArr count])
    {
        [kvlocal removeObjectForKey:@"DownLoadItems"];
        return;
    }
    [kvlocal setObject:dwldNewArr forKey:@"DownLoadItems"];
}

-(void) addToDownLoadItems:(NSArray *)dwldItems
{
    NSUserDefaults* kvlocal = [NSUserDefaults standardUserDefaults];
    NSArray *dwldArr = [kvlocal arrayForKey:@"DownLoadItems"];
    if (dwldArr !=nil && [dwldArr count])
    {
        [kvlocal setObject:[dwldArr arrayByAddingObjectsFromArray:dwldItems] forKey:@"DownLoadItems"];
     }
    else
    {
        [kvlocal setObject:dwldItems forKey:@"DownLoadItems"];
    }
    return;
}

-(void) storeInKeyChain
{
    [kchain setObject:userName forKey:(__bridge id)kSecAttrAccount];
    
    // Store password to keychain
    [kchain setObject:passWord forKey:(__bridge id)kSecValueData];
    
    if(kvstore)
    {
        [kvstore setString:userName forKey:@"UserName"];
    }
    passWord = @"";
    bRegistered = true;
    return;
    
}

-(void) storeFriends
{
    if (friendList != nil && [friendList length] > 0)
    {
        NSLog(@"Storing friend list %@ in key chain and kv store", friendList);
        [kchain setObject:friendList forKey:(__bridge id)kSecAttrComment];
        if(kvstore)
        {
            [kvstore setString:friendList forKey:@"Friends"];
        }
    }
    return;
}

-(void)reloadFetchedResults :(NSNotification*)note
{
   
    return;
}

-(void)reloadMainScreen :(NSNotification*)note
{
    dataSync.refreshNow = true;
    return;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    bInBackGround = true;
    self.navViewController.navigationBar.tintColor = nil;
    return;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    bInBackGround = false;
    return;
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             */
            NSLog(@"Unresolved error while saving MOC %@, %@", error, [error userInfo]);
           // abort();
        } 
    }
}

#pragma mark - Core Data stack
// this takes the NSPersistentStoreDidImportUbiquitousContentChangesNotification
// and transforms the userInfo dictionary into something that
// -[NSManagedObjectContext mergeChangesFromContextDidSaveNotification:] can consume
// then it posts a custom notification to let detail views know they might want to refresh.
// The main list view doesn't need that custom notification because the NSFetchedResultsController is
// already listening directly to the NSManagedObjectContext
- (void)mergeiCloudChanges:(NSNotification*)note forContext:(NSManagedObjectContext*)moc
{
    if (!unlocked)
    {
        return;
    }
    [moc mergeChangesFromContextDidSaveNotification:note];
    
    NSNotification* refreshNotification = [NSNotification notificationWithName:@"RefreshAllViews" object:self  userInfo:[note userInfo]];
    
    [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
}

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
/*
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

 */

- (NSManagedObjectContext *)managedObjectContext {
	
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (coordinator != nil) 
    {
        // Make life easier by adopting the new NSManagedObjectContext concurrency API
        // the NSMainQueueConcurrencyType is good for interacting with views and controllers since
        // they are all bound to the main thread anyway
        NSManagedObjectContext* moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        
        [moc performBlockAndWait:^{
            // even the post initialization needs to be done within the Block
            [moc setPersistentStoreCoordinator: coordinator];
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(mergeChangesFrom_iCloud:) name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:coordinator];
        }];
        __managedObjectContext = moc;
    }
    [__managedObjectContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
    return __managedObjectContext;
}

// NSNotifications are posted synchronously on the caller's thread
// make sure to vector this back to the thread we want, in this case
// the main thread for our views & controller
- (void)mergeChangesFrom_iCloud:(NSNotification *)notification
{
	//NSManagedObjectContext* moc = [self managedObjectContext];
    
    // this only works if you used NSMainQueueConcurrencyType
    // otherwise use a dispatch_async back to the main thread yourself
    //[moc performBlock:^{
     //   [self mergeiCloudChanges:notification forContext:moc];
    //}];
    
    if (!unlocked)
    {
        return;
    }
    
     NSLog(@"Merging change from iCloud refreshNow set to true in AppDelegate\n");
    [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
    dataSync.refreshNow = true;
    
   
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Shopper" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
    
    
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    unlocked = false;
    NSError *error = nil;
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Shopper.sqlite"];
    NSUserDefaults* kvlocal = [NSUserDefaults standardUserDefaults];
    
    
      __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSData *tokenData = [kvlocal objectForKey:@"iCloudToken"];
    if (tokenData !=nil)
    {
        NSArray *tokArry = [kvlocal arrayForKey:@"iCloudTokens"];
        int i=0;
        bool bTokInArry = false;
        for (NSData *tok in tokArry)
        {
            NSLog(@"Token Data %@", tok);
            if ([tok isEqualToData:tokenData])
            {
                bTokInArry = true;
                if (i)
                {
                    NSString *storeURLStr = [NSString stringWithFormat:@"AutoSpree%d.sqlite", i];
                    storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:storeURLStr];
                }
                break;
            }
        }
    }
    
    NSLog(@"Setting URL to %@", storeURL);
    
    
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        
        bSystemAbrt = true;
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        
        UIAlertView *pAvw = [[UIAlertView alloc] initWithTitle:@"System error" message:@"Restart the app. If Delete the app and reinstall and  restart." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [pAvw show];
    }
    return __persistentStoreCoordinator;
    
   
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end

