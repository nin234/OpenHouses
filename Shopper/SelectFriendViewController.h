//
//  SelectFriendViewController.h
//  Shopper
//
//  Created by Ninan Thomas on 7/3/13.
//
//

#import <UIKit/UIKit.h>
#import "FriendDetails.h"


@interface SelectFriendViewController : UITableViewController<UIAlertViewDelegate, UIActionSheetDelegate>
{
    NSEnumerator *itr;
    NSMutableDictionary *rownoFrndDetail;
    UIActivityIndicatorView *busyInd;
}

@property (nonatomic, strong) NSMutableDictionary *frndDic;
@property (nonatomic, retain) NSMutableArray *seletedItems;

-(bool) displayAddedFriend:(FriendDetails *) newFrnd;
-(NSArray *) getSelectedFriends;


@end
