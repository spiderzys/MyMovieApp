//
//  SecondViewController.h
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2015-10-03.
//  Copyright © 2015 YANGSHENG ZOU. All rights reserved.
//


#import "ViewController.h"
#import "AppDelegate.h"


@interface SecondViewController : ViewController
@property (weak, nonatomic) IBOutlet UITableView *searchResultTableView;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet UILabel *markLabel;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;



@end

