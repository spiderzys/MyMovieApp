//
//  APICommunicator.m
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2016-08-25.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

#import "APICommunicator.h"
#import "Constant.h"



@implementation APICommunicator
// request or post data from API


// make it singleton

+ (APICommunicator*)sharedInstance{
    static APICommunicator *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[APICommunicator alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}


+ (id)allocWithZone:(NSZone *)zone
{
    static APICommunicator *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [super allocWithZone:zone];
        
    });
    return sharedInstance;
}


//--------------------------------end--------------------------------------------


//-----------------------------request data--------------------------------------



- (NSData*)getPlayingMovieDataInPage:(int) page{
    // Call API for playing movies of specified page
    NSString *playingMovieUrlString = [NSString stringWithFormat:@"%@%@&sort_by=popularity.desc&language=en-US&certification_country=US&page=%d",nowPlayWeb,APIKey, page];
    NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString: playingMovieUrlString]];
    
    return data;
    
}

- (NSData*)getCastDataWithId:(NSNumber*)idn{
     NSString *castRequestUrlString = [movieWeb stringByAppendingString:[NSString stringWithFormat:@"%@/casts?%@",idn,APIKey]];
    return [NSData dataWithContentsOfURL:[NSURL URLWithString:castRequestUrlString]];
}







//-------------------------------end----------------------------------------







@end
