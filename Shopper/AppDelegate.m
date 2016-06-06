//
//  AppDelegate.m
//  Shopper
//
//  Created by Ninan Thomas on 12/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "common/MainViewController.h"
#import "common/AddViewController.h"
#import "common/EditViewController.h"
#import "common/DisplayViewController.h"
#import "Item.h"
#import <MapKit/MapKit.h>
#import <sharing/FriendDetails.h>
#import <sharing/AddFriendViewController.h>
#import "SortOptionViewController.h"
#import "AddEditDispDelegate.h"


@implementation AppDelegate

@synthesize window = _window;

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
@synthesize pShrMgr;
@synthesize appUtl;
@synthesize apputil;

-(void) setPurchsed
{
    [kchain setObject:@"true" forKey:(__bridge id)kSecAttrAccount];
    return;
}

-(void) iCloudOrEmail
{
    [apputil iCloudOrEmail];
}

- (NSString *) getAlbumDir: (NSString *) album_name
{
    NSString *pHdir = NSHomeDirectory();
    NSString *pAlbums = @"/Documents/albums";
    NSString *pAlbumsDir = [pHdir stringByAppendingString:pAlbums];
    pAlbumsDir = [pAlbumsDir stringByAppendingString:@"/"];
    NSString *pNewAlbum = [pAlbumsDir stringByAppendingString:album_name];
    NSURL *url = [NSURL fileURLWithPath:pNewAlbum isDirectory:YES];
    return [url absoluteString];
}

-(void) setAlbumName:(id) item albumcntrl:(AlbumContentsViewController *) cntrl
{
    LocalItem *itm = item;
    if (selectedItem.icloudsync == YES)
        pAlName = itm.album_name;
    else
        pAlName  = [apputil getAlbumDir:itm.album_name];
    [cntrl setPFlMgr:pFlMgr];
    [cntrl setPAlName:pAlName];
    [cntrl setName:itm.name];
    if (itm.street != nil)
        [cntrl setStreet:itm.street];
    return;
}

-(void) photoActions:(int) source
{
    [apputil photoActions:source];
    return;
}

-(void) initRefresh
{
    if (bInitRefresh)
    {
        bInitRefresh = false;
        NSLog(@"AppDelegate.bInitRefresh set to false");
    }
    else
    {
        dataSync.refreshNow = true;
        NSLog(@"Setting AppDelegate.dataSync.refreshNow to true");
    }
    return;
}

-(void) searchStrSet:(NSString *)text
{
    pSearchStr = text;
    dataSync.refreshNow = true;
    return;
}

-(void) searchStrReset
{
    pSearchStr = nil;
    dataSync.refreshNow = true;
    return;
}

-(NSString *) getLabelTxt:(id) itm
{
    LocalItem *item = itm;
    NSString *labtxt = item.name;
    labtxt = [labtxt stringByAppendingString:@" - "];
    if (item.street != nil)
        labtxt = [labtxt stringByAppendingString:item.street];
    
    return labtxt;
}

-(void) pushSortOptionViewController
{
    SortOptionViewController *aViewController = [[SortOptionViewController alloc]
                                                 initWithNibName:nil bundle:nil];
    [self.navViewController pushViewController:aViewController animated:YES];

    return;
}

-(void) pushDisplayViewController:(id) itm indx:(int)Indx
{
    LocalItem *item = itm;
    selectedItem = item;
    editItem = item;
    selectIndx = Indx;
    editIndx = Indx;
    if (selectedItem.icloudsync == YES)
        pAlName = selectedItem.album_name;
    else
        pAlName = [apputil getAlbumDir:selectedItem.album_name];
    NSLog(@"Setting pDlg.pAlName=%@", pAlName);
    
    DisplayViewController *aViewController = [[DisplayViewController alloc]
                                              initWithNibName:nil bundle:nil];
    [aViewController setPFlMgr:pFlMgr];
    [aViewController setPAlName:pAlName];
    [aViewController setNavViewController:self.navViewController];
    [aViewController setDelegate:[[AddEditDispDelegate alloc]init]];
    
    [self.navViewController pushViewController:aViewController animated:YES];
    return;
}

-(NSString *) getItemName:(id)itm
{
    LocalItem *item = itm;
    return item.name;
}

