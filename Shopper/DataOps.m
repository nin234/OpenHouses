//
//  DataOps.m
//  Shopper
//
//  Created by Ninan Thomas on 11/17/12.
//
//

#import "DataOps.h"
#import "Item.h"
#import "AppDelegate.h"
#import <sys/stat.h>
#import "MainViewController.h"
#import "ShareItems.h"
#import "FriendDetails.h"
#import "AVFoundation/AVAssetImageGenerator.h"
#import "AVFoundation/AVAsset.h"
#import "AVFoundation/AVTime.h"
#import "AddFriendViewController.h"

@implementation DataOps
@synthesize dontRefresh;
@synthesize refreshNow;
@synthesize updateNow;
@synthesize updateNowSetDontRefresh;
@synthesize loginNow;
@synthesize shareQ;

-(void) setRefreshNow:(bool)refNow
{
    [workToDo lock];
    refreshNow = refNow;
    if (refreshNow == true)
    {
        NSLog(@"Setting refreshNow and signalling work\n");
        [workToDo signal];
    }
    [workToDo unlock];
    return;
}

-(void) setLoginNow:(bool)lgNow
{
    [workToDo lock];
    loginNow = lgNow;
    [workToDo signal];
    [workToDo unlock];

}

-(void) setDontRefresh:(bool)dontRef
{
    [workToDo lock];
    dontRefresh = dontRef;
    if (dontRefresh == false)
        [workToDo signal];
    [workToDo unlock];
    return;
}

-(void) setUpdateNow:(bool)upNow
{
    [workToDo lock];
    updateNow = upNow;
    [workToDo signal];
    [workToDo unlock];
    return;
}

-(void) setUpdateNowSetDontRefresh:(bool)upNow
{
    [workToDo lock];
    updateNowSetDontRefresh = upNow;
    [workToDo signal];
    [workToDo unlock];
    return;
}

-(void) main
{
    newItems = [[NSMutableArray alloc] init];
    workToDo = [[NSCondition alloc]init];
    dontRefresh = false;
    refreshNow = false;
    itemsToAdd = 0;
    itemsEdited = 0;
    itemsToShare = 0;
    itemsToDownload = 0;
    itemsToDownloadOnStartUp = 0;
    forceRefresh = false;
    itemsDeleted = 0;
    editedItems = [[NSMutableArray alloc] init];
    deletedItems = [[NSMutableArray alloc] init];
    itemNamesTmp = [[NSMutableArray alloc] init];
    itemNames = [[NSMutableArray alloc] init];
    sharedItems = [[NSMutableArray alloc]init];
    downloadIds = [[NSMutableArray alloc] init];
    updateNow = false;
    updateNowSetDontRefresh = false;
    bInitRefresh = true;
    bInUpload = false;
    bRedColor = false;
    waitTime = 3;
    bAnimateNow = false;
    bAnimateOnDwld = false;
    bAnimateOnStrtUp = false;
    bInStartUpDownload =false;
    bShowSelfHelp = true;
    upldBkTaskId = UIBackgroundTaskInvalid;
    dwldBkTaskId = UIBackgroundTaskInvalid;
    dwldStrtUpTaskId = UIBackgroundTaskInvalid;
    loginTaskId = UIBackgroundTaskInvalid;
    
    shareQ = dispatch_queue_create("P2P_SHAREQ", DISPATCH_QUEUE_SERIAL);
    [self refreshData];
    [self updateMainLstVwCntrl];
    for(;;)
    {
        [workToDo lock];
        if (!itemsToAdd || !itemsEdited ||!itemsDeleted || !refreshNow || dontRefresh || !updateNowSetDontRefresh || !updateNow || !loginNow)
        {
           // NSLog(@"Waiting for work\n");
            NSDate *checkTime = [NSDate dateWithTimeIntervalSinceNow:waitTime];
            [workToDo waitUntilDate:checkTime];
        }
        [workToDo unlock];
        
        
        if (dontRefresh)
        {
          //  NSLog(@"Dont refresh set to true continuing\n");
            continue;
        }
        
        if(loginNow)
        {
            NSLog(@"Attempting to login to aws\n");
            [self login];
        }
        
        if (itemsToAdd)
        {
            NSLog(@"Adding %d items\n", itemsToAdd);
            [self storeNewItems];
            [self refreshData];
            [self updateMainLstVwCntrl];

        }
        
        if (itemsEdited)
        {
            NSLog(@"Editing %d items\n", itemsEdited);
            [self updateEditedItems];
            [self refreshData];
            [self updateMainLstVwCntrl];
            
        }
        
        
        
        if(itemsDeleted)
        {
            NSLog(@"Deleted %d items\n", itemsDeleted);
            [self updateDeletedItems];
            [self refreshData];
            [self updateMainLstVwCntrl];

        }
        
        if (forceRefresh)
        {
            NSDate *now = [NSDate date];
            if ([now compare:refreshTime] == NSOrderedDescending)
            {
                forceRefresh = false;
                [self refreshData];
                NSLog(@"FORCE Refreshing main screen contents in DataOps.m\n");
                [self updateMainLstVwCntrl];
            }
        }
        
        if(refreshNow)
        {
            
              refreshNow = false;
          //  forceRefresh = true;
           //  refreshTime = [NSDate dateWithTimeIntervalSinceNow:10];
             [self refreshData];
             NSLog(@"Refreshing main screen contents in DataOps.m\n");
             [self updateMainLstVwCntrl];
        }
        
        if (updateNow)
        {
            updateNow = false;
            NSLog(@"Updating main screen contents in DataOps.m\n");
            [self updateMainLstVwCntrl];
        }
        if (updateNowSetDontRefresh)
        {
            updateNowSetDontRefresh = false;
            [self updateMainLstVwCntrl];
            dontRefresh = true;
            NSLog(@"Updating main screen contents and setting dontRefresh to true in DataOps.m\n");
            
        }
        
    }
    
    return;
}

