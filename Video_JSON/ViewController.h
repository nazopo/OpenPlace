//
//  ViewController.h
//  Video_JSON
//
//  Created by Nathan Poag on 12/1/14.
//  Copyright (c) 2014 Nathan Poag. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@interface ViewController : UIViewController<UITextFieldDelegate,UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate,UIGestureRecognizerDelegate>{
    

    CLLocation *_currentLocation;
    
    IBOutlet UIImageView *googlePowered;
    
   
    IBOutlet UITextField *autocompleteTextField;
}
-(void)getJSONPlaceDetails:(NSString *) place_id completion:(void (^)(void))dataReceived;
- (BOOL)textFieldShouldReturn:(UITextField *)textField;

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
@property (nonatomic, strong) NSUserDefaults *prefs;
@property (nonatomic, strong) NSString *currentLatitude;
@property (nonatomic, strong) NSString *currentLongitude;
@property (strong, nonatomic) IBOutlet UIImageView *googlePowered;
@property (nonatomic) NSInteger currentSection;
@property (nonatomic) BOOL finishedLoadingData;
@property (nonatomic) int cellHeight;
@property (strong, nonatomic) IBOutlet UIButton *info;



@end

