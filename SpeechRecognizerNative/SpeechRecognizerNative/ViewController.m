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
int _unitySpeechRecognizerAuthorizationStatus();
void _unitySpeechRecognizerRequestAuthorization(SpeechRecognizerRequestCallback callback);


void _SpeechRecognizerRequestCallback(int status) {
    NSLog(@"statsu callback : %i", status);
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
    NSLog(@"Start");
}

@end
