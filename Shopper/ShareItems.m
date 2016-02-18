//
//  ShareItems.m
//  Shopper
//
//  Created by Ninan Thomas on 7/12/13.
//
//

#import "ShareItems.h"

@implementation ShareItems

@synthesize item;
@synthesize pics;
@synthesize frnds;

-(id) initWithItem:(LocalItem *)itm pictures:(NSArray *)pictures friends:(NSArray *)frnd
{
    self = [super init];
    if (self)
    {
        item = itm;
        pics = [[NSMutableArray alloc] initWithCapacity:[pictures count]];
        for (NSURL *picture in pictures)
        {
            [pics addObject:picture];
        }
        frnds = frnd;
    }
    return  self;
}

@end
