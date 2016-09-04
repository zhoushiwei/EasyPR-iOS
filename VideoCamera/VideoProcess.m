//
//  VideoProcess.m
//  OnLineFaceRecog
//
//  Created by zhoushiwei on 15/2/11.
//  Copyright (c) 2015年 zhoushiwei. All rights reserved.
//

#import "VideoProcess.h"

#import "VideoProcess.h"
#import <AVFoundation/AVFoundation.h>
#import <Accelerate/Accelerate.h>

@interface VideoProcess ()

+ (CGImageRef)createGrayScaleImageRefFromImageBuffer:(CVImageBufferRef)imageBuffer;
+ (CGImageRef)createRGBImageRefFromImageBuffer:(CVImageBufferRef)imageBuffer;

@end

@implementation VideoProcess
@synthesize m_avSession;
@synthesize m_captureImageType;

- (id)init {
    if (self = [super init])
    {
        self.m_captureImageType = MPVideoProcessorCaptureColorImageGrayScale;
    }
    return self;
}

- (void)setupAVCaptureSession {
    
    NSError *error;
    
    AVCaptureSession *avSession = [[AVCaptureSession alloc] init];
    [avSession setSessionPreset:AVCaptureSessionPreset640x480];
    NSArray* videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *captureDevice = nil;
    for (AVCaptureDevice *device in videoDevices)
    {
        if (device.position == AVCaptureDevicePositionBack)
        {
            captureDevice = device;
            break;
        }
    }
 
    if ( ! captureDevice)
    {
        captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    if (!captureDevice.position == AVCaptureDevicePositionFront){
        [captureDevice lockForConfiguration:&error];
        
        [captureDevice setExposureMode:AVCaptureExposureModeLocked];
        [captureDevice setFocusMode:AVCaptureFocusModeLocked];
        [captureDevice setWhiteBalanceMode:AVCaptureWhiteBalanceModeLocked];
        [captureDevice unlockForConfiguration];
    }
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice
                                                                              error:&error];
    if ([avSession canAddInput:deviceInput])
    {
        NSLog(@"avSession input added");
        [avSession addInput:deviceInput];
        
        //< Output Buffer
        AVCaptureVideoDataOutput *dataOutput = [[AVCaptureVideoDataOutput alloc] init];
        switch (self.m_captureImageType)
        {
            case MPVideoProcessorCaptureColorImageGrayScale:
                dataOutput.videoSettings = [NSDictionary
                                            dictionaryWithObject:[NSNumber numberWithUnsignedInt:
                                                                  kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
                                            forKey:(NSString *)kCVPixelBufferPixelFormatTypeKey];
                break;
            case MPVideoProcessorCaptureColorImageRGB:
                dataOutput.videoSettings = [NSDictionary
                                            dictionaryWithObject:[NSNumber numberWithUnsignedInt:
                                                                  kCVPixelFormatType_32BGRA]
                                            forKey:(NSString *)kCVPixelBufferPixelFormatTypeKey];
                break;
            default:
                break;
        }
 
        if ([avSession canAddOutput:dataOutput])
        {
            [avSession addOutput:dataOutput];
            NSLog(@"avSession output added");
        }
    }
    
    self.m_avSession = avSession;
}

- (void)startAVSessionWithBufferDelegate:(id<AVCaptureVideoDataOutputSampleBufferDelegate>) delegate {
    if (!self.m_avSession)
    {
        [self setupAVCaptureSession];
    }
    AVCaptureVideoDataOutput *dataOutput = [[self.m_avSession outputs] objectAtIndex:0];
    if ([dataOutput sampleBufferDelegate] == nil || [dataOutput sampleBufferDelegate] != delegate)
    {
        [dataOutput setSampleBufferDelegate:delegate queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        [dataOutput setAlwaysDiscardsLateVideoFrames:TRUE];
        //   [dataOutput setSampleBufferDelegate:self queue:queue];
        
        AVCaptureConnection *videoConnection = [dataOutput connectionWithMediaType:AVMediaTypeVideo];
        videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;  
        videoConnection.videoMinFrameDuration = CMTimeMake(1, 18);
        
        [self.m_avSession startRunning];
    }
}

- (void)stopAVSession {
    [self.m_avSession stopRunning];
}

- (void)startAVSession {
    [self.m_avSession startRunning];
}

#pragma mark - Private
- (CGImageRef)createImageRefFromImageBuffer:(CVImageBufferRef)imageBuffer {
    switch (self.m_captureImageType)
    {
        case MPVideoProcessorCaptureColorImageGrayScale:
            return [VideoProcess createGrayScaleImageRefFromImageBuffer:imageBuffer];
            break;
        case MPVideoProcessorCaptureColorImageRGB:
            return [VideoProcess createRGBImageRefFromImageBuffer:imageBuffer];
            break;
        default:
            break;
    }
}

+ (CGImageRef)createGrayScaleImageRefFromImageBuffer:(CVImageBufferRef)imageBuffer {
    size_t width = CVPixelBufferGetWidthOfPlane(imageBuffer, 0);
    size_t height = CVPixelBufferGetHeightOfPlane(imageBuffer, 0);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0);
    Pixel_8 *lumaBuffer = (Pixel_8 *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
    CGColorSpaceRef grayColorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(lumaBuffer, width, height, 8, bytesPerRow, grayColorSpace, kCGImageAlphaNone);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(grayColorSpace);
    return imageRef;
}

+ (CGImageRef)createRGBImageRefFromImageBuffer:(CVImageBufferRef)imageBuffer {
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    uint8_t *lumaBuffer = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(lumaBuffer, width, height, 8, bytesPerRow, rgbColorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(rgbColorSpace);
    return imageRef;
}


@end