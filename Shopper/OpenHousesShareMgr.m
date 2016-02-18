//
//  OpenHousesShareMgr.m
//  Shopper
//
//  Created by Ninan Thomas on 2/17/16.
//
//

#import "OpenHousesShareMgr.h"
#import "OpenHousesTranslator.h"
#import "OpenHousesDecoder.h"

@implementation OpenHousesShareMgr


-(void) getItems
{
    char *pMsgToSend = NULL;
    int len =0;
    pMsgToSend = [self.pTransl getItems:self.share_id msgLen:&len];
    [self putMsgInQ:pMsgToSend msgLen:len];
    return;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.pTransl = [[OpenHousesTranslator alloc] init];
        self.pDecoder = [[OpenHousesDecoder alloc] init];
    }
    return self;
}


@end