-(void) downloadSharedItemsOnStartUp
{
   
   
    return;
}

-(void) loginAction
{
    
    return;
}

-(void) login
{
    loginNow = false;
    dispatch_async(shareQ,
    ^{
        loginTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:
        ^{
                [[UIApplication sharedApplication] endBackgroundTask:loginTaskId];
                loginTaskId = UIBackgroundTaskInvalid;
        }];
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        pDlg.beingLoggedIn = true;
        [self loginAction];
        pDlg.beingLoggedIn = false;
        [[UIApplication sharedApplication] endBackgroundTask:loginTaskId];
        loginTaskId = UIBackgroundTaskInvalid;
        if (loginTaskId == UIBackgroundTaskInvalid)
        {
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        }
        
        
                       
      });

    
    return;
}

-(void) addItem:(LocalItem*)item
{
    [workToDo lock];
    [newItems addObject:item];
    ++itemsToAdd;
    NSLog(@"Added  new item %@ %d and signalling work to do\n", item.name, itemsToAdd);
    [workToDo signal];
    [workToDo unlock];
    return;
}

-(void) editedItem:(LocalItem*)item
{
    [workToDo lock];
    [editedItems addObject:item];
    ++itemsEdited;
    NSLog(@"Added edit item %@ %d and signalling work to do\n", item.name, itemsEdited);
    [workToDo signal];
    [workToDo unlock];
    return;
}

-(void) cleanUp: (int) indx
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
     MainViewController *pMainVwCntrl = [pDlg.navViewController.viewControllers objectAtIndex:0];
    [workToDo lock];
    [pMainVwCntrl.pAllItms cleanUp:indx];
    [workToDo unlock];
}

-(void) deletedItem:(LocalItem*)item
{
    [workToDo lock];
    [deletedItems addObject:item];
    ++itemsDeleted;
    NSLog(@"Added deleted item %@ %d and signalling work to do\n", item.name, itemsDeleted);
    [workToDo signal];
    [workToDo unlock];
    return;
}

