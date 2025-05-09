#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WhisperKitBridge : NSObject

+ (nullable NSString *)loadModel:(nullable NSString *)variant
                       modelRepo:(nullable NSString *)modelRepo
                      redownload:(BOOL)redownload
                           error:(NSError **)error;

+ (nullable NSString *)transcribeFromFile:(NSString *)filePath
                                  options:(NSDictionary *)options
                                    error:(NSError **)error;

+ (nullable NSString *)startRecording:(NSDictionary *)options
                                 loop:(BOOL)loop
                                error:(NSError **)error;

+ (nullable NSString *)stopRecording:(BOOL)loop
                               error:(NSError **)error;

// Callback registration for transcription results
+ (void)registerTranscriptionCallback:(void (^)(NSString *))callback;

// Callback registration for model progress updates
+ (void)registerModelProgressCallback:(void (^)(NSDictionary *))callback;

// Unregister callbacks
+ (void)unregisterTranscriptionCallback;
+ (void)unregisterModelProgressCallback;

@end

NS_ASSUME_NONNULL_END
