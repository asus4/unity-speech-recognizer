//
//  UnitySpeechRecognizerPlugin.h
//  SpeechRecognizerNative
//
//  Created by Koki Ibukuro on 2019/02/07.
//  Copyright © 2019 Koki Ibukuro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UnitySpeechRecognizerPlugin : NSObject

+ (UnitySpeechRecognizerPlugin*) shared;


- (void)setLocale: (NSString*)locale;


@end

NS_ASSUME_NONNULL_END