-(void) updateDeletedItems
{
    [workToDo lock];
    NSArray *deletedItemsTmp = [NSArray arrayWithArray:deletedItems];
    [workToDo unlock];
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSUInteger cnt = [itemNamesTmp count];
    NSUInteger ecnt = [deletedItemsTmp count];
    for (NSUInteger j=0; j < ecnt; ++j)
    {
        LocalItem *litem = [deletedItemsTmp objectAtIndex:j];
        for (NSUInteger i=0; i < cnt; ++i)
        {
            Item *item = [itemNamesTmp objectAtIndex:i];
            if ([item.album_name isEqualToString:litem.album_name])
            {
                [pDlg.managedObjectContext deleteObject:item];
                break;
            }
        }
    }
    
    [workToDo lock];
    if(itemsDeleted > ecnt)
    {
        NSRange aR;
        aR.location = 0;
        aR.length = ecnt;
        [deletedItems removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:aR]];
        
    }
    else
    {
        [deletedItems removeAllObjects];
    }
    itemsDeleted -= ecnt;
    [workToDo unlock];
    
    [pDlg saveContext];
    return;
}

-(void) shareItem:(LocalItem*) item pictures:(NSArray *)pics friends:(NSArray *)frnds
{
    [workToDo lock];
    ShareItems *sharedItem = [[ShareItems alloc]initWithItem:item pictures:pics friends:frnds];
    [sharedItems addObject:sharedItem];
    ++itemsToShare;
    NSLog(@"Added  new item to share %@ %d and signalling work to do\n", item.name, itemsToShare);
    [workToDo signal];
    [workToDo unlock];
    
    return;
}

-(void) downloadItemsOnStartUp
{
    [workToDo lock];
    ++itemsToDownloadOnStartUp;
    NSLog(@"There are new items to download at start up \n");
    [workToDo signal];
    [workToDo unlock];
    return;
 
}

-(void) downloadItem:(NSString *)item
{
    [workToDo lock];
    [downloadIds addObject:item];
    ++itemsToDownload;
    NSLog(@"Added new item to download %@ and signalling work to do \n", item);
    [workToDo signal];
    [workToDo unlock];
    return;
}

-(void) updateEditedItems
{
    [workToDo lock];
    NSArray *editedItemsTmp = [NSArray arrayWithArray:editedItems];
    [workToDo unlock];
    NSUInteger cnt = [itemNamesTmp count];
    NSUInteger ecnt = [editedItemsTmp count];
    for (NSUInteger j=0; j < ecnt; ++j)
    {
        LocalItem *litem = [editedItemsTmp objectAtIndex:j];
        for (NSUInteger i=0; i < cnt; ++i)
        {
            Item *item = [itemNamesTmp objectAtIndex:i];
            NSArray *album_arr = [item.album_name componentsSeparatedByString:@"/"];
            NSArray *lalbum_arr = [litem.album_name componentsSeparatedByString:@"/"];
            NSUInteger alindx = [album_arr count];
            NSUInteger lalindx = [lalbum_arr count];
                if (alindx >=2)
                    alindx -= 2;
                else if (alindx == 1)
                    alindx -= 1;
                else
                    continue;
                if (lalindx >=2)
                    lalindx -= 2;
                else if (lalindx == 1)
                    lalindx -= 1;
                else
                    continue;
                NSString *album_name = [album_arr objectAtIndex:alindx];
                NSString *lalbum_name = [lalbum_arr objectAtIndex:lalindx];
                if ([album_name isEqualToString:lalbum_name])
                {
                    [item copyFromLocalItem:litem copyAlbumName:true];
                    NSLog(@"Updated edited item %@ album_name=%@ lalbum_name=%@\n", item.name, album_name, lalbum_name);
                    break;
                }
        }
    }
    
    [workToDo lock];
    if(itemsEdited > ecnt)
    {
        NSRange aR;
        aR.location = 0;
        aR.length = ecnt;
        [editedItems removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:aR]];
   
    }
    else
    {
        [editedItems removeAllObjects];
    }
    itemsEdited -= ecnt;
    [workToDo unlock];
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [pDlg saveContext];
    return;
}

