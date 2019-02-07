//
//  UnitySpeechRecognizerPlugin.m
//  SpeechRecognizerNative
//
//  Created by Koki Ibukuro on 2019/02/07.
//  Copyright © 2019 Koki Ibukuro. All rights reserved.
//

#import "UnitySpeechRecognizerPlugin.h"
#import <Speech/Speech.h>

@interface UnitySpeechRecognizerPlugin () <SFSpeechRecognizerDelegate> {
    SFSpeechRecognizer* speechRecognizer;
    SFSpeechAudioBufferRecognitionRequest* speechRequest;
    SFSpeechRecognitionTask* recognazationTask;
    AVAudioEngine *audioEngine;
}
@end

@implementation UnitySpeechRecognizerPlugin

static UnitySpeechRecognizerPlugin * _shared;

+ (UnitySpeechRecognizerPlugin*) shared {
    @synchronized(self) {
        if(_shared == nil) {
            _shared = [[self alloc] init];
        }
    }
    return _shared;
}

- (id) init {
    if (self = [super init])
    {
        audioEngine = [AVAudioEngine new];
        if( audioEngine.inputNode ){
            [audioEngine.inputNode installTapOnBus:0 bufferSize:1024 format:nil block:^(AVAudioPCMBuffer* buffer, AVAudioTime* when) {
                [self->speechRequest appendAudioPCMBuffer:buffer];
            }];
        }
        
        speechRequest = [[SFSpeechAudioBufferRecognitionRequest alloc]init];
        speechRequest.shouldReportPartialResults = YES;
    }
    return self;
}

- (void) dealloc {
    NSLog(@"dealloc plugin");
}


- (void)setLocale: (NSString*)locale {
    speechRecognizer = [[SFSpeechRecognizer alloc]initWithLocale:[NSLocale localeWithLocaleIdentifier:locale]];
    speechRecognizer.delegate = self;}

@end

#pragma mark - Unity Bridge

extern "C" {
    typedef void (*SpeechRecognizerRequestCallback)(int status);
    
    void _unitySpeechRecognizerRequestAuthorization(SpeechRecognizerRequestCallback callback) {
        [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
            callback(status);
        }];
    }
    
    int _unitySpeechRecognizerAuthorizationStatus() {
        return [SFSpeechRecognizer authorizationStatus];
    }
}
