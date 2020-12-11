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
#import "common/AppCmnUtil.h"
#import "AVFoundation/AVAssetImageGenerator.h"
#import "AVFoundation/AVAsset.h"
#import "AVFoundation/AVTime.h"
#import "CoreMedia/CMTime.h"
#import <BackgroundTasks/BackgroundTasks.h>

//#import "common/ThumbnailImageView.h"



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
@synthesize dataOpsDelegate;
@synthesize bRatingsAsc;
@synthesize share_id;
@synthesize selFrndCntrl;
@synthesize tabBarController;



-(void ) setShareId:(long long)shareId
{
    share_id = shareId;
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    pAppCmnUtil.share_id = share_id;
}

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
-(void) refreshShareView
{
    [apputil refreshShareView];
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

-(AlbumContentsViewController *) pushAlbumContentsViewController:(id) itm indx:(int)Indx source:(int)source delegate:(id )albumVwCntrlDelegate
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

    AlbumContentsViewController *albumContentsViewController = [AlbumContentsViewController alloc] ;
    NSLog(@"Pushing AlbumContents view controller %s %d\n" , __FILE__, __LINE__);
    //  albumContentsViewController.assetsGroup = group_;
    
    [albumContentsViewController setDelphoto:false];
    [albumContentsViewController setEmailphoto:true];
    [albumContentsViewController setPFlMgr:pFlMgr];
    [albumContentsViewController setPAlName:pAlName];
    [albumContentsViewController setDelegate:albumVwCntrlDelegate];
    [albumContentsViewController setNavViewController:self.navViewController];
    [albumContentsViewController setPhotoreqsource:source];
    albumContentsViewController = [albumContentsViewController initWithNibName:@"AlbumContentsViewController" bundle:nil];
    
    NSString *title ;
    if (selectedItem.street != nil)
        title = selectedItem.street;
    else
        title = @" ";
    [albumContentsViewController  setTitle:title];
    
    [appUtl pushAlbumContentsViewController:albumContentsViewController title:title];
    return albumContentsViewController;
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
    
    DisplayViewController *aViewController = [DisplayViewController alloc];
    
    [aViewController setPFlMgr:pFlMgr];
    [aViewController setPAlName:pAlName];
    [aViewController setNavViewController:self.navViewController];
    [aViewController setDelegate:[[AddEditDispDelegate alloc]init]];
    aViewController = [aViewController  initWithNibName:nil bundle:nil];
    
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
    UIImage  *fullScreenImage ;
    NSString *pFlName = [picUrl lastPathComponent];
    if ([pFlName hasSuffix:@".mp4"] || [pFlName hasSuffix:@".MOV"] )
    {
        AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:[AVAsset assetWithURL:picUrl]];
        CMTime thumbTime = CMTimeMakeWithSeconds(0.0, 600);
        NSError *error = nil;
        CMTime actualTime;
        
        CGImageRef startImage = [generator copyCGImageAtTime:thumbTime actualTime:&actualTime error:&error];
        fullScreenImage = [UIImage imageWithCGImage:startImage];
    }
    else
    {
        fullScreenImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:picUrl] scale:1.0];
    }
    
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
    
    if ([pFlName hasSuffix:@".mp4"])
    {
        pFlName = [pFlName stringByReplacingOccurrencesOfString:@"mp4" withString:@"jpg"];
        
    }
    else if ([pFlName hasSuffix:@".MOV"])
    {
        pFlName = [pFlName stringByReplacingOccurrencesOfString:@"MOV" withString:@"jpg"];
    }
    
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

-(NSURL *) getShareUrl:(long long ) shareId picName:(NSString *) name itemName:(NSString *) iName
{
    NSString *pAlbumName = [dataSync getAlbumName:shareId itemName:iName];
    if (pAlbumName == nil)
        return nil;
    NSString *pAlbumDir = [apputil getAlbumDir:pAlbumName];
    NSString *picFil = [pAlbumDir stringByAppendingString:@"sharing/"];
    picFil  = [picFil stringByAppendingString:name];
    NSURL *picUrl = [NSURL URLWithString:picFil];
    return picUrl;
}