-(void) storeThumbNailImage:(NSURL *)picUrl
{
    UIImage  *fullScreenImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:picUrl] scale:1.0];
    CGSize oImgSize;
    oImgSize.height = 71;
    oImgSize.width = 71;
    UIGraphicsBeginImageContext(oImgSize);
    [fullScreenImage drawInRect:CGRectMake(0, 0, oImgSize.width, oImgSize.height)];
    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //  CGImageRef thumbnailImageRef = MyCreateThumbnailImageFromData (data, 5);
    // UIImage *thumbnail = [UIImage imageWithCGImage:thumbnailImageRef];
    CGSize pImgSiz = [thumbnail size];
    NSLog(@"Added thumbnail Image height = %f width=%f \n", pImgSiz.height, pImgSiz.width);
    
    NSData *thumbnaildata = UIImageJPEGRepresentation(thumbnail, 0.3);
    
   // [pAlName stringByAppendingString:@"/thumbnails/"];
    NSURL *albumurl = [picUrl URLByDeletingLastPathComponent];
    albumurl = [albumurl URLByAppendingPathComponent:@"thumbnails" isDirectory:YES];
   // NSURL  *albumurl = pDlg.pThumbNailsDir;
    NSError *err;
    NSString *pFlName = [picUrl lastPathComponent];
    NSURL *pFlUrl;
    if (albumurl != nil && [albumurl checkResourceIsReachableAndReturnError:&err])
    {
        
        pFlUrl = [albumurl URLByAppendingPathComponent:pFlName isDirectory:NO];
    }
    
    if ([thumbnaildata writeToURL:pFlUrl atomically:YES] == NO)
    {
        NSLog (@"Failed to write to thumbnail file  %@\n",  pFlUrl);
        return;
        // --nAlNo;
        
    }
    else
    {
        NSLog(@"Save thumbnail file %@\n", pFlUrl);
    }
    
    

    return;
}

-(NSURL *) getPicUrl:(long long ) shareId picName:(NSString *) name itemName:(NSString *) iName
{
    NSString *pAlbumName = [dataSync getAlbumName:shareId itemName:iName];
    if (pAlbumName == nil)
        return nil;
    NSString *pAlbumDir = [apputil getAlbumDir:pAlbumName];
    NSString *picFil = [pAlbumDir stringByAppendingString:@"/"];
    picFil  = [picFil stringByAppendingString:name];
    NSURL *picUrl = [NSURL URLWithString:picFil];
    return picUrl;
}

-(void) decodeAndStoreItem :(NSString *) ItemStr
{
    NSArray *pArr = [ItemStr componentsSeparatedByString:@"]:;"];
    NSMutableDictionary *pItemDic = [[NSMutableDictionary alloc] init];
    NSUInteger cnt = [pArr count];
    for (NSUInteger i=0; i < cnt; ++i)
    {
        NSString *kval = [pArr objectAtIndex:i];
        NSArray  *kvarr = [kval componentsSeparatedByString:@":|:"];
        NSUInteger kvcnt = [kvarr count];
        if (kvcnt != 2)
            continue;
        [pItemDic setObject:[kvarr objectAtIndex:1] forKey:[kvarr objectAtIndex:0]];
    }
    LocalItem *pItem = [[LocalItem alloc] init];
    NSString *pName = [pItemDic objectForKey:@"Name"];
    if (pName != nil)
        pItem.name  = pName;
    NSString *pPrice = [pItemDic objectForKey:@"Price"];
    if (pPrice != nil)
        pItem.price = [NSNumber numberWithFloat:[pPrice floatValue]];
    NSString *pArea = [pItemDic objectForKey:@"Area"];
    if (pArea != nil)
        pItem.area = [NSNumber numberWithFloat:[pArea floatValue]];
    NSString *pYear = [pItemDic objectForKey:@"Year"];
    if (pYear != nil)
        pItem.year = [pYear intValue];
    NSString *pBeds = [pItemDic objectForKey:@"Beds"];
    if (pBeds != nil)
        pItem.beds = [NSNumber numberWithFloat:[pBeds floatValue]];
    NSString *pBaths = [pItemDic objectForKey:@"Baths"];
    if (pBaths != nil)
        pItem.baths = [NSNumber numberWithFloat:[pBaths floatValue]];
    NSString *pNotes = [pItemDic objectForKey:@"Notes"];
    if (pNotes != nil)
        pItem.notes = pNotes;
    NSString *pStreet = [pItemDic objectForKey:@"Street"];
    if (pStreet != nil)
        pItem.street = pStreet;
    NSString *pCity = [pItemDic objectForKey:@"City"];
    if (pCity != nil)
        pItem.city = pCity;
    NSString *pState = [pItemDic objectForKey:@"State"];
    if (pState != nil)
        pItem.state = pState;
    NSString *pZip = [pItemDic objectForKey:@"PostalCode"];
    if (pZip != nil)
        pItem.zip = pZip;
    NSString *pLat = [pItemDic objectForKey:@"latitude"];
    if (pLat != nil)
        pItem.latitude = [pLat doubleValue];
    NSString *pLong = [pItemDic objectForKey:@"longitude"];
    if (pLong != nil)
        pItem.longitude = [pLong doubleValue];
    NSString *pStr1 = [pItemDic objectForKey:@"str1"];
    if (pStr1 != nil)
        pItem.str1 = pStr1;
    NSString *pShrId = [pItemDic objectForKey:@"shareId"];
    if (pShrId != nil)
        pItem.val2 = [pShrId doubleValue];
    struct timeval tv;
    gettimeofday(&tv, 0);
    long long sec = ((long long)tv.tv_sec)*1000000;
    long long usec =tv.tv_usec;
    pItem.val1 = sec + usec;
    NSString *pHdir = NSHomeDirectory();
    NSString *pAlbums = @"/Documents/albums";
    NSString *pAlbumsDir = [pHdir stringByAppendingString:pAlbums];
    NSLog(@"create new album name in directory %@", pAlbumsDir);
    gettimeofday(&tv, NULL);
    sec = ((long long)tv.tv_sec)*1000000;
    usec = tv.tv_usec;
    long long alNo =  sec+ usec;
    NSString *intStr = [[NSNumber numberWithLongLong:alNo] stringValue];
    pItem.album_name = intStr;
    bool bNewItem = true;
    if (![dataSync isNewItem:pItem])
    {
        bNewItem = false;
    }
    if (bNewItem)
    {
        [dataSync addItem:pItem];
    }
    else
    {
        [dataSync editedItem:pItem];
    }
       return;
}

