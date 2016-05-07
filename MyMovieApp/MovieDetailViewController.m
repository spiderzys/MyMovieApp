//
//  CustomViewController.m
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2016-04-05.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

#import "MovieDetailViewController.h"
#import "MovieBackdropCollectionViewCell.h"
#import "MovieMediaViewController.h"
#import "AppDelegate.h"
static NSDictionary *movie;
@interface MovieDetailViewController ()

@end

@implementation MovieDetailViewController

//------------------------------------login for rating-------------------------------

-(void)signIn{
    LoginAlertController *alertController = [LoginAlertController alertControllerWithTitle:@"Registration and sign-in for TMDB is needed" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    
    alertController.delegate = self;
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
    
    
}

- (void)didDismissAlertControllerButtonTapped:(NSInteger)buttonTapped{
    AppDelegate *delegate = [[UIApplication sharedApplication]delegate];
    if(buttonTapped==cancel){
    }
    else if(buttonTapped ==signIn){
        if(delegate.sessionId){
            
            [self showRatingSuccess];
           
        }
        else{
            LoginAlertController *alertController = [LoginAlertController alertControllerWithTitle:@"Username and Password do not match!" message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            
            alertController.delegate = self;
            [self presentViewController:alertController animated:YES completion:^{}];
        }
    }
    else{
        RegViewController *regController =  [[RegViewController alloc]initWithNibName:@"RegViewController" bundle:nil];
        regController.delegate = self;
        NSURLRequest *registerRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:regRequestUrl]];
        [self presentViewController:regController animated:YES completion:^{
            [regController.webView loadRequest:registerRequest];
        }];
        
    }
}



-(void)didDismissRegViewController{
    [self signIn];
}


- (IBAction)rateMovie:(id)sender {
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    if(delegate.sessionId){
        
        [self showRatingSuccess];
        
    }
    else{
        [self signIn];
    }
}

-(void)showRatingSuccess{
    [self rateMovieWithId:[movie valueForKey:@"id"] Rate:_ratingView.value*2];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Thanks for your rating" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alertController animated:YES completion:^{
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}


//----------------------------major-------------------------------------


