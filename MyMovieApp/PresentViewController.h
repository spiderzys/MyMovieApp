//
//  PresentViewController.h
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2016-01-05.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PresentViewController : UIViewController <UIDocumentInteractionControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property UIDocumentInteractionController *documentInteractionController;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil image: (UIImage*)image;

@end
