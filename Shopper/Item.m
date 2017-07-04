//
//  Item.m
//  Shopper
//
//  Created by Ninan Thomas on 12/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Item.h"
#import "LocalItem.h"
#include <sys/time.h>

@implementation Item

@dynamic name;
@dynamic album_name;
@dynamic notes;
@dynamic price;
@dynamic pic_cnt;
@dynamic street;
@dynamic city;
@dynamic state;
@dynamic zip;
@dynamic country;
@dynamic longitude;
@dynamic latitude;
@dynamic area;
@dynamic beds;
@dynamic baths;
@dynamic year;
@dynamic icloudsync;
@dynamic val1;
@dynamic val2;
@dynamic str1;
@dynamic str2;
@dynamic str3;
@dynamic share_id;


-(void) copyFromLocalItem:(LocalItem *)item copyAlbumName:(bool)bCopy
{
    self.name = item.name;
    if (bCopy)
    {
        self.album_name = item.album_name;
    }
	self.notes = item.notes;
    //NSLog(@"Notes set to %@ for house %@", self.notes, self.name);
	self.price = item.price;
	self.pic_cnt = item.pic_cnt;
	self.street = item.street;
	self.city = item.city;
	self.state = item.state;
	self.zip = item.zip;
	self.country = item.country;
	self.longitude = item.longitude;
	self.latitude = item.latitude;
	self.area = item.area;
	self.beds = item.beds;
	self.baths = item.baths;
	self.year = item.year;
	self.icloudsync = item.icloudsync;
    //val1 is the last modify time
	self.val1 = item.val1;
	self.val2 = item.val2;
	self.str1 = item.str1;
	self.str2 = item.str2;
	self.str3 = item.str3;
    self.share_id = item.share_id;
    return;
}

-(void) updateItem:(LocalItem*)item
{
    self.str1 = item.str1;
    self.val1 = item.val1;
}

@end