- (void)viewDidLoad {
    [super viewDidLoad];
    self.backImageView =  [[UIImageView alloc]initWithFrame:self.view.frame];
    [self.backImageView setContentMode:UIViewContentModeScaleAspectFill];
    self.backImageView.clipsToBounds = YES;
    self.backImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    self.backImageView.alpha = 0.2;
    [self.view addSubview:self.backImageView];
    [self.view sendSubviewToBack:self.backImageView];
    [_navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    _navigationBar.shadowImage = [UIImage new];
    [_movieBackdropCollectionView registerNib:[UINib nibWithNibName:@"MovieBackdropCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"movieImages"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    self.genreResourcePath = [basePath stringByAppendingPathComponent:@"genre.plist"];
       
    
    // Do any additional setup after loading the view from its nib.
    
}

-(void)loadDataFromMovie:(NSDictionary*)movieDic{
   
    movie = movieDic;

    NSDictionary *genreDic = [[NSDictionary alloc] initWithContentsOfFile: self.genreResourcePath];
    NSArray *genre_ids = [movie valueForKey:@"genre_ids"];
    NSString *label = @"Label: ";
    for (NSNumber* genreIdn in genre_ids) {
        NSString *genreId = genreIdn.description;
        NSString *genreName = [genreDic valueForKey:genreId];
        label = [NSString stringWithFormat:@"%@%@  ",label,genreName];
    }
    
    

    float mark = [[movie valueForKey:@"vote_average" ]floatValue];
    NSString *title = [movie  valueForKey:@"title"];
    self.navigationBar.topItem.title = title;
    [_titleLabel setText:title];
    
    NSString *release_date = [movie  valueForKey:@"release_date"];
    
    NSString *overview = [movie  valueForKey:@"overview"];
    
    NSString *idn = [movie  valueForKey:@"id"];
    NSString *showCast = @"";
    //  /*
    NSString *castRequestString = [movieWeb stringByAppendingString:[NSString stringWithFormat:@"%@/casts?%@",idn,APIKey]];
    
    NSString *castList = [self getCastFromUrl:[NSURL URLWithString:castRequestString]];
    if(castList.length==0){
        
        castList = @"N/A";
    }
    NSArray *castArray = [castList componentsSeparatedByString:@","];
    
    
    for (NSString *name in castArray) {
        showCast = [showCast stringByAppendingString:name];
        if (showCast.length>maxCastLengthForDisplay) {
            break;
        }
    }
    
    
    
    NSString *info = @"";
    if(mark==0){
        info = [NSString stringWithFormat:@"%@\nRelease Date: %@      Rate: N/A\nCast: %@  \n\nOverview:\n%@ ",label, release_date,showCast, overview];
        
    }
    else{
        info = [NSString stringWithFormat:@"%@\nRelease Date: %@      Rate: %.1f\nCast: %@ \n\nOverview:\n%@ ", label, release_date, mark,showCast, overview];
        
    }
    NSString *reviewRequestString = [NSString stringWithFormat:@"%@%@/reviews?%@",movieWeb,idn,APIKey];
    NSArray *reviewList = [self getDataFromUrl:[NSURL URLWithString:reviewRequestString] withKey:@"results" LimitPages:1];
    NSString *reviewString = @"\n\nReview:\n";
    NSUInteger reviewLength = reviewString.length;
    if(reviewList.count>0){
        
        for (NSDictionary *reviewDic in reviewList) {
            NSString *author = [reviewDic valueForKey:@"author"];
            NSString *content = [reviewDic valueForKey:@"content"];
            reviewString = [NSString stringWithFormat:@"%@\n%@:\n%@\n(End)\n\n",reviewString,author,content];
        }
    }
    if(reviewString.length>reviewLength){
        info = [info stringByAppendingString:reviewString];
    }

    [_movieInfo setText:info];
    NSLog(@"%@",_movieInfo.tintColor);
    
    [_ratingView setValue:mark/2];
    [_ratingView setAccurateHalfStars:NO];
    
    
   

    //https://api.themoviedb.org/3/movie/id/images?api_key=3c9140cda64a622c6cb5feb6c2689164
    NSString *movieImagesString = [NSString stringWithFormat:@"%@%@/images?%@",movieImageUrl,[movie valueForKey:@"id"],APIKey];
    NSData *moviesImagesData = [NSData dataWithContentsOfURL:[NSURL URLWithString:movieImagesString]];
    if(moviesImagesData.length>0){
        NSDictionary *movieImagesDic = [NSJSONSerialization JSONObjectWithData:moviesImagesData options:0 error:nil];
        NSArray* backdropImagesDicArray = [movieImagesDic valueForKey:@"backdrops"];
        NSArray* posterImagesDicArray = [movieImagesDic valueForKey:@"posters"];
        _movieImagesDicArray = [backdropImagesDicArray arrayByAddingObjectsFromArray:posterImagesDicArray];
        if(![[movie valueForKey:@"poster_path"]isEqual:[NSNull null]]){
            NSString *poster_path = [movie valueForKey:@"poster_path"];
            poster_path = [imdbPosterWeb stringByAppendingString:poster_path];
            self.backImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:poster_path]]];
            NSLog(@"%@",self.backImageView.description);
            /*
            [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:[movie valueForKey:@"poster_path"]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                self.backImageView.image = [UIImage imageWithData:data];
                NSLog(@"%@",self.backImageView.description);
          
            }]; */
        }
        
        
    }
    [_movieBackdropCollectionView reloadData];
    
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    [_movieInfo setContentOffset:CGPointZero animated:NO];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)turnBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *movieImageDic = [_movieImagesDicArray objectAtIndex:indexPath.row];
    NSNumber *aspect_ratio = [movieImageDic valueForKey:@"aspect_ratio"];
    float height = collectionView.frame.size.height;
    return CGSizeMake(height*[aspect_ratio floatValue], height);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    MovieBackdropCollectionViewCell * customCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"movieImages" forIndexPath:indexPath];
    NSDictionary *movieImageDic = [_movieImagesDicArray objectAtIndex:indexPath.row];
    
    
    NSString *file_path = [movieImageDic valueForKey:@"file_path"];
    file_path = [imdbPosterWeb stringByAppendingString: file_path];
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:file_path] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            UIImage *image = [UIImage imageWithData:data];
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    MovieBackdropCollectionViewCell *updateCell =(MovieBackdropCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
                    if (updateCell){
                        updateCell.movieImageView.image = image;
                    }
                });
            }
        }
    }];
    
    [task resume];
    
    
    return customCell;
}


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _movieImagesDicArray.count;
}





- (IBAction)showMedia:(id)sender {
    MovieMediaViewController *mediaViewController = [[MovieMediaViewController alloc]initWithNibName:@"MovieMediaViewController" bundle:nil movieDic:movie];
    [self presentViewController:mediaViewController animated:YES completion:nil];
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


@end