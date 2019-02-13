//
//  UnitySpeechRecognizerPlugin.m
//  SpeechRecognizerNative
//
//  Created by Koki Ibukuro on 2019/02/07.
//  Copyright © 2019 Koki Ibukuro. All rights reserved.
//

#import "UnitySpeechRecognizerPlugin.h"
#import <Speech/Speech.h>

#define MakeStringCopy( _x_ ) ( _x_ != NULL && [_x_ isKindOfClass:[NSString class]] ) ? strdup( [_x_ UTF8String] ) : NULL


@interface UnitySpeechRecognizerPlugin () <SFSpeechRecognizerDelegate> {
    SFSpeechRecognizer* speechRecognizer;
    SFSpeechAudioBufferRecognitionRequest* speechRequest;
    SFSpeechRecognitionTask* recognazationTask;
    AVAudioEngine *audioEngine;
    
    BOOL _isRunning;
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
        NSLog(@"initializedddddddd");
    }
    return self;
}

- (void) dealloc {
    if(self.isRunning) {
        [self stop];
    }
}


- (void)setLocale: (NSString*)locale {
    NSLog(@"set locale with %@", locale);
    speechRecognizer = [[SFSpeechRecognizer alloc]initWithLocale:[NSLocale localeWithLocaleIdentifier:locale]];
    speechRecognizer.delegate = self;
}

- (void)start:(void(^)(NSString *))callback {
    NSLog(@"start");
    if(_isRunning) {
        return;
    }
    _isRunning = YES;
    
    [audioEngine prepare];
    [audioEngine startAndReturnError:nil];
    
    recognazationTask = [speechRecognizer recognitionTaskWithRequest:speechRequest resultHandler:^(SFSpeechRecognitionResult *result, NSError * error)
    {
        BOOL isFinal = NO;
        if(result) {
            callback(result.bestTranscription.formattedString);
            isFinal = result.isFinal;
        }
        if(error || isFinal) {
            if(error.code != 216) {
                NSLog(@"error: %@ %@", error, error.localizedDescription);
            }
            [self stop];
        }
    }];
}

- (void)stop {
    NSLog(@"stop");
    if(!_isRunning) {
        return;
    }
    _isRunning = NO;
    
    [recognazationTask cancel];
    [speechRequest endAudio];
    [audioEngine stop];
    recognazationTask = nil;
}

- (BOOL) isRunning {
    return _isRunning;
}

@end

#pragma mark - Unity Bridge

extern "C" {
    typedef void (*SpeechRecognizerRequestCallback)(int status);
    typedef void (*SpeechRecognizerResultCallback)(const char *);
    
    void _unitySpeechRecognizerRequestAuthorization(SpeechRecognizerRequestCallback callback) {
        [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
            callback(status);
        }];
    }
    
    int _unitySpeechRecognizerAuthorizationStatus() {
        return [SFSpeechRecognizer authorizationStatus];
    }
    
    void _unitySpeechRecognizerSetLocale(const char* locale) {
        [UnitySpeechRecognizerPlugin.shared setLocale:[NSString stringWithUTF8String:locale]];
    }
    
    void _unitySpeechRecognizerStart(SpeechRecognizerResultCallback callback) {
        [UnitySpeechRecognizerPlugin.shared start:^(NSString * _Nonnull result) {
            callback(MakeStringCopy(result));
            //callback(result.UTF8String);
        }];
    }
    
    void _unitySpeechRecognizerStop() {
        [UnitySpeechRecognizerPlugin.shared stop];
    }
}
