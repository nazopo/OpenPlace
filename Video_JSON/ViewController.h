//
//  ViewController.h
//  Video_JSON
//
//  Created by Nathan Poag on 12/1/14.
//  Copyright (c) 2014 Nathan Poag. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITextFieldDelegate,UITableViewDelegate, UITableViewDataSource>{
    

    
    
    
   
    IBOutlet UITextField *autocompleteTextField;
}
-(void)getJSONPlaceDetails:(NSString *) place_id completion:(void (^)(void))dataReceived;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UILabel *placeCell;
@property (nonatomic, retain) UITextField *autocompleteTextField;
@property (nonatomic, retain) NSMutableArray *autocompletePlaces;
@property (nonatomic, retain) NSMutableArray *pastPlaces;
@property (nonatomic, retain) NSMutableArray *placesAsProperties;
@property (nonatomic, retain) NSMutableArray *placesAsPropertiesTemp;
@property (nonatomic, retain) NSMutableArray *placeDetailsTemp;
@property (nonatomic, retain) NSMutableArray *placeDetails;
@property (nonatomic, strong) UITableView *autocompleteTableView;
@property (atomic, strong) NSMutableDictionary *posts;
@property (atomic, strong) NSMutableDictionary *rawDetails;
@property (atomic, strong) NSMutableArray *place_id_storage;




@end

