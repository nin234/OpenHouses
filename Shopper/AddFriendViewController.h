//
//  AddFriendViewController.h
//  Shopper
//
//  Created by Ninan Thomas on 7/2/13.
//
//

#import <UIKit/UIKit.h>
#import "SelectFriendViewController.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface AddFriendViewController : UITableViewController<UITextFieldDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate, UIActionSheetDelegate>
{
    NSString *userName;
    NSString *nickName;
    bool bValidEmail;
    UIActivityIndicatorView *busyInd;
   
    bool bClickShare;
    UIBackgroundTaskIdentifier addFTaskId;
    
}

@property (nonatomic, strong) SelectFriendViewController *frndSelector;
@property bool bInDeleteFrnd;

-(void) addFriend;
+(void) storeFrndInCloud;

@end
