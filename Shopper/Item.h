//
//  Item.h
//  Shopper
//
//  Created by Ninan Thomas on 12/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LocalItem;

@interface Item : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * album_name;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSNumber * area;
@property (nonatomic, retain) NSNumber * beds;
@property (nonatomic, retain) NSNumber * baths;
@property (nonatomic, retain) NSString *street;
@property (nonatomic, retain) NSString *city;
@property (nonatomic, retain) NSString *state;
@property (nonatomic, retain) NSString *zip;
@property (nonatomic, retain) NSString *country;
@property int pic_cnt;
@property int year;
@property BOOL icloudsync;
@property double longitude;
@property double latitude;
@property double val1;
@property double val2;
@property (nonatomic, retain) NSString *str1;
@property (nonatomic, retain) NSString *str2; // stores the ratings value
@property (nonatomic, retain) NSString *str3;
@property (nonatomic) long long share_id;

-(void) copyFromLocalItem:(LocalItem *)item copyAlbumName:(bool) bCopy;
-(void) updateItem:(LocalItem*)item;

@end
