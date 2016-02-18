//
//  LocalItem.m
//  Shopper
//
//  Created by Ninan Thomas on 11/17/12.
//
//

#import "LocalItem.h"
#import "Item.h"
#import "Constants.h"


@implementation LocalItem
@synthesize name;
@synthesize album_name;
@synthesize notes;
@synthesize price;
@synthesize pic_cnt;
@synthesize street;
@synthesize city;
@synthesize state;
@synthesize zip;
@synthesize country;
@synthesize longitude;
@synthesize latitude;
@synthesize area;
@synthesize beds;
@synthesize baths;
@synthesize year;
@synthesize icloudsync;
@synthesize val1;
@synthesize val2;
@synthesize str1;
@synthesize str2;
@synthesize str3;

-(id) init
{
    self = [super init];
    if (self != nil)
    {
        icloudsync = NO;
        val1 = 0.0;
        val2 = 0.0;
    }
    return self;
}

-(id) initWithItem:(Item *)item
{
    self = [super init];
    if (self != nil)
    {
        [self copyFromItem:item];
    }
    return self;
}

-(id) copyFromItem:(Item *)item
{
    self.name = item.name;
	self.album_name = item.album_name;
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
	self.val1 = item.val1;
	self.val2 = item.val2;
	self.str1 = item.str1;
	self.str2 = item.str2;
	self.str3 = item.str3;

    return self;
}

-(void) updateItem:(SimpleDBGetAttributesResponse *)resp
{
    for (SimpleDBAttribute *attr in resp.attributes)
    {
        if ([attr.name isEqualToString:@"Val1"])
        {
            val1 = [attr.value doubleValue];
        }
        else if ([attr.name isEqualToString:@"Str1"])
        {
            str1 = attr.value;
        }
    }
    return;
}

-(id) initWithDownloadedItem:(SimpleDBGetAttributesResponse *)resp
{
    self = [super init];
    if (self != nil)
    {
        icloudsync = NO;
    NSMutableDictionary *itemsDic = [[NSMutableDictionary alloc] initWithCapacity:[resp.attributes count]];
    for (SimpleDBAttribute *attr in resp.attributes)
    {
        [itemsDic setObject:attr forKey:attr.name];
    }
    SimpleDBAttribute *attr;
     attr   = [itemsDic objectForKey:@"Name"];
    if (attr != nil)
    {
        name = attr.value;
    }
    attr   = [itemsDic objectForKey:@"AlbumName"];
    if (attr != nil)
    {
        album_name = attr.value;
    }
    attr   = [itemsDic objectForKey:@"Notes"];
    if (attr != nil)
    {
        notes = attr.value;
    }
    attr   = [itemsDic objectForKey:@"Price"];
    if (attr != nil)
    {
        price = [NSNumber numberWithDouble:[attr.value doubleValue]];
    }
    else
    {
        price = [NSNumber numberWithDouble:-2.0];
    }
    attr   = [itemsDic objectForKey:@"Area"];
    if (attr != nil)
    {
        area = [NSNumber numberWithDouble:[attr.value doubleValue]];
    }
    else
    {
        area = [NSNumber numberWithDouble:-2.0];
    }
    attr   = [itemsDic objectForKey:@"Beds"];
    if (attr != nil)
    {
        beds = [NSNumber numberWithDouble:[attr.value doubleValue]];
    }
    else
    {
        beds = [NSNumber numberWithDouble:-2.0];
    }
    attr   = [itemsDic objectForKey:@"Baths"];
    if (attr != nil)
    {
        baths = [NSNumber numberWithDouble:[attr.value doubleValue]];
    }
    else
    {
        baths = [NSNumber numberWithDouble:-2.0];
    }
    attr   = [itemsDic objectForKey:@"Street"];
    if (attr != nil)
    {
        street = attr.value;
    }
    attr   = [itemsDic objectForKey:@"City"];
    if (attr != nil)
    {
        city = attr.value;
    }
    attr   = [itemsDic objectForKey:@"State"];
    if (attr != nil)
    {
        state = attr.value;
    }
    attr   = [itemsDic objectForKey:@"Zip"];
    if (attr != nil)
    {
        zip = attr.value;
    }
    attr   = [itemsDic objectForKey:@"Country"];
    if (attr != nil)
    {
        country = attr.value;
    }
   // attr   = [itemsDic objectForKey:@"PicCnt"];
        //pic_cnt is set to zero here and updated with the actual number of pictures downloaded
        pic_cnt = 0;
    attr   = [itemsDic objectForKey:@"Year"];
    if (attr != nil)
    {
        year = [attr.value intValue];
    }
    else
    {
        year = 3000;
    }
    attr   = [itemsDic objectForKey:@"Longitude"];
    if (attr != nil)
    {
        longitude = [attr.value doubleValue];
    }
    attr   = [itemsDic objectForKey:@"Latitude"];
    if (attr != nil)
    {
        latitude = [attr.value doubleValue];
    }
    attr   = [itemsDic objectForKey:@"Val1"];
    if (attr != nil)
    {
        val1 = [attr.value doubleValue];
    }
    else
    {
        val1 = 0.0;
    }
    attr   = [itemsDic objectForKey:@"Val2"];
    if (attr != nil)
    {
        val2 = [attr.value doubleValue];
    }
    else
    {
        val2 = 0.0;
    }
    attr   = [itemsDic objectForKey:@"Str1"];
    if (attr != nil)
    {
        str1 = attr.value;
    }
    attr   = [itemsDic objectForKey:@"Str2"];
    if (attr != nil)
    {
        str2 = attr.value;
    }
    attr   = [itemsDic objectForKey:@"Str3"];
    if (attr != nil)
    {
        str3 = attr.value;
    }
    }
    return self;
}

-(NSString *) getItemKeyLastEl
{
	NSArray *lalbum_arr = [album_name componentsSeparatedByString:@"/"];
	NSUInteger lalindx = [lalbum_arr count];
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
	    return nil;
	}
	
    NSString* lalbum_lastpath = [lalbum_arr objectAtIndex:lalindx];
    return lalbum_lastpath;
}

@end