-(NSString *) getShareMsg:(id)itm
{
    LocalItem *item = itm;
    NSString *message = @"";
    NSString *msg =[message stringByAppendingFormat:@"Name:|:%@]:;Price:|:%.2f]:;Area:|:%.2f]:;Year:|:%d]:;Beds:|:%.2f]:;Baths:|:%.2f]:;Notes:|: %@]:;Street:|:%@]:;City:|:%@]:;State:|:%@]:;Country:|:%@]:;PostalCode:|:%@]:;latitude:|:%f]:;longitude:|:%f]:;str1:|:%@]:;shareId:|:%.2lld",item.name, [item.price floatValue] < 0.0? 0.0: [item.price floatValue],
                    [item.area floatValue] < 0.0 ? 0.0 : [item.area floatValue],
                    item.year == 3000? 0: item.year, [item.beds floatValue] < 0.0? 0.0:[item.beds floatValue] < 0.0, [item.baths floatValue] < 0.0? 0.0: [item.baths floatValue], item.notes, item.street,
                    item.city, item.state, item.country, item.zip, item.latitude, item.longitude, item.str1, pShrMgr.share_id];
    return msg;
    

}

-(NSString *) getEmailFbMsg:(id)itm
{
    LocalItem *item = itm;
    NSString *message = @"";
    NSString *msg =[message stringByAppendingFormat:@"Name:%@\nPrice: %.2f\nArea: %.2f  Year: %d\nBeds: %.2f  Baths: %.2f\n Notes: %@\nStreet: %@\nCity: %@\nState: %@\nCountry: %@\n Postal Code: %@\n\n\n",item.name, [item.price floatValue] < 0.0? 0.0: [item.price floatValue],
           [item.area floatValue] < 0.0 ? 0.0 : [item.area floatValue],
           item.year == 3000? 0: item.year, [item.beds floatValue] < 0.0? 0.0:[item.beds floatValue] < 0.0? 0.0: [item.beds floatValue], [item.baths floatValue] < 0.0? 0.0: [item.baths floatValue], item.notes, item.street,
           item.city, item.state, item.country, item.zip];
    return msg;
    
}

