//
//  VideoProcess.h
//  OnLineFaceRecog
//
//  Created by zhoushiwei on 15/2/11.
//  Copyright (c) 2015年 zhoushiwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@class AVCaptureSession;
@protocol AVCaptureVideoDataOutputSampleBufferDelegate;

typedef enum {
    MPVideoProcessorCaptureColorImageRGB,
    MPVideoProcessorCaptureColorImageGrayScale
} CaptureImageType;

@interface VideoProcess : NSObject

@property (strong, nonatomic) AVCaptureSession *m_avSession;

//< By Default: EnumCaptureGrayScaleImage
@property (assign, nonatomic) CaptureImageType m_captureImageType;


//< Start Steps, call setupAVCaptureSession first than startAVSessionWithBufferDelegate
//< One can add customization between these two methods
- (void)setupAVCaptureSession;
- (void)startAVSessionWithBufferDelegate:(id<AVCaptureVideoDataOutputSampleBufferDelegate>)delegate;

//< Stop
- (void)stopAVSession;
- (void)startAVSession;
//< Utility function, typically used in the delegate function
- (CGImageRef)createImageRefFromImageBuffer:(CVImageBufferRef)imageBuffer;

@end