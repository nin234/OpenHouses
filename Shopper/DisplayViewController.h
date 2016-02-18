//
//  DisplayViewController.h
//  Shopper
//
//  Created by Ninan Thomas on 1/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface DisplayViewController : UITableViewController
{

//ALAssetsLibrary *assetsLibrary;
   // ALAssetsGroup *group_;
    NSMetadataQuery *query;
}

@property int nSmallest;
@property bool processQuery;

@end
