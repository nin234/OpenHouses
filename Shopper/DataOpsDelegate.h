//
//  DataOpsDelegate.h
//  Shopper
//
//  Created by Ninan Thomas on 3/9/16.
//
//

#import <Foundation/Foundation.h>
#import "common/DataOps.h"

@interface DataOpsDelegate : NSObject<DataOpsDelegate>

-(bool) updateEditedItem:(id) item local:(id) litem;
-(NSString *) getAlbumName:(id) item;
-(id) getNewItem:(NSEntityDescription *) entity context:(NSManagedObjectContext *) managedObjectContext;
-(void) addToCount;
-(void) copyFromLocalItem:(id) item local:(id)litem;
-(NSString *) getSearchStr;
-(NSString *) sortDetails:(bool *)ascending;
-(id) getLocalItem;
-(void) copyFromItem:(id) itm local:(id)litm;
-(MainViewController *) getMainViewController;
@end
