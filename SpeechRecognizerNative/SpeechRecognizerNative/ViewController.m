//
//  ViewController.m
//  SpeechRecognizerNative
//
//  Created by Koki Ibukuro on 2019/02/07.
//  Copyright © 2019 Koki Ibukuro. All rights reserved.
//

#import <Speech/Speech.h>
#import "ViewController.h"
#import "UnitySpeechRecognizerPlugin.h"

typedef void (*SpeechRecognizerRequestCallback)(int status);
typedef void (*SpeechRecognizerResultCallback)(const char *);
int _unitySpeechRecognizerAuthorizationStatus();
void _unitySpeechRecognizerRequestAuthorization(SpeechRecognizerRequestCallback callback);
void _unitySpeechRecognizerStart(SpeechRecognizerResultCallback callback);
void _unitySpeechRecognizerStop();

void _SpeechRecognizerRequestCallback(int status) {
    NSLog(@"status callback : %i", status);
}

void _SpeechRecognizerResultCallback(const char * result) {
    NSLog(@"result callback : %@", [NSString stringWithUTF8String:result]);
}

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextView *resultTextView;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@property (nonatomic, retain) UnitySpeechRecognizerPlugin* speechRecognizer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.speechRecognizer = [UnitySpeechRecognizerPlugin shared];
    [self.speechRecognizer setLocale:@"ja-JP"];
    
    _unitySpeechRecognizerRequestAuthorization(_SpeechRecognizerRequestCallback);
    
    int status = _unitySpeechRecognizerAuthorizationStatus();
    NSLog(@"status : %i", status);
}



- (IBAction)onToggleStart:(id)sender {
    if(self.speechRecognizer.isRunning) {
//        [self.speechRecognizer stop];
        _unitySpeechRecognizerStop();
    } else {
//        [self.speechRecognizer start:^(NSString * _Nonnull result) {
//            NSLog(@"result: %@", result);
//            self.resultTextView.text = result;
//        }];
        _unitySpeechRecognizerStart(_SpeechRecognizerResultCallback);
    }
    
    NSLog(@"Start : running : %i ", self.speechRecognizer.isRunning);
}

@end
