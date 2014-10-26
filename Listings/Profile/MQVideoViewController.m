//
//  MQVideoViewController.m
//  Listings
//
//  Created by Dan Kwon on 10/25/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "MQVideoViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <MediaPlayer/MediaPlayer.h>


@interface MQVideoViewController ()
@property (strong, nonatomic) NSData *movieData;
@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;
@property (strong, nonatomic) UIImageView *videoThumbnail;
@end

NSString *movieFileName = @"movie.MOV";

@implementation MQVideoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Video";

    }
    return self;
}


- (void)loadView
{
    UIView *view = [self baseView:YES];
    CGRect frame = view.frame;
    
    UIImage *bgImage = [UIImage imageNamed:@"bgBlurry1.png"];
    view.backgroundColor = [UIColor colorWithPatternImage:bgImage];
    
    UIButton *btnPlay = [UIButton buttonWithType:UIButtonTypeCustom];
    btnPlay.frame = CGRectMake(0, 0, frame.size.width-24.0f, 44.0f);
    btnPlay.backgroundColor = [UIColor redColor];
    [btnPlay setTitle:@"PLAY" forState:UIControlStateNormal];
    btnPlay.center = CGPointMake(0.5f*frame.size.width, 0.25f*frame.size.height);
    [btnPlay addTarget:self action:@selector(playMovie:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnPlay];

    
    self.videoThumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.5f*frame.size.width, 0.5f*frame.size.width)];
    self.videoThumbnail.center = CGPointMake(0.50f*frame.size.width, 0.50f*frame.size.height);
    self.videoThumbnail.backgroundColor = [UIColor greenColor];
    self.videoThumbnail.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [view addSubview:self.videoThumbnail];
    
    CGFloat padding = 12.0f;
    UIView *next = [[UIView alloc] initWithFrame:CGRectMake(0.0f, frame.size.height-64.0f, frame.size.width, 64.0f)];
    next.backgroundColor = [UIColor grayColor];
    next.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    UIButton *btnNext = [UIButton buttonWithType:UIButtonTypeCustom];
    btnNext.frame = CGRectMake(padding, padding, frame.size.width-2*padding, 44.0f);
    btnNext.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    btnNext.backgroundColor = [UIColor clearColor];
    btnNext.layer.borderColor = [[UIColor whiteColor] CGColor];
    btnNext.layer.borderWidth = 1.5f;
    btnNext.layer.cornerRadius = 4.0f;
    btnNext.layer.masksToBounds = YES;
    btnNext.titleLabel.font = [UIFont fontWithName:@"Heiti SC" size:16.0f];
    [btnNext setTitle:@"RECORD VIDEO" forState:UIControlStateNormal];
    [btnNext setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnNext addTarget:self action:@selector(recordVideo:) forControlEvents:UIControlEventTouchUpInside];
    [next addSubview:btnNext];
    
    [view addSubview:next];

    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)playMovie:(UIButton *)btn
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideMoviePlayer)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
    
    self.moviePlayer.view.frame = self.view.frame;
    [self.view addSubview:self.moviePlayer.view];
    
    [self.moviePlayer play];
    
}

- (void)hideMoviePlayer
{
    NSLog(@"HIDE MOVIE PLAYER");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [self.moviePlayer.view removeFromSuperview];
    

}

-(void)handleThumbnailImageRequestFinishNotification:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerThumbnailImageRequestDidFinishNotification object:nil];
    

    NSDictionary *userinfo = [notification userInfo];
    NSLog(@"handleThumbnailImageRequestFinishNotification: %@", [userinfo description]);
    NSError *error = [userinfo objectForKey:MPMoviePlayerThumbnailErrorKey];
    if (error){
        NSLog(@"Error creating video thumbnail image. Details: %@", [error localizedDescription]);
        return;
    }
    
    UIImage *thumbnail = [userinfo valueForKey:MPMoviePlayerThumbnailImageKey];
    NSLog(@"Thumbnail: %.2f, %.2f", thumbnail.size.width, thumbnail.size.height);
    
    CGFloat w = thumbnail.size.width;
    CGFloat h = thumbnail.size.height;
    CGRect thumbnailFrame = self.videoThumbnail.frame;
    if (w > thumbnailFrame.size.width){
        double scale = thumbnailFrame.size.width / w;
        w = thumbnailFrame.size.width;
        h *= scale;
        thumbnailFrame.size.width = w;
        thumbnailFrame.size.height = h;
        self.videoThumbnail.frame = thumbnailFrame;
        self.videoThumbnail.center = CGPointMake(0.50f*self.view.frame.size.width, 0.50f*self.view.frame.size.height);
    }
    
    
    
    self.videoThumbnail.image = thumbnail;
    
}

- (void)recordVideo:(UIButton *)btn
{
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    cameraUI.mediaTypes = @[(NSString *)kUTTypeMovie]; // Displays a control that allows the user to choose movie capture
    
    // Hides the controls for moving & scaling pictures, or for trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    cameraUI.delegate = self;
    
    [self presentViewController:cameraUI animated:YES completion:^{
        
    }];
    
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
//    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    NSLog(@"picker didFinishPickingMediaWithInfo: %@", [info description]);
    
    NSURL *chosenMovie = [info objectForKey:UIImagePickerControllerMediaURL];
    
    self.movieData = [NSData dataWithContentsOfURL:chosenMovie];
    NSString *filePath = [self createFilePath:movieFileName];
    [self.movieData writeToFile:filePath atomically:YES];
    NSLog(@"%d bytes", (int)self.movieData.length);
    
    if (!self.moviePlayer){
        self.moviePlayer = [[MPMoviePlayerController alloc] init];
        self.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleThumbnailImageRequestFinishNotification:)
                                                 name:MPMoviePlayerThumbnailImageRequestDidFinishNotification
                                               object:self.moviePlayer];
    
    

    [self.moviePlayer setContentURL:[NSURL fileURLWithPath:[self createFilePath:movieFileName]]];
    [self.moviePlayer requestThumbnailImagesAtTimes:@[[NSNumber numberWithDouble:2.0f]] timeOption:MPMovieTimeOptionNearestKeyFrame];

    
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}


- (NSString *)createFilePath:(NSString *)fileName
{
    fileName = [fileName stringByReplacingOccurrencesOfString:@"/" withString:@"+"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    return filePath;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
