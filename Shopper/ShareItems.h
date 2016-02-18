//
//  ShareItems.h
//  Shopper
//
//  Created by Ninan Thomas on 7/12/13.
//
//

#import <Foundation/Foundation.h>
#import "LocalItem.h"

//-(void) shareItem:(LocalItem*) item pictures:(NSArray *)pics friends:(NSArray *)frnds
@interface ShareItems : NSObject

-(id) initWithItem:(LocalItem *)itm pictures:(NSArray *)pictures friends:(NSArray *)frnd;


@property(nonatomic, strong) LocalItem *item;
@property(nonatomic, strong) NSArray *frnds;
@property(nonatomic, strong) NSMutableArray *pics;

@end
