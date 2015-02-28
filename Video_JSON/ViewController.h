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

@interface ViewController : UIViewController<UITextFieldDelegate,UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate,UIGestureRecognizerDelegate, UIWebViewDelegate>{
    

    CLLocation *_currentLocation;
    
    IBOutlet UIImageView *googlePowered;
    
   
    IBOutlet UITextField *autocompleteTextField;
}
-(void) viewDidLoad;
-(void) hideKeyboard;
-(void) dealloc;
-(void) CurrentLocationIdentifier;
- (NSUInteger) supportedInterfaceOrientations;
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error;
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;
-(void)getJSONData: (NSString *) input completion:(void (^)(void))dataReceived;
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
- (void)refresh:(id)sender;
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
-(IBAction) performUnwind: (UIStoryboardSegue *)segue;
-(void)didReceiveData;
-(void)createFavoritePlaces;
-(void)textFieldDidChange:(UITextField *)input;
- (void)didReceiveMemoryWarning;
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)didReceiveTap:(UITapGestureRecognizer *)gesture;
- (UIImage *)imageWithColor:(UIColor *)color;
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section;
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView;
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath;
-(void)getJSONPlaceDetails:(NSString *) place_id;
//-(void)getJSONPlaceDetails:(NSString *) place_id completion:(void (^)(void))dataReceived;


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
@property (nonatomic, strong) UIView *footerView;
@property (strong, nonatomic) IBOutlet UIWebView *privacyPolicy;



@end

