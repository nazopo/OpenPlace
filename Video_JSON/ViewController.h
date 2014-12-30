//
//  ViewController.h
//  Video_JSON
//
//  Created by Nathan Poag on 12/1/14.
//  Copyright (c) 2014 Nathan Poag. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
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
@property (nonatomic, strong) NSMutableArray *placeDetails;
@property (nonatomic, strong) UITableView *autocompleteTableView;
@property (atomic, strong) NSMutableDictionary *posts;
@property (atomic, strong) NSMutableDictionary *rawDetails;
@property (atomic, strong) NSMutableArray *place_id_storage;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UITableViewController *favorites_manager;
@property (nonatomic, strong) NSArray *paths;
@property (nonatomic, strong) NSString *documentsDirectory;
@property (nonatomic, strong) NSString *filePath;



@end

