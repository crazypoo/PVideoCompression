//
//  ViewController.m
//  PVideoCompression
//
//  Created by crazypoo on 15/7/1.
//  Copyright (c) 2015年 P. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    NSURL *sourceURL;
    UILabel *fileLenLabel;
    UILabel *fileSizeLabel;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    fileLenLabel  = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 200, 20)];
    fileLenLabel.textColor = [UIColor redColor];
    [self.view addSubview:fileLenLabel];
    fileSizeLabel  = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 200, 20)];
    fileSizeLabel.textColor = [UIColor grayColor];
    [self.view addSubview:fileSizeLabel];
    
}

-(IBAction)start:(id)sender
{
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
    NSArray *availableMedia = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    ipc.mediaTypes = [NSArray arrayWithObject:availableMedia[1]];
    ipc.videoMaximumDuration = 30.0f;
    ipc.delegate = self;
    [self presentViewController:ipc animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    sourceURL = [info objectForKey:UIImagePickerControllerMediaURL];
    
    fileLenLabel.text = [NSString stringWithFormat:@"%f s", [self getVideoLength:sourceURL]];
    fileSizeLabel.text = [NSString stringWithFormat:@"%f kb", [self getFileSize:[[sourceURL absoluteString] substringFromIndex:16]]];
    //    NSLog(@"%@",[[sourceURL absoluteString] substringFromIndex:16]);
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)convert:(id)sender
{
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:sourceURL options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    NSString *resultQuality = @"AVAssetExportPreset640x480";
    NSString *resultPath;
    if ([compatiblePresets containsObject:resultQuality])
    {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:resultQuality];
        
        NSDateFormatter *formater = [[NSDateFormatter alloc] init];
        [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
        resultPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/output-%@.mp4", [formater stringFromDate:[NSDate date]]];
        
        exportSession.outputURL = [NSURL fileURLWithPath:resultPath];
        exportSession.outputFileType = AVFileTypeMPEG4;
        [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
         {
             switch (exportSession.status) {
                 case AVAssetExportSessionStatusUnknown:
                     NSLog(@"AVAssetExportSessionStatusUnknown");
                     break;
                 case AVAssetExportSessionStatusWaiting:
                     NSLog(@"AVAssetExportSessionStatusWaiting");
                     break;
                 case AVAssetExportSessionStatusExporting:
                     NSLog(@"AVAssetExportSessionStatusExporting");
                     break;
                 case AVAssetExportSessionStatusCompleted:
                     NSLog(@"AVAssetExportSessionStatusCompleted");
                     break;
                 case AVAssetExportSessionStatusFailed:
                     NSLog(@"AVAssetExportSessionStatusFailed");
                     break;
             }
         }];
    }
}

-(CGFloat)getFileSize:(NSString *)path
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    float filesize = -1.0;
    if ([fileManager fileExistsAtPath:path]) {
        NSDictionary *fileDic = [fileManager attributesOfItemAtPath:path error:nil];
        unsigned long long size = [[fileDic objectForKey:NSFileSize] longLongValue];
        filesize = 1.0*size/1024;
    }
    return filesize;
}

-(CGFloat)getVideoLength:(NSURL *)URL
{
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:URL options:opts];
    float second = 0;
    second = urlAsset.duration.value/urlAsset.duration.timescale;
    return second;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