- (void)displayAlert:(NSString *)msg {
    
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
    NSString *pCountry = [pItemDic objectForKey:@"Country"];
    if (pCountry != nil)
        pItem.country = pCountry;
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
    
    NSString *pStr2 = [pItemDic objectForKey:@"Ratings"];
    if (pStr2 != nil)
        pItem.str2 = pStr2;
    
    NSString *pShrId = [pItemDic objectForKey:@"shareId"];
    if (pShrId != nil)
    {
        pItem.val2 = [pShrId doubleValue];
        pItem.share_id = [pShrId longLongValue];
    }
    struct timeval tv;
    gettimeofday(&tv, 0);
    long long sec = ((long long)tv.tv_sec)*1000000;
    long long usec =tv.tv_usec;
    pItem.val1 = sec + usec;
    
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
        NSString *pHdir = NSHomeDirectory();
        NSString *pAlbums = @"/Documents/albums";
        NSString *pAlbumsDir = [pHdir stringByAppendingString:pAlbums];
        NSLog(@"create new album name in directory %@", pAlbumsDir);
        
        NSLog(@"Album params alNo=%lld tv_sec=%ld tv_usec=%d intStr=%@ sec=%lld usec=%lld", alNo,tv.tv_sec, tv.tv_usec, intStr, sec, usec);
        pAlbumsDir = [pAlbumsDir stringByAppendingString:@"/"];
        NSString *pNewAlbum = [pAlbumsDir stringByAppendingString:intStr];
        NSString *pThumpnail = [pNewAlbum stringByAppendingPathComponent:@"thumbnails"];
        BOOL  bDirCr = [pFlMgr createDirectoryAtPath:pThumpnail withIntermediateDirectories:YES attributes:nil error:nil];
        
        if(bDirCr == YES)
        {
            NSLog (@"Created new album %s album_name %@\n", [pThumpnail UTF8String], intStr);
        }
        
        NSString *pSharing = [pNewAlbum stringByAppendingPathComponent:@"sharing"];
          bDirCr = [pFlMgr createDirectoryAtPath:pSharing withIntermediateDirectories:YES attributes:nil error:nil];
        
        if(bDirCr == YES)
        {
            NSLog (@"Created sharing directory for received Item %@\n", pSharing);
        }

        //create directory
    }
    else
    {
        [dataSync editedItem:pItem];
    }
       return;
}

-(ItemKey *) getItemKey:(id) itm
{
  LocalItem *item = itm;
    ItemKey *itk = [[ItemKey alloc] init];
    itk.share_id = item.share_id;
    itk.name = item.name;
    return itk;
}

-(long long ) getItemShareId:(id) itm
{
   LocalItem *item = itm;
    return item.share_id;
}

