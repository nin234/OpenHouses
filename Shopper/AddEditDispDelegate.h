//
//  AddEditDispDelegate.h
//  Shopper
//
//  Created by Ninan Thomas on 3/5/16.
//
//

#import <Foundation/Foundation.h>
#import "LocalItem.h"
#import "common/AddViewController.h"

@interface AddEditDispDelegate : NSObject<AddViewControllerDelegate>

@property (nonatomic, retain) LocalItem *pNewItem;
-(void) initializeNewItem;
-(void) setAlbumNames:(NSString *)noStr fullName:(NSString *)urlStr;
-(void) setLocation:(double) lat longitude:(double) longtde;
-(void) stopLocUpdate;
-(bool) updateAddress:(NSString *)street city:(NSString *)city state:(NSString *) state country:(NSString * )country zip:(NSString *)zip;
-(void) incrementPicCnt;
-(void) saveQAdd:(NSInvocationOperation*) theOp;

- (void) populateValues:(UITextField *)textField;
-(void) populateTextFields:(UITextField *) textField textField1:(UITextField *) textField1 row:(NSUInteger)row;
-(NSArray *) getFieldNames;
-(NSArray *) getSecondFieldNames;
-(bool) isTwoFieldRow:(NSUInteger) row;
-(CGRect) getTextFrame;
-(UILabel *) getLabel;
-(bool) isSingleFieldRow:(NSUInteger) row;
-(void) itemAddCancel;
-(void) itemAddDone;
-(NSString *) setTitle;
-(NSString *) getAlbumTitle;
-(NSString *) getNotes;
-(double) getLongitude;
-(double) getLatitude;
@end
