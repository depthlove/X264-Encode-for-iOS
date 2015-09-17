//
//  ViewController.m
//  X264Encode
//
//  Created by sunminmin on 15/8/27.
//  Copyright (c) 2015年 suntongmian@163.com. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "X264Manager.h"

@interface ViewController () <AVCaptureVideoDataOutputSampleBufferDelegate>
{
    X264Manager                     *manager264;
    
    AVCaptureSession                *captureSession;
    AVCaptureDevice                 *captureDevice;
    AVCaptureDeviceInput            *captureDeviceInput;
    AVCaptureVideoDataOutput        *captureVideoDataOutput;
    AVCaptureVideoPreviewLayer      *previewLayer;
    
    UIButton                        *openVideoButton;
    UIButton                        *closeViedoButton;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
 
/* ---------------------------------------------------------------------- */
    captureSession = [[AVCaptureSession alloc] init];
    captureSession.sessionPreset = AVCaptureSessionPresetMedium;
    
    captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error = nil;
    captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if(captureDeviceInput)
        [captureSession addInput:captureDeviceInput];
    else
        NSLog(@"Error: %@", error);
    
    captureVideoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [captureVideoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
    
    NSDictionary *settingsDic = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 [NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange],
                                 kCVPixelBufferPixelFormatTypeKey,
                                 nil]; // X264_CSP_NV12
    captureVideoDataOutput.videoSettings = settingsDic;
    
    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
    [captureVideoDataOutput setSampleBufferDelegate:self queue:queue];
    [captureSession addOutput:captureVideoDataOutput];

    
/* ---------------------------------------------------------------------- */
    previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
    previewLayer.frame = self.view.layer.bounds;


/* ---------------------------------------------------------------------- */
    openVideoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    openVideoButton.frame = CGRectMake(45, self.view.frame.size.height - 44 - 20, 80, 44);
    [openVideoButton setTitle:@"打开视频" forState:UIControlStateNormal];
    [openVideoButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [openVideoButton addTarget:self action:@selector(openVideo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:openVideoButton];
    
    closeViedoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeViedoButton.frame = CGRectMake(self.view.frame.size.width - 45 - 80, self.view.frame.size.height - 44 - 20, 80, 44);
    [closeViedoButton setTitle:@"关闭视频" forState:UIControlStateNormal];
    [closeViedoButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [closeViedoButton addTarget:self action:@selector(closeVideo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeViedoButton];
}

// 文件保存路径
- (NSString *)savedFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *fileName = [self savedFileName];
    
    NSString *writablePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    return writablePath;
}

// 拼接文件名
- (NSString *)savedFileName
{
    return [[self nowTime2String] stringByAppendingString:@".h264"];
}

// 获取系统当前时间
- (NSString* )nowTime2String
{
    NSString *date = nil;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"YYYY-MM-dd hh:mm:ss";
    date = [formatter stringFromDate:[NSDate date]];
    
    return date;
}

- (void)openVideo
{
    NSLog(@"openVideo....");

    manager264 = [[X264Manager alloc]init];
    [manager264 setFileSavedPath:[self savedFilePath]];
    [manager264 setX264Resource];
    
    [self.view.layer addSublayer:previewLayer];
    [captureSession startRunning];
}

- (void)closeVideo
{
    NSLog(@"closeVideo!!!");
    
    [captureSession stopRunning];
    [previewLayer removeFromSuperlayer];

    [manager264 freeX264Resource];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    previewLayer = nil;
    captureSession = nil;
}


#pragma mark --
#pragma mark --  AVCaptureVideo(Audio)DataOutputSampleBufferDelegate method
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{

    if (captureOutput == captureVideoDataOutput) {
        
        [manager264 encoderToH264:sampleBuffer];
    }
    
    
}

#pragma mark --
#pragma mark -- screen 
- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
