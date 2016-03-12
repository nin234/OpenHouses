//
//  DataOpsDelegate.m
//  Shopper
//
//  Created by Ninan Thomas on 3/9/16.
//
//

#import "DataOpsDelegate.h"
#import "AppDelegate.h"
#import "Item.h"
#import "LocalItem.h"

@implementation DataOpsDelegate


-(bool) updateEditedItem:(id) itm local:(id) litm
{
    Item *item = itm;
    LocalItem *litem = litm;
    NSArray *album_arr = [item.album_name componentsSeparatedByString:@"/"];
    NSArray *lalbum_arr = [litem.album_name componentsSeparatedByString:@"/"];
    NSUInteger alindx = [album_arr count];
    NSUInteger lalindx = [lalbum_arr count];
    if (alindx >=2)
        alindx -= 2;
    else if (alindx == 1)
        alindx -= 1;
    else
        return false;
    if (lalindx >=2)
        lalindx -= 2;
    else if (lalindx == 1)
        lalindx -= 1;
    else
        return  false;
NSString *album_name = [album_arr objectAtIndex:alindx];
NSString *lalbum_name = [lalbum_arr objectAtIndex:lalindx];
if ([album_name isEqualToString:lalbum_name])
{
    [item copyFromLocalItem:litem copyAlbumName:true];
    NSLog(@"Updated edited item %@ album_name=%@ lalbum_name=%@\n", item.name, album_name, lalbum_name);
    return true;
}
    return false;
    
}

-(NSString *) getAlbumName:(id) itm
{
    if ([itm isKindOfClass:[Item class]])
    {
        Item *item = itm;
        return item.album_name;
    }
    else
    {
        LocalItem *litem = itm;
        return litem.album_name;
    }
    return nil;
}

-(id) getNewItem:(NSEntityDescription *) entity context:(NSManagedObjectContext *) managedObjectContext
{
    Item *newItem = [[Item alloc]
     initWithEntity:entity insertIntoManagedObjectContext:managedObjectContext];
    return newItem;
}

-(void) addToCount
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [pDlg addToCount];
    return;
}

-(NSString *) getSearchStr
{
  AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return pDlg.pSearchStr;
}

-(void) copyFromLocalItem:(id) itm local:(id)litm
{
    Item *item = itm;
    LocalItem *litem = litm;
    [item copyFromLocalItem:litem copyAlbumName:true];
    return;
}

-(void) copyFromItem:(id) itm local:(id)litm
{
    Item *item = itm;
    LocalItem *litem = litm;
    [litem copyFromItem:item];
    return;
}

-(NSString *) sortDetails:(bool *)ascending
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    switch (pDlg.sortIndx)
    {
            
        case 1:
        {
            *ascending = pDlg.bPriceAsc;
            return @"price";
        }
        break;
        case 2:
        {
            *ascending = pDlg.bAreaAsc;
            return @"area";
        }
        break;
        case 3:
        {
            *ascending = pDlg.bYearAsc;
            return @"year";
           
        }
        break;
        case 4:
        {
            *ascending = pDlg.bBedsAsc;
            return @"beds";
        }
            break;
        case 5:
        {
            *ascending = pDlg.bBathsAsc;
            return @"baths";
        }
        break;
        case 0:
        {
            *ascending = pDlg.bDateAsc;
            return @"date";
        }
            break;
            
        default:
            break;
    }

    return nil;
}

-(id) getLocalItem
{
    return [[LocalItem alloc] init];
}

-(MainViewController *) getMainViewController
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return [pDlg.navViewController.viewControllers objectAtIndex:0];
}

@end