-(NSString *) getShareMsg:(id)itm
{
    LocalItem *item = itm;
    NSString *message = @"";
    NSString *msg =[message stringByAppendingFormat:@"Name:|:%@]:;Price:|:%.2f]:;Area:|:%.2f]:;Year:|:%d]:;Beds:|:%.2f]:;Baths:|:%.2f]:;latitude:|:%f]:;longitude:|:%f]:;shareId:|:%lld]:;",item.name, [item.price floatValue] < 0.0? 0.0: [item.price floatValue],
                    [item.area floatValue] < 0.0 ? 0.0 : [item.area floatValue],
                    item.year == 3000? 0: item.year, [item.beds floatValue] < 0.0? 0.0:[item.beds floatValue] < 0.0? 0.0:[item.beds floatValue], [item.baths floatValue] < 0.0? 0.0: [item.baths floatValue],   item.latitude, item.longitude,  item.share_id];
    if (item.notes && [item.notes length])
    {
        msg = [msg stringByAppendingFormat:@"Notes:|:%@]:;", item.notes];
    }
    
    if (item.street && [item.street length])
    {
        msg = [msg stringByAppendingFormat:@"Street:|:%@]:;", item.street];
    }

    if (item.city && [item.city length])
    {
        msg = [msg stringByAppendingFormat:@"City:|:%@]:;", item.city];
    }
    
    if (item.state && [item.state length])
    {
        msg = [msg stringByAppendingFormat:@"State:|:%@]:;", item.state];
    }
    
    if (item.country && [item.country length])
    {
        msg = [msg stringByAppendingFormat:@"Country:|:%@]:;", item.country];
    }

    if (item.zip && [item.zip length])
    {
        msg = [msg stringByAppendingFormat:@"PostalCode:|:%@]:;", item.zip];
    }

    if (item.str1 && [item.str1 length])
    {
        msg = [msg stringByAppendingFormat:@"str1:|:%@]:;", item.str1];
    }

    if (item.str2 && [item.str2 length])
    {
        msg = [msg stringByAppendingFormat:@"Ratings:|:%@]:;", item.str2];
    }

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
    
    
    EditViewController *aViewController = [EditViewController alloc];
    
    [aViewController setDelegate:[[AddEditDispDelegate alloc] init]];
    [aViewController setPAlName:pAlName];
    [aViewController setPFlMgr:pFlMgr];
    [aViewController setNavViewController:self.navViewController];
    aViewController = [aViewController initWithNibName:nil bundle:nil];
     
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
    //DisplayViewController *pDisp = (DisplayViewController *)[self.navViewController topViewController];
   // [pDisp.tableView reloadData];
    [self.navViewController popViewControllerAnimated:NO];
    
}

-(long long) getShareId
{
    return pShrMgr.share_id;
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
    [apputil.mainVwNavCntrl popViewControllerAnimated:YES];
}


- (void) itemAddDone
{
    mapView.showsUserLocation = NO;
    [locmgr stopUpdatingLocation];
    aVw = nil;
          
    AddViewController *pAddViewCntrl = (AddViewController *)[apputil.mainVwNavCntrl popViewControllerAnimated:NO];
    struct timeval tv;
    gettimeofday(&tv, 0);
    long long sec = ((long long)tv.tv_sec)*1000000;
    long long usec =tv.tv_usec;
    AddEditDispDelegate *pAddView = (AddEditDispDelegate *)pAddViewCntrl.delegate;
    
	pAddView.pNewItem.val1 = sec + usec;
    pAddView.pNewItem.share_id = share_id;
    

    [dataSync addItem:pAddView.pNewItem];
    NSLog(@"New Item added %@\n", pAddView.pNewItem);
      selectedItem = pAddView.pNewItem;
    editItem = pAddView.pNewItem;
    
}

- (void)itemAdd
{    
  //  UIBarButtonItem *pBarItem1 = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(itemAddCancel) ];
    NSLog(@"Adding item purchase = %d COUNT = %lld", appUtl.purchased, COUNT);
    
    /*
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
     */
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
    MainViewController *pMainVwCntrl = apputil.aViewController2;
    [locmgr startUpdatingLocation];
    pSearchStr = nil;
    pMainVwCntrl.pSearchBar.text = nil;
    [pMainVwCntrl.pSearchBar resignFirstResponder];
    [pMainVwCntrl setDelegate:self];
    [pMainVwCntrl setDelegate_1:self];
    AddViewController *aViewController = [AddViewController alloc];
    
    [aViewController setPFlMgr:pFlMgr];
    [aViewController setNavViewController:self.navViewController];
    [aViewController setDelegate:[[AddEditDispDelegate alloc]init]];
    aViewController = [aViewController initWithNibName:nil bundle:nil];
    aVw = aViewController;
    mapView.showsUserLocation = YES;
    [apputil.mainVwNavCntrl pushViewController:aViewController animated:YES];
  
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
    self.appUtl.selFrndCntrl.eViewCntrlMode = eModeShareToSelected;
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
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    NSLog(@"Application did become active app state=%ld %s %d", (long)[[UIApplication sharedApplication] applicationState], __FILE__, __LINE__);
    [dataSync start];

   [pShrMgr start];
    NSLog(@"Application did become active %s %d", __FILE__, __LINE__);
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
        
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    
    NSLog(@"didReceiveRemoteNotification: Downloading items %s %d", __FILE__, __LINE__);
    NSUserDefaults* kvlocal = [NSUserDefaults standardUserDefaults];
    [kvlocal setBool:YES forKey:@"ToDownload"];
    completionHandler(UIBackgroundFetchResultNoData);
    return;
}