-(bool) updateItemIfFound:(LocalItem *)litem albumName:(NSString **)lalbum_name
{
	NSArray *lalbum_arr = [litem.album_name componentsSeparatedByString:@"/"];
	NSUInteger lalindx = [lalbum_arr count];
    *lalbum_name =nil;
	if (lalindx >=2)
    {
        lalindx -= 2;
    }
	else if (lalindx == 1)
    {
        lalindx -= 1;
    }
	else
	{
	    return false;
	}
	
    NSString* lalbum_lastpath = [lalbum_arr objectAtIndex:lalindx];
	NSUInteger icnt = [itemNamesTmp count];
	for (NSUInteger i=0; i < icnt; ++i)
	{
	    Item *item = [itemNamesTmp objectAtIndex:i];
	    NSArray *album_arr = [item.album_name componentsSeparatedByString:@"/"];
	    
	    NSUInteger alindx = [album_arr count];
	    if (alindx >=2)
		alindx -= 2;
	    else if (alindx == 1)
		alindx -= 1;
	    else
		continue;
	    
	    NSString *album_name = [album_arr objectAtIndex:alindx];
	    
	    if ([album_name isEqualToString:lalbum_lastpath])
	    {
            [item copyFromLocalItem:litem copyAlbumName:false];
            NSLog(@"Updated downloaded item %@ album_name=%@ lalbum_name=%@\n", item.name, album_name, lalbum_lastpath);
            *lalbum_name = item.album_name;
            return true;
	    }
	}
    return false;
}

-(void) saveThumbImage:(NSURL *)pFlUrl :(NSURL *) thumburl :(NSString *)picName
{
    NSArray *picNameArr = [picName componentsSeparatedByString:@"."];
    
    UIImage *image;
    if ([[picNameArr objectAtIndex:1] isEqualToString:@"jpg" ])
    {
        image = [UIImage imageWithData:[NSData dataWithContentsOfURL:pFlUrl]];
    }
    else
    {
        AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:[AVAsset assetWithURL:pFlUrl]];
        
        
        
        CMTime thumbTime = CMTimeMakeWithSeconds(0.0, 600);
        NSError *error = nil;
        CMTime actualTime;
        
        CGImageRef startImage = [generator copyCGImageAtTime:thumbTime actualTime:&actualTime error:&error];
        image = [UIImage imageWithCGImage:startImage];
        
        
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
    NSString *thumbPicName = [NSString stringWithFormat:@"%@.jpg", [picNameArr objectAtIndex:0]];
    NSURL *pThFlUrl = [thumburl URLByAppendingPathComponent:thumbPicName isDirectory:NO];
    if ([thumbnaildata writeToURL:pThFlUrl atomically:YES] == NO)
    {
        //printf("Failed to write to thumbnail file %d\n", filno);
        // --nAlNo;
        NSLog(@"Failed to save thumbnail file %@ thumburl = %@ picName = %@\n", pThFlUrl, thumburl, thumbPicName);
        
    }
    else
    {
        NSLog(@"Save thumbnail file %@ thumburl = %@ picName = %@\n", pThFlUrl, thumburl, picName);
    }
    
    

    return;
}

-(void) createURLIfNeeded :(NSURL **)albumurl :(NSURL **)thumburl :(LocalItem*)litem
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    *albumurl = [NSURL URLWithString:litem.album_name];
    NSError *err;
    if (*albumurl != nil && [*albumurl checkResourceIsReachableAndReturnError:&err])
    {
        *thumburl = [*albumurl URLByAppendingPathComponent:@"thumbnails" isDirectory:YES];
    }
    else
    {
        
        *albumurl = [pDlg.cloudDocsURL URLByAppendingPathComponent:@"albums" isDirectory:YES];
        *albumurl = [*albumurl URLByAppendingPathComponent:litem.album_name isDirectory:YES];
        *thumburl = [*albumurl URLByAppendingPathComponent:@"thumbnails" isDirectory:YES];
    }

    return;
}

-(NSString *) createFrndLst:(NSArray *)names
{
    NSString *frndLst = @"=";
    NSUInteger frndcnt = [names count];
    NSUInteger k =0;
    for (NSString *name in names)
    {
        if (k == (frndcnt-1))
        {
            frndLst = [frndLst stringByAppendingFormat:@"%@;",name];
        }
        else
        {
            frndLst = [frndLst stringByAppendingFormat:@"%@:",name];
        }
        ++k;
    }
    return frndLst;
}

