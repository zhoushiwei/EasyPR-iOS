//
//  ViewController.m
//  EasyPR iOS
//
//  Created by zhoushiwei on 15/1/30.
//  Copyright (c) 2015年 zhoushiwei. All rights reserved.
//
#import "ViewController.h"
#import "UIImageCVMatConverter.h"
#import "SVProgressHUD.h"
#include "easypr.h"
#include "easypr/util/switch.hpp"
#include "GlobalData.hpp"
using namespace easypr;

int test_plate_recognize();
int testMain();
CPlateRecognize pr;

@interface ViewController ()

@end

@implementation ViewController

@synthesize imageView;
@synthesize textView;
@synthesize loadButton;
@synthesize saveButton;
@synthesize popoverController;
@synthesize toolbar;
@synthesize textLabel;
- (NSInteger)supportedInterfaceOrientations
{
    //only portrait orientation
    return UIInterfaceOrientationMaskPortrait;
}



- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [popoverController dismissPopoverAnimated:YES];
    }
    else
    {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
    UIImage* temp = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    UIImage *temp_image=[UIImageCVMatConverter scaleAndRotateImageBackCamera:temp];
    [SVProgressHUD show];
    source_image=[UIImageCVMatConverter cvMatFromUIImage:temp_image];
    UIImage*plate_uiimage=[self plateRecognition:source_image];
    imageView.image = temp_image;
    [saveButton setEnabled:YES];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [popoverController dismissPopoverAnimated:YES];
    }
    else
    {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)loadButtonPressed:(id)sender {
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    
    if (![UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypePhotoLibrary])
        return;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if ([self.popoverController isPopoverVisible])
        {
            [self.popoverController dismissPopoverAnimated:YES];
        }
        else
        {
            if ([UIImagePickerController isSourceTypeAvailable:
                 UIImagePickerControllerSourceTypePhotoLibrary])
            {
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                self.popoverController = [[UIPopoverController alloc]
                                          initWithContentViewController:picker];
                
                popoverController.delegate = self;
                
                [self.popoverController
                 presentPopoverFromBarButtonItem:sender
                 permittedArrowDirections:UIPopoverArrowDirectionUp
                 animated:YES];
            }
        }
    }
    else
    {
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (IBAction)loadButtonCameraPressed:(id)sender {
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    
    if (![UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera])
        return;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if ([self.popoverController isPopoverVisible])
        {
            [self.popoverController dismissPopoverAnimated:YES];
        }
        else
        {
            if ([UIImagePickerController isSourceTypeAvailable:
                 UIImagePickerControllerSourceTypeCamera])
            {
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                self.popoverController = [[UIPopoverController alloc]
                                          initWithContentViewController:picker];
                
                popoverController.delegate = self;
                
                [self.popoverController
                 presentPopoverFromBarButtonItem:sender
                 permittedArrowDirections:UIPopoverArrowDirectionUp
                 animated:YES];
            }
        }
    }
    else
    {
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (IBAction)saveButtonPressed:(id)sender {
    if (image != nil)
    {
        UIImageWriteToSavedPhotosAlbum(image, self, nil, NULL);
        //Alert window
        UIAlertView *alert = [UIAlertView alloc];
        alert = [alert initWithTitle:@"Gallery info"
                             message:@"The image was saved to the Gallery!"
                            delegate:self
                   cancelButtonTitle:@"Continue"
                   otherButtonTitles:nil];
        [alert show];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString* bundlePath=[[NSBundle mainBundle] bundlePath];
    std::string mainPath=[bundlePath UTF8String];
    GlobalData::mainBundle()=mainPath;
    
    cout << "test_plate_recognize" << endl;
    
    Mat src = imread(mainPath+"/image/test.jpg");
    pr.setLifemode(true);
    pr.setDebug(false);
    pr.setMaxPlates(4);
    //pr.setDetectType(PR_DETECT_COLOR | PR_DETECT_SOBEL);
    pr.setDetectType(easypr::PR_DETECT_CMSER);
    
    
    CGRect bounds = [UIScreen mainScreen].bounds;
    imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
    imageView.contentMode=UIViewContentModeScaleAspectFit;
    imageView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:imageView];
//    textView = [[UIImageView alloc] init];
//    textView.frame = CGRectMake(20, 0, 100, 30);
//    textView.contentMode=UIViewContentModeScaleAspectFit;
//    textView.backgroundColor = [UIColor redColor];
//    [self.view addSubview:textView];
//    [self.view bringSubviewToFront:textView];
    /* Add the fps Label */
    UILabel *fps = [[UILabel alloc] initWithFrame:CGRectMake(20, 120, 180, 20)];
    fps.font=[UIFont fontWithName:@"华文细黑" size:14.0f];
    
    fps.backgroundColor=[UIColor clearColor];
    fps.textColor=[UIColor redColor];
    fps.textAlignment=NSTextAlignmentLeft;
   // fps.transform = CGAffineTransformMakeRotation(90);
    fps.text=@"EasyPR iOS";
    self.textLabel = fps;
    [self.view addSubview:self.textLabel];
    [self.view bringSubviewToFront:self.textLabel];
    
    toolbar=[[UIToolbar alloc] initWithFrame:CGRectMake(0, bounds.size.height- 44, bounds.size.width, 44)];
    [toolbar setBackgroundColor:[UIColor clearColor]];
    //   toolbar.barStyle=UIBarStyleDefault;
    toolbar.tintColor=[UIColor blackColor];
    toolbar.translucent=YES;
    //   [toolbar setTranslucent:YES];
    [self.toolbar setBackgroundImage:[UIImage new]
                  forToolbarPosition:UIBarPositionAny
                          barMetrics:UIBarMetricsDefault];
    toolbar.delegate=self;
  
    UIBarButtonItem*TrainingItem= [[UIBarButtonItem alloc]
                                   
                                   initWithTitle:@"识别"
                                   
                                   style:UIBarButtonItemStylePlain
                                   
                                   target:self
                                   
                                   action:@selector(TraningPressed:)];
    UIBarButtonItem*flexitem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem*albumitem=[[UIBarButtonItem alloc]
                               
                               initWithTitle:@"相册"
                               style:UIBarButtonItemStylePlain
                               
                               target:self
                               
                               action:@selector(loadButtonPressed:)];
    
    UIBarButtonItem*cameraitem=[[UIBarButtonItem alloc]
                                
                                initWithTitle:@"相机"
                                style:UIBarButtonItemStylePlain
                                
                                target:self
                                
                                action:@selector(loadButtonCameraPressed:)];
  
    
    [toolbar setItems:[NSArray arrayWithObjects:albumitem,flexitem,cameraitem,
                       nil]];
    [self.view addSubview:toolbar];
    
    // Do any additional setup after loading the view, typically from a nib
    toolbar.autoresizingMask = UIViewAutoresizingNone;
  
    
    [saveButton setEnabled:NO];
     [SVProgressHUD show];
    NSString *nsstring=[[NSBundle mainBundle] pathForResource:@"test" ofType:@"jpg"];
    string image_path=[nsstring UTF8String];
    
    source_image=imread(image_path);
    resize(source_image, source_image,cv::Size(source_image.cols/2,source_image.rows/2));
    imageView.image=[UIImageCVMatConverter UIImageFromCVMat:source_image];
    UIImage*plate_uiimage=[self plateRecognition:source_image];
}

-(UIImage*)plateRecognition:(cv::Mat&)src
{
    UIImage *plateimage;
   
    vector<CPlate> plateVec;
    
    int result = pr.plateRecognize(src, plateVec);
    //int result = pr.plateRecognizeAsText(src, plateVec);
    if (result == 0) {
        size_t num = plateVec.size();
        for (size_t j = 0; j < num; j++) {
            cout << "plateRecognize: " << plateVec[j].getPlateStr() << endl;
        }
    }
    
    if (result != 0) cout << "result:" << result << endl;
    if(plateVec.size()==0){
        [SVProgressHUD dismiss];
        [self.textLabel performSelectorOnMainThread:@selector(setText:) withObject:[NSString stringWithFormat:@"No Plate"] waitUntilDone:NO];
        return plateimage;
    }
    string name=plateVec[0].getPlateStr();
    NSString *resultMessage = [NSString stringWithCString:plateVec[0].getPlateStr().c_str()
                                                encoding:NSUTF8StringEncoding];
    [self.textLabel performSelectorOnMainThread:@selector(setText:) withObject:[NSString stringWithFormat:@"%@",resultMessage] waitUntilDone:NO];
  
    
    if (result != 0)
        cout << "result:" << result << endl;
    [SVProgressHUD dismiss];
    return plateimage;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end