-(NSString* ) mainVwCntrlTitle
{
    return @"House List";
}

-(NSString* ) helpTxt
{
    return @"OpenHouses is a decision support tool to aid the home buying process. This help section shows how to use the App effectively\n\n    Create CheckLists. Click Checklists icon in the bottom tab bar to navigate to the Checklists section of the OpenHouses App.\n\n    Create a new Checklist by clicking the + button on the top right hand corner. This will create and display a blank CheckList with title List1. Start adding items to the CheckList. CheckList items are those items of interest when viewing or buying a home. A sample Checklist is as follows 1)Hardwood floors 3) Granite Countertops 3) Two car garage. 4) Patio 5)Bathroom tiles. Title can be changed from List1 to a more meaningful name. Click the Done button after adding items. Click the + button on top right hand corner to create another Checklist. Different sets of CheckLists can be created and saved.\n\n    OpenHouses app needs the following permissions. Access to location. This enables OpenHouses to autofill the home address and show the location of home on the map. Access to camera and microphone to record pictures and videos. Push notifications should be allowed for sharing houses.\n\n    On reaching a home to view navigate to Home screen by clicking the Home icon in the bottom tab bar. Click the + button on the top right corner of Home screen. This will bring the main screen view of the home. The street address will be auto populated with the Home address.\n\n    To view the Map of the house click the Map row. Standard map view will be shown. To change the Map view click the action button on the top right corner. This will show the Action sheet with the options 1)Standard. 2)Satellite. 3)Hybrid. Click on these actions items to see different map views. Click the back button (House Info) to navigate back to main Home details screen.\n\n Click the Notes row to navigate to the Notes screen. Touch the screen. This will bring up the keyboard. Takes notes. Click the back button (House Info) to navigate back to main Home details screen.\n\n Select the Check Lists row. OpenHouses app will show a screen with all the previously created Checklist titles. Select the CheckList title appropriate for this house. This will show the Checklist. For the features present in the home being viewed place green checkmarks for Checklist items by clicking the rows on the screen. Click the back button (House Info) to navigate back to main Home details screen.\n\n Select the Camera row. This will show the Camera View. Click the Camera button in the center of bottom tab bar to take pictures. To take video slide the slider to the right. The slider is located to right of the bottom tab bar. Click the blue dot to start video recording. Click the red dot to stop recording. Click the Done button on the bottom left of tab bar to exit the Camera view. Select the Pictures row to view the photos and videos. Touch a photo to show the single picture view. Swipe left and right on pictures to navigate to the next. Double tap the Picture to go to pinch to zoom mode. Click the back button to navigate back to previous screens.\n\n Enter the Price, Area, Year, Beds by touching the screen to bring up the keyboard. Click the Done button on the top right corner to save the changes.\n\n    The house details can be shared with friends. Notifications should be enabled for the app for sharing. Notifications can be enabled during intial start up or later in the Settings app.\n\n    The first step to share is to add Contacts to share the house with. Click the Contacts icon in the bottom tab bar to bring up the Contacts screen. There will be a ME line. Selecting the ME line, shows the share Id of the OpenHouses on this iPhone. This number uniquely identifies the App for sharing purposes. Now navigate back to Contacts screen by clicking the Contacts button on top left corner. Click the + button on top right corner to add a new contact. Enter the share Id and a name to identify the contact.The Share Id is the number in the ME row of your friend's OpenHouses app. \n\n    Click the Share icon in the bottom tab bar. This will bring up the Share screen. Select the House to share. Attach Pictures dialog pop up. If YES is selected the picture roll screen is shown. Select the photos to share by clicking on them. Click Done when finished or Cancel to cancel. Click the Recipients icon on the top right corner. This will bring up the Contacts screen. Select the contacts to share the item. Once the contacts are selected click the Send button. This will sent the list to the selected Contacts\n\n    Delete the house. Navigate to home screen by selecting Home icon on the bottom tab bar. Select the House to be deleted. This will bring up the home details screen. Click the Edit button on the top right corner. Scroll down to the bottom after the address details. There is a delete button. Click the button and confirm\n\n         Edit house details.  Navigate to home screen by selecting Home icon on the bottom tab bar. Select the House to be edited.  This will bring up the home details screen. Click the Edit button on the top right corner. Edit the house details as described earlier in the Add house sections. Click the Done button to save the house details. Click the Cancel button to discard edits.\n\n    Sort by option. Select the Sort by option to show the Sorting options screen. Select the row to change the sorting option. Click the brown button on the row to reverse the sorting criteria.\n\n    Search bar. This acts as a filter to limit the houses. Search based on street address, price , area etc. Checklist items are not yet included in the search."  ;
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

-(void) initVariables
{
    bFirstActive = true;
    pFlMgr = [[NSFileManager alloc] init];
    
    sortIndx = 0;
    bUpgradeAlert = false;
    unlocked = false;
    bDateAsc = true;
    bPriceAsc = true;
    bAreaAsc = true;
    bYearAsc = true;
    bBedsAsc = true;
    bRatingsAsc = true;
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
    pShrMgr.pNtwIntf.connectPort = @"16789";
     pShrMgr.pNtwIntf.port = 16803;
    appUtl.pShrMgr = pShrMgr;
    pShrMgr.delegate = self;
    pShrMgr.shrMgrDelegate = self;
    NSUserDefaults* kvlocal = [NSUserDefaults standardUserDefaults];
    [self populateOneMonth];
    kvstore = [NSUbiquitousKeyValueStore defaultStore];
    kchain = [[KeychainItemWrapper alloc] initWithIdentifier:@"LoginData" accessGroup:@"3JEQ693MKL.com.rekhaninan.sinacama"];
    apputil = [AppUtil alloc];
    apputil.delegate = self;
    [apputil setProductId:@"com.rekhaninan.openhouses_unlocked"];
     apputil = [apputil init];
    appUtl.delegate = apputil;
    apputil.pShrMgr = pShrMgr;
    apputil.appShrUtl = appUtl;
    COUNT = [kvlocal integerForKey:@"TotRows"];
    totcount = [kvlocal integerForKey:@"TotTrans"];
        
    bTokPut = [kvlocal boolForKey:@"TokInAws"];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self initVariables];
    NSLog(@"Launching openhouses");
    NSString *pHdir = NSHomeDirectory();
    
    
    tabBarController = [[UITabBarController alloc] init];
    tabBarController.delegate = self;
    
#ifdef CLEANUP
         [self cleanUpEverything];
          return YES ;
#endif
    
    NSError *error;
    dataSync = [[DataOps alloc] init];
    dataSync.appName = @"Shopper";
   
    
    apputil.dataSync = dataSync;
           
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
    MainViewController *aViewController = [MainViewController alloc];
    
    aViewController.pAllItms.bInICloudSync = false;
    aViewController.pAllItms.bInEmail = false;
    aViewController.pAllItms.bAttchmentsInit = false;
    aViewController.delegate = self;
    aViewController.delegate_1  = self;
    aViewController.bShareView = false;
    aViewController = [aViewController initWithNibName:nil bundle:nil];
    
    
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
   
    
        // Override point for customization after application launch.
    UINavigationController *navCntrl = [[UINavigationController alloc] initWithRootViewController:aViewController];
    self.navViewController = navCntrl;
      dataSync.navViewController = navCntrl;
    dataOpsDelegate = [[DataOpsDelegate alloc] init];
    dataSync.delegate = dataOpsDelegate;

    self.window.backgroundColor = [UIColor whiteColor];
    [self.window addSubview:self.navViewController.view];
    [self.window makeKeyAndVisible];
    
    appUtl.window = self.window;
   
        
     CGRect mapFrame = CGRectMake(90, 12, 200, 25);
    mapView = [[MKMapView alloc] initWithFrame:mapFrame];
    mapView.showsUserLocation = NO;
    mapView.delegate = self;
    locmgr = [[CLLocationManager alloc] init];
    locmgr.delegate = self;
    UIDevice *dev = [UIDevice currentDevice];
    sysver = [[dev systemVersion] doubleValue];
    
    
   NSLog(@"Not pausing location updates automatically\n");
        locmgr.pausesLocationUpdatesAutomatically = NO;
    
    [locmgr stopUpdatingLocation];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMainScreen:) name:@"RefetchAllDatabaseData" object:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadFetchedResults:) name:@"RefreshAllViews" object:self];
    
    if (biCloudAvail)
        NSLog (@"iCloud available\n");
    else
        NSLog (@"iCloud NOT available at this point\n");
    self.window.backgroundColor = [UIColor whiteColor];
    //[self.window addSubview:self.navViewController.view];
   // [self.window setRootViewController:self.navViewController];
    [self.window makeKeyAndVisible];
    [appUtl registerForRemoteNotifications];
    
    [apputil setWindow:self.window];
    
    [apputil initShareTabBar];
    self.navViewController = apputil.mainVwNavCntrl;
     appUtl.navViewController = self.navViewController;
    [apputil setNavViewController:self.navViewController];
    
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    
    NSUserDefaults* kvlocal = [NSUserDefaults standardUserDefaults];
    [kvlocal setBool:YES forKey:@"ToDownload"];
    
    [self setUpBackGroundTasks];
    
    return YES;
}