-(NSArray *) createFrndNamesArr:(ShareItems *)updItem
{
    NSMutableArray *frndNames = [[NSMutableArray alloc] initWithCapacity:[updItem.frnds count]];
    for (FriendDetails *frnd in updItem.frnds)
    {
        [frndNames addObject:frnd.name];
    }
    return frndNames;
}



-(void) animateNavBar
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (bAnimateNow || bAnimateOnDwld ||bAnimateOnStrtUp)
    {
        waitTime = 1;
        if (bShowSelfHelp)
        {
            bShowSelfHelp = false;
            NSUserDefaults* kvlocal = [NSUserDefaults standardUserDefaults];
            int COUNT = [kvlocal integerForKey:@"SelfHelp"];
            ++COUNT;
            if (COUNT < 3)
            {
                NSLog(@"Self help count %d", COUNT);
                [kvlocal setInteger:COUNT forKey:@"SelfHelp"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    UIAlertView *pAvw = [[UIAlertView alloc] initWithTitle:@"Share Started" message:@"Flashing red color indicates house details are shared in the background" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [pAvw show];
                });
            }
        }
        dispatch_async(dispatch_get_main_queue(),
        ^{
            [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:
            ^{
                    if (!bRedColor)
                    {
                        pDlg.navViewController.navigationBar.tintColor = [UIColor redColor];
                        bRedColor = true;
                    }
                    else
                    {
                        pDlg.navViewController.navigationBar.tintColor = nil;
                        bRedColor = false;
                                    
                    }
            }
            completion:nil];
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(),
        ^{
                           [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:
                            ^{
                                pDlg.navViewController.navigationBar.tintColor = nil;
                            }
                                            completion:nil];
        });
        waitTime = 3;
   
    }
    return;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    return;
}

-(void) storeNewItems
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    int nItems = itemsToAdd;
    NSMutableArray *storeItems = [[NSMutableArray alloc] initWithCapacity:nItems];
    for (int i=0 ; i < nItems; ++i)
    {
        NSManagedObjectModel *managedObjectModel =
        [[pDlg.managedObjectContext persistentStoreCoordinator] managedObjectModel];
        NSDictionary *ent = [managedObjectModel entitiesByName];
        printf("entity count %d\n", [[ent allKeys] count]);
        NSEntityDescription *entity =
        [ent objectForKey:@"Item"];
        Item *newItem = [[Item alloc]
        initWithEntity:entity insertIntoManagedObjectContext:pDlg.managedObjectContext];
        [storeItems addObject:newItem];
        
    }
    
    [workToDo lock];
    
    for (NSUInteger i=0; i < nItems; ++i)
    {
        [[storeItems objectAtIndex:i] copyFromLocalItem:[newItems objectAtIndex:i] copyAlbumName:true];
    }
    if (itemsToAdd > nItems)
    {
        NSRange aR;
        aR.location = 0;
        aR.length = nItems;
        [newItems removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:aR]];
    }
    else
    {
        [newItems removeAllObjects];
    }
    itemsToAdd -= nItems;
    [workToDo unlock];
    [pDlg saveContext];
    
    [pDlg addToCount];

    return;
}

