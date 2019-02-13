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
    SFSpeechAudioBufferRecognitionRequest* recognitionRequest;
    SFSpeechRecognitionTask* recognitionTask;
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
        audioEngine = [[AVAudioEngine alloc] init];
        if(audioEngine.inputNode == nil) {
            [NSException raise:@"Initialize error" format:@"No audio engine input"];
            return nil;
        }
        recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc]init];
        recognitionRequest.shouldReportPartialResults = YES;
    }
    return self;
}

- (void) dealloc {
    if(self.isRunning) {
        [self stop];
    }
}

- (void)setLocale: (NSString*)locale {
    speechRecognizer = [[SFSpeechRecognizer alloc]initWithLocale:[NSLocale localeWithLocaleIdentifier:locale]];
    speechRecognizer.delegate = self;
}

- (void)start:(void(^)(NSString *))callback {
    // Error checks
    if(!speechRecognizer) {
        [NSException raise:@"Initialize error" format:@"Call SetLocale before start"];
        return;
    }
    if(_isRunning) {
        return;
    }
    _isRunning = YES;
    
    // Make audio session
    NSError *err;
    AVAudioSession* audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:&err];
    assert(err == nil);
    [audioSession setMode:AVAudioSessionModeMeasurement error:&err];
    assert(err == nil);
    [audioSession setActive:YES
                withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                      error:&err];
    assert(err == nil);
    
    recognitionTask = [speechRecognizer recognitionTaskWithRequest:recognitionRequest resultHandler:^(SFSpeechRecognitionResult *result, NSError * error)
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
    
    // Start audio engine
    // Have to change audio format for recognition : 24000 Hz, 1channels
    // AVAudioFormat* recordingFormat = [audioEngine.inputNode outputFormatForBus:0];
    AVAudioFormat* recordingFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:24000 channels:1];
    [audioEngine.inputNode installTapOnBus:0
                                bufferSize:1024
                                    format:recordingFormat
                                     block:^(AVAudioPCMBuffer* buffer, AVAudioTime* when) {
        [self->recognitionRequest appendAudioPCMBuffer:buffer];
    }];
    [audioEngine prepare];
    [audioEngine startAndReturnError:nil];
}

- (void)stop {
    if(!_isRunning) {
        return;
    }
    _isRunning = NO;
    
    [recognitionTask cancel];
    [audioEngine stop];
    [recognitionRequest endAudio];
    [audioEngine.inputNode removeTapOnBus:0];
    recognitionTask = nil;
}

- (BOOL) isRunning {
    return _isRunning;
}

- (void)speechRecognizer:(SFSpeechRecognizer *)speechRecognizer availabilityDidChange:(BOOL)available {
    NSLog(@"available did change: %i", available);
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
//            callback(MakeStringCopy(result));
            callback(result.UTF8String);
        }];
    }
    
    void _unitySpeechRecognizerStop() {
        [UnitySpeechRecognizerPlugin.shared stop];
    }
}
