//
//  OpenHousesTranslator.m
//  Shopper
//
//  Created by Rekha Thomas on 2/6/16.
//
//

#import "OpenHousesTranslator.h"
#include "Constants.h"

@implementation OpenHousesTranslator

-(char *) getItems:(long long)shareId msgLen:(int *)len
{
    return [self getItems:shareId msgLen:len msgId:GET_OPENHOUSES_ITEMS];
}


@end