-(void) refreshData
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = pDlg.managedObjectContext;
    NSEntityDescription *descr = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:moc];
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:descr];
    if (pDlg.pSearchStr != nil && [pDlg.pSearchStr length])
    {
        NSArray *searchComps = [pDlg.pSearchStr componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSUInteger cnt = [searchComps count];
        NSMutableArray *srchStrs = [NSMutableArray arrayWithCapacity:cnt];
        for (NSUInteger i=0; i < cnt; i++)
        {
            NSString *srchStr = [searchComps objectAtIndex:i];
            if ([srchStr length] == 0)
                continue;
            [srchStrs addObject:srchStr];
        }
        NSString *predStr;
        NSUInteger scnt = [srchStrs count];
        for (NSUInteger i=0; i < scnt; ++i)
        {
            if (i ==0)
                predStr = @"(name contains [cd] %@";
            else
                predStr = [predStr stringByAppendingString:@"name contains [cd] %@"];
            if (i != scnt -1)
                predStr = [predStr stringByAppendingString:@" AND "];
            else
                predStr = [predStr stringByAppendingString:@" )"];
            
        }
        
        predStr = [predStr stringByAppendingString:@" OR "];
        for (NSUInteger i=0; i < scnt; ++i)
        {
            if (i == 0)
                predStr = [predStr stringByAppendingString:@"(street contains [cd] %@"];
            else
                predStr = [predStr stringByAppendingString:@"street contains [cd] %@"];
            
            if (i != scnt -1)
                predStr = [predStr stringByAppendingString:@" AND "];
            else
                predStr = [predStr stringByAppendingString:@" )"];
            
        }
        
        predStr = [predStr stringByAppendingString:@" OR "];
        for (NSUInteger i=0; i < scnt; ++i)
        {
            if (i == 0)
                predStr = [predStr stringByAppendingString:@"(notes contains [cd] %@"];
            else
                predStr = [predStr stringByAppendingString:@"notes contains [cd] %@"];
            if (i != scnt -1)
                predStr = [predStr stringByAppendingString:@" AND "];
            else
                predStr = [predStr stringByAppendingString:@" )"];
            
        }
        
        NSMutableArray *predArr = [NSMutableArray arrayWithCapacity:scnt*3];
        for (int i=0; i < 3; ++i)
        {
            [predArr addObjectsFromArray:srchStrs];
        }
        
        NSLog(@"Predicate string %@\n", predStr);
        NSLog (@"Predicate array ");
        NSUInteger pcnt = [predArr count];
        for (NSUInteger i=0 ; i < pcnt; ++i)
        {
            NSLog(@"%@ " , [predArr objectAtIndex:i]);
        }
        //NSLog (@"\n ");
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predStr argumentArray:predArr];
        
        //    NSPredicate *predicate = [NSPredicate
        //      predicateWithFormat:@"(name contains[cd] %@) OR street contains[cd] %@",
        //  [pDlg.pSearchStr stringByAppendingString:@"*"]];
        //     pDlg.pSearchStr, pDlg.pSearchStr];
        [req setPredicate:predicate];
        NSLog(@"Setting predicate %@ \n", predicate);
    }
    
    NSError *error = nil;
    switch (pDlg.sortIndx)
    {
            
        case 1:
        {
            NSSortDescriptor* ageDescriptor = [[NSSortDescriptor alloc] initWithKey:@"price"
                                                                          ascending:pDlg.bPriceAsc?YES:NO];
            NSArray* sortDescriptors = [NSArray arrayWithObject:ageDescriptor];
            itemNamesTmp = [[moc executeFetchRequest:req error:&error]sortedArrayUsingDescriptors:sortDescriptors];
        }
            break;
        case 2:
        {
            NSSortDescriptor* ageDescriptor = [[NSSortDescriptor alloc] initWithKey:@"area"
                                                                          ascending:pDlg.bAreaAsc?YES:NO];
            NSArray* sortDescriptors = [NSArray arrayWithObject:ageDescriptor];
            itemNamesTmp = [[moc executeFetchRequest:req error:&error]sortedArrayUsingDescriptors:sortDescriptors];
        }
            break;
        case 3:
        {
            NSSortDescriptor* ageDescriptor = [[NSSortDescriptor alloc] initWithKey:@"year"
                                                                          ascending:pDlg.bYearAsc?YES:NO];
            NSArray* sortDescriptors = [NSArray arrayWithObject:ageDescriptor];
            itemNamesTmp = [[moc executeFetchRequest:req error:&error]sortedArrayUsingDescriptors:sortDescriptors];
        }
            break;
        case 4:
        {
            NSSortDescriptor* ageDescriptor = [[NSSortDescriptor alloc] initWithKey:@"beds"
                                                                          ascending:pDlg.bBedsAsc?YES:NO];
            NSArray* sortDescriptors = [NSArray arrayWithObject:ageDescriptor];
            itemNamesTmp = [[moc executeFetchRequest:req error:&error]sortedArrayUsingDescriptors:sortDescriptors];
        }
            break;
        case 5:
        {
            NSSortDescriptor* ageDescriptor = [[NSSortDescriptor alloc] initWithKey:@"baths"
                                                                          ascending:pDlg.bBathsAsc?YES:NO];
            NSArray* sortDescriptors = [NSArray arrayWithObject:ageDescriptor];
            itemNamesTmp = [[moc executeFetchRequest:req error:&error]sortedArrayUsingDescriptors:sortDescriptors];
        }
            break;
            
            
        case 0:
        {
            if (pDlg.bDateAsc)
                itemNamesTmp = [moc executeFetchRequest:req error:&error];
            else
                itemNamesTmp = [[[moc executeFetchRequest:req error:&error] reverseObjectEnumerator] allObjects];
        }
            break;
            
        default:
            break;
    }
    
    if (itemNamesTmp == nil)
    {
        return;
    }
    //Fetch predicate add
    // nRows = [itemNames count];
    
    //seletedItems = [NSMutableArray arrayWithCapacity:nRows];
    int nItems = [itemNamesTmp count];
    NSLog(@"Main list counts %d %d\n", nItems, [itemNamesTmp count]);
    indexesTmp = [[NSMutableArray alloc] initWithCapacity:nItems];
    seletedItemsTmp = [[NSMutableArray alloc] initWithCapacity:nItems];
    for (int i=0 ; i < nItems; ++i)
    {
        Item* item = [itemNamesTmp objectAtIndex:i];
        bool add = false;
        struct stat sb;
        NSLog(@"iCloudSync=%d %@ %@ %@\n", item.icloudsync, item.name, item.album_name, [[NSURL URLWithString:item.album_name] path]);
        if (item.icloudsync == YES)
            add = true;
        else if (stat([[[NSURL URLWithString:item.album_name] path] UTF8String], &sb) == 0)
        {
            if ((sb.st_mode &S_IFMT) == S_IFDIR)
                add = true;
            
        }
        
        //need to revisit this
        add = true;
        
        if (add)
        {
            [seletedItemsTmp addObject:[NSNumber numberWithBool:NO]];
            [indexesTmp addObject:[NSNumber numberWithInt:i]];
        }
    }
    // nRows = [indexes count] + 1;
    NSLog(@"UPDATED Main list row count %d %d\n", [itemNamesTmp count], [indexesTmp count]);
    //Temp created so that there is no need to lock for the entire duration of refreshData
    [workToDo lock];
    seletedItems = [NSMutableArray arrayWithArray:seletedItemsTmp];
    indexes = [NSArray arrayWithArray:indexesTmp];
    [itemNames removeAllObjects];
    NSUInteger noOfNames = [itemNamesTmp count];
    for (NSUInteger i =0; i < noOfNames; ++i)
    {
        LocalItem *litem = [[LocalItem alloc] init];
        [litem copyFromItem:[itemNamesTmp objectAtIndex:i]];
        [itemNames addObject:litem];
    }
    [workToDo unlock];
    return;
}

-(void) updateMainLstVwCntrl
{
    if (dontRefresh)
    {
        NSLog(@"Dont refresh set to true, not updating mainlstvwcntrl\n");
        return;
    }
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    MainViewController *pMainVwCntrl = [pDlg.navViewController.viewControllers objectAtIndex:0];
    
    [workToDo lock];
    pMainVwCntrl.pAllItms.itemNames = [NSMutableArray arrayWithArray:itemNames];
    pMainVwCntrl.pAllItms.indexes = [NSMutableArray arrayWithArray:indexes];
    pMainVwCntrl.pAllItms.seletedItems = [NSMutableArray arrayWithArray:seletedItems];
    [workToDo unlock];
    NSLog(@"Refreshing main row itemNames = %d indexes = %d seletedItems = %d\n", [itemNames count], [indexes count], [seletedItems count]);
    
   // 
   // [pMainVwCntrl.pAllItms.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationLeft];
    dispatch_sync(dispatch_get_main_queue(), ^{
         [pMainVwCntrl.pAllItms.tableView reloadData];  
    });
        return;
}

-(void) lock
{
    [workToDo lock];
    return;
}

-(void) unlock
{
    [workToDo unlock];
    return;
}

@end