-(void) populateOneMonth
{
    oneMonth = 30*24*60*60*1000000;
    return;
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
    [aViewController setDelegate:[[AddEditDispDelegate alloc] init]];
    [aViewController setPAlName:pAlName];
    [aViewController setPFlMgr:pFlMgr];
    [aViewController setNavViewController:self.navViewController];
     
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
          
    AddViewController *pAddViewCntrl = (AddViewController *)[self.navViewController popViewControllerAnimated:NO];
    struct timeval tv;
    gettimeofday(&tv, 0);
    long long sec = ((long long)tv.tv_sec)*1000000;
    long long usec =tv.tv_usec;
    AddEditDispDelegate *pAddView = (AddEditDispDelegate *)pAddViewCntrl.delegate;
    
	pAddView.pNewItem.val1 = sec + usec;
    

    [dataSync addItem:pAddView.pNewItem];
    NSLog(@"New Item added %@\n", pAddView.pNewItem);
      selectedItem = pAddView.pNewItem;
    editItem = pAddView.pNewItem;
    
}

- (void)itemAdd
{    
  //  UIBarButtonItem *pBarItem1 = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(itemAddCancel) ];
    NSLog(@"Adding item purchase = %d COUNT = %lld", appUtl.purchased, COUNT);
    
    if (!appUtl.purchased)
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
    [pMainVwCntrl setDelegate:self];
    [pMainVwCntrl setDelegate_1:self];
    AddViewController *aViewController = [[AddViewController alloc]
                                          initWithNibName:nil bundle:nil];
    [aViewController setPFlMgr:pFlMgr];
    [aViewController setNavViewController:self.navViewController];
    [aViewController setDelegate:[[AddEditDispDelegate alloc]init]];
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


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"Clicked button at index %ld", (long)buttonIndex);
    if (bUpgradeAlert)
    {
        NSLog(@"Resetting bUpgradeAlert in alertview action");
        bUpgradeAlert = false;
        return;
    }
     int attchmnts = (int)buttonIndex;
    
    switch (attchmnts)
    {
        case 1:
        {
            [self itemAddCancelConfirm];
        }
            break;
            
        default:
            break;
    }
    return;
}

-(void) syncNow
{
    NSLog(@"Syncing to iCloud selected items\n");
    MainViewController *pMainVwCntrl = [self.navViewController.viewControllers objectAtIndex:0];
    [pMainVwCntrl.pAllItms syncSelectedtoiCloud];
    [self.apputil iCloudEmailCancel];
    return;
}

-(void) shareContactsAdd
{
    self.appUtl.selFrndCntrl.bModeShare = true;
    self.appUtl.tabBarController.selectedIndex = 1;
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
    if (!appUtl.purchased)
    {
        BOOL purch = [kvstore boolForKey:@"Purchased"];
        if (purch == YES)
        {
            appUtl.purchased = true;
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
    [appUtl didRegisterForRemoteNotification:deviceToken];
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
    toggle = 0;
    bPtoPShare = false;
    bInitRefresh = true;
    photo_scale = 1.0;
    bRegistered = false;
    bSharingDisabled = true;
    bShareAction = false;
    bChkdFrndLst = false;
    bInBackGround = false;
    bFromShareAction = false;
    beingLoggedIn = false;
    appUtl = [[AppShrUtil alloc] init];
    appUtl.purchased = false;
    pShrMgr = [[CommonShareMgr alloc] init];
    pShrMgr.pNtwIntf.connectAddr = @"openhouses.ddns.net";
    pShrMgr.pNtwIntf.connectAddr = @"16973";
    appUtl.pShrMgr = pShrMgr;
    pShrMgr.delegate = self;
    pShrMgr.shrMgrDelegate = self;
    NSLog(@"Launching openhouses");
    
    NSUserDefaults* kvlocal = [NSUserDefaults standardUserDefaults];
    [self populateOneMonth];
    kvstore = [NSUbiquitousKeyValueStore defaultStore];
    kchain = [[KeychainItemWrapper alloc] initWithIdentifier:@"LoginData" accessGroup:@"3JEQ693MKL.com.rekhaninan.sinacama"];
    apputil = [AppUtil alloc];
    apputil.delegate = self;
    [apputil setProductId:@"com.rekhaninan.openhouses_unlocked"];
     apputil = [apputil init];
    apputil.pShrMgr = pShrMgr;
    
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
    aViewController.delegate = self;
    aViewController.delegate_1  = self;
    
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
    [appUtl registerForRemoteNotifications];
    
    [apputil setWindow:self.window];
    apputil.navViewController = self.navViewController;
    [apputil initializeShrUtl];
    return YES;
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
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    bInBackGround = true;
    self.navViewController.navigationBar.tintColor = nil;
    return;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    bInBackGround = false;
    return;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self.dataSync saveContext];
}

@end
