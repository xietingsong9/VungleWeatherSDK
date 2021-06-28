//
//  VLWeatherRequest.m
//  VLWeatherSDK
//
//  Created by xietingsong on 2021/6/26.
//

#import "VLWeatherRequest.h"

@interface VLWeatherRequest ()
@property (nonatomic , copy) NSString *urlString;

@property (nonatomic , strong) NSMutableDictionary *parameters;
@property (nonatomic , strong) NSMutableDictionary *headers;
@property (nonatomic , strong) NSMutableURLRequest *currentRequest;

@end

@implementation VLWeatherRequest

#pragma mark Initializer

- (instancetype)initWithURLString:(NSString *)aURLString
                           params:(NSDictionary*)params
                       httpMethod:(NSString *)httpMethod {
  
  if(self = [super init]) {
    
    self.urlString = aURLString;
    if(params) {
      self.parameters = params.mutableCopy;
    } else {
      self.parameters = [NSMutableDictionary dictionary];
    }
    
    self.httpMethod = httpMethod;
    
    self.headers = [NSMutableDictionary dictionary];
  }
  
  return self;
}

#pragma mark -
#pragma mark Lazy request creator

- (NSMutableURLRequest*)request {
  
    if (_currentRequest == nil) {

        NSURL *url = [self formatURL];
        if(url == nil) {
            NSLog(@"Unable to create request, because the url is ni");
            return nil;
        }

        NSMutableURLRequest *createdRequest = [NSMutableURLRequest requestWithURL:url];
        [createdRequest setAllHTTPHeaderFields:self.headers];
        [createdRequest setHTTPMethod:self.httpMethod];

        NSString *charset = (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
        [createdRequest setValue:[NSString stringWithFormat:@"application/json; charset=%@", charset]
              forHTTPHeaderField:@"Content-Type"];

        _currentRequest = createdRequest;
    }

    return _currentRequest;
}

#pragma mark -
#pragma mark Methods to customize your network request after initialization

- (void)addParameters:(NSDictionary*)paramsDictionary {
    if (paramsDictionary) {
        [self.parameters addEntriesFromDictionary:paramsDictionary];
    }
}

- (void)addHeaders:(NSDictionary*)headersDictionary {
    if (headersDictionary) {
        [self.headers addEntriesFromDictionary:headersDictionary];
    }
}

- (void)cancel {
    if (self.state == VLWeatherRequestStateStarted) {
        [self.task cancel];
        self.state = VLWeatherRequestStateCancelled;
    }
}

- (void)setState:(VLWeatherRequestState)state {
    _state = state;
  
    //when the state is started , reume current task
    if(state == VLWeatherRequestStateStarted) {
        [self.task resume];
    }
    else if(state == VLWeatherRequestStateCompleted ||
            state == VLWeatherRequestStateError) {
    }else if(state == VLWeatherRequestStateCancelled) {}
}

- (id)responseAsJSON {
  
    if(self.responseData == nil) return nil;
    NSError *error = nil;
    id returnValue = [NSJSONSerialization JSONObjectWithData:self.responseData options:0 error:&error];
    if(!returnValue) NSLog(@"JSON Parsing Error: %@", error);
    return returnValue;
}

- (NSURL*)formatURL
{
    NSURL *url = nil;
    if ([self.httpMethod.uppercaseString isEqualToString:@"GET"] &&
      (self.parameters && self.parameters.allKeys.count > 0)) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", self.urlString,[self urlEncodedKeyValueString:self.parameters]]];
    } else {
        url = [NSURL URLWithString:self.urlString];
    }
    return url;
}

- (NSString*)urlEncodedKeyValueString:(NSDictionary*)params {
  
  NSMutableString *string = [NSMutableString string];
  for (NSString *key in params) {
      NSObject *value = [params valueForKey:key];
      [string appendFormat:@"%@=%@&",key,value];
  }
  
  if([string length] > 0)
      [string deleteCharactersInRange:NSMakeRange([string length] - 1, 1)];
  
  return string;
}

@end

