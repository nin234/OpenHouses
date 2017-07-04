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
#import "common/EditViewController.h"
#import "common/DisplayViewController.h"

@interface AddEditDispDelegate : NSObject<AddViewControllerDelegate, EditViewControllerDelegate, DisplayViewControllerDelegate>

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
-(NSArray *) getFieldDispNames;
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
-(NSString *) getName;
-(double) getLongitude;
-(double) getLatitude;
-(double) getEditLongitude;
-(double) getEditLatitude;
-(NSString *) getEditName;
-(NSUInteger) getEditItemShareId;
-(bool) ratingsTag:(NSInteger) tag;

-(void) itemEditCancel;
-(void) itemEditDone;
-(void) itemEdit;
-(void) incrementEditPicCnt;
-(void) setEditAlbumNames:(NSString *)noStr fullName:(NSString *)urlStr;
-(void) deleteEditItem;
- (void) populateEditValues:(UITextField *)textField;
-(void) populateEditTextFields:(UITextField *) textField textField1:(UITextField *) textField1 row:(NSUInteger)row;
-(NSString *) deleteButtonTitle;
-(NSString *) getEditItemTitle;
-(double) getDispLatitude;
-(double) getDispLongitude;
-(NSString *) getDispName;
-(NSString *) getEditNotes;
-(bool) changeCharacters:(NSInteger) tag;
-(bool) rangeFourTag:(NSInteger) tag;
-(void) populateDispTextFields:(UILabel *) textField textField1:(UILabel *) textField1 row:(NSUInteger)row;
-(bool) isSingleFieldDispRow:(NSUInteger) row;
-(bool) numbersTag:(NSInteger) tag;
-(NSString *) getDispItemTitle;
-(NSString *) getDispNotes;
- (BOOL)characterChk:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
-(void ) setAddNotes:(NSString *)notes;
-(void) setEditNotes: (NSString *)notes;
-(NSUInteger) getShareId;


@end