-(void) setUpBackGroundTasks
{
    if (@available(iOS 13.0, *)) {
        [[BGTaskScheduler sharedScheduler] registerForTaskWithIdentifier:@"com.rekhaninan.sharing" usingQueue:nil launchHandler:^(BGTask *task)
         {
            [self initVariables];
            dataSync.bBackGroundMode = true;
            pShrMgr.bBackGroundMode = true;
            [dataSync startBackGroundTask];
            [pShrMgr startBackGroundTask];
            [task setExpirationHandler:^{
                
                [pShrMgr stopBackGroundTask];
                [dataSync stopBackGroundTask];
            }];
            
        }];
    } else {
        // Fallback on earlier versions
        NSLog(@"Background tasks not supported");
    }
}

-(void) scheduleBackGroundTask
{
    if (@available(iOS 13.0, *)) {
        BGProcessingTaskRequest *bgTaskRequest = [[BGProcessingTaskRequest alloc] initWithIdentifier:@"com.rekhaninan.sharing"];
        bgTaskRequest.requiresExternalPower = false;
        bgTaskRequest.requiresNetworkConnectivity = true;
        NSError *error;
        if ([[BGTaskScheduler sharedScheduler] submitTaskRequest:bgTaskRequest error:&error] == YES)
        {
            NSLog(@"Submitted background task request");
        }
        else
        {
            NSLog(@"Failed to submit background task error=%@", error);
        }
    } else {
        // Fallback on earlier versions
        NSLog(@"Background tasks not supported");
    }
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
    dataSync.bBackGroundMode = true;
    self.navViewController.navigationBar.tintColor = nil;
    return;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    dataSync.bBackGroundMode = false;
    bInBackGround = false;
    return;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self.dataSync saveContext];
}

@end
