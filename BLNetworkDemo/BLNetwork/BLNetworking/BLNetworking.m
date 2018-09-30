//
//  BLNetworking.m
//  BLFast
//
//  Created by lightning on 2018/6/27.
//  Copyright © 2018年 lightning. All rights reserved.
//  变啦网络请求类

#import "BLNetworking.h"

#define kStringIsEmpty(str) ([str isKindOfClass:[NSNull class]] || [[NSString stringWithFormat:@"%@",str] isEqualToString: @"(null)"] || [[NSString stringWithFormat:@"%@",str] isEqualToString: @"<null>"] || [[NSString stringWithFormat:@"%@",str] isEqualToString: @"null"] || [[NSString stringWithFormat:@"%@",str] isEqualToString: @""]|| str == nil || [[NSString stringWithFormat:@"%@",str] length] < 1 ? YES : NO )

#define BLOCK_EXEC(block, ...) if (block) { block(__VA_ARGS__);};

// 解决循环引用
#ifndef weakify
#if RELEASE
#if __has_feature(objc_arc)
#define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif
#ifndef strongify
#if RELEASE
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif

@interface NSDictionary (BLAdd)
/**
 Convert dictionary to json string formatted. return nil if an error occurs.
 */
- (NSString *)jsonPrettyStringEncoded;
@end
@implementation NSDictionary (BLAdd)

- (NSString *)jsonPrettyStringEncoded {
    if ([NSJSONSerialization isValidJSONObject:self]) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
        NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        if (!error) return json;
    }
    return nil;
}
@end


/**
 网络请求打印函数

 @param para 参数
 @param url 地址
 @param resonpse 响应
 */
void BLNetworkingLog(NSDictionary * para, NSString * url, id resonpse) {
    NSString *responseString;
    if (!resonpse) {
        responseString = @"";
    } else {
        NSData* jsonData =[NSJSONSerialization dataWithJSONObject:resonpse
                             options:NSJSONWritingPrettyPrinted error:nil];
        responseString = [[NSString alloc] initWithData:jsonData
      encoding:NSUTF8StringEncoding];
    }
    
    NSLog(@"\n🍺🍺🍺🍺🍺🍺 network info 🍺🍺🍺🍺🍺🍺\n");
    NSLog(@" parameters = %@\n",[para jsonPrettyStringEncoded]);
    NSLog(@" url = %@\n",url);
    NSLog(@" response = %@\n",responseString);
    
    NSLog(@"\n🍺🍺🍺🍺🍺🍺 info end 🍺🍺🍺🍺🍺🍺\n");
}

/**
 网络请求错误打印函数

 @param para 参数
 @param url 地址
 @param error 错误
 */
void BLNetworkingErrorLog(NSDictionary * para, NSString * url, NSError * error) {
    NSLog(@"\n🍏🍏🍏🍏🍏🍏 network error 🍏🍏🍏🍏🍏🍏\n");
    NSLog(@" parameters = %@\n",[para jsonPrettyStringEncoded]);
    NSLog(@" url = %@\n",url);
    NSLog(@" error = %@\n",error.userInfo[NSLocalizedDescriptionKey]);
    NSLog(@"\n🍏🍏🍏🍏🍏🍏 error end 🍏🍏🍏🍏🍏🍏\n");
}

/**
 网络请求错误

 @param code 错误代码
 @param errorMsg 错误信息
 @return NSError
 */
NSError * BLNetworkError(NSInteger code, NSString * errorMsg) {
    return [[NSError alloc] initWithDomain:@"www.bianla.com" code:code userInfo:@{@"msg":errorMsg}];
}

@interface BLNetworking ()
@property (nonatomic, strong) NSMutableArray *runTaskArray;
@end

@implementation BLNetworking


#pragma mark - 声明周期
- (instancetype)init {
    if (self = [super init]) {
        _network = [BLNetwork network];
        _network.manager.responseSerializer = [AFJSONResponseSerializer serializer];
        _network.manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json",@"text/javascript", @"text/plain",@"text/html", nil];
    }
    return self;
}
- (void)dealloc {
    [self cancelAllCurrentRunTask];
}
#pragma mark - 公共方法
+ (instancetype)defaultNetwork
{
    static BLNetworking *objectName;
    static dispatch_once_t token;
    dispatch_once(&token,^{
        objectName = [[BLNetworking alloc]init];
    });
    return objectName;
}
- (NSArray *)currentRunTasks {
    return self.runTaskArray;
}
- (NSURLSessionDataTask *)GETRequestWithApiName:(NSString *)apiName
                                     parameters:(id)parameters
                                  responesBlock:(void (^)(id))responseBlock
                                   failuerBlcok:(void (^)(NSError *))failureBlck {
    
    return [self GETRequestWithApiName:apiName isJson:YES isFromBL:YES isNeedDeal:YES parameters:parameters responesBlock:responseBlock failuerBlcok:failureBlck];
    
}
- (NSURLSessionDataTask *)POSTRequestWithApiName:(NSString *)apiName
                                      parameters:(id)parameters
                                   responesBlock:(void (^)(id))responseBlock
                                    failuerBlcok:(void (^)(NSError *))failureBlck {
    return [self POSTRequestWithApiName:apiName isJson:YES isFromBL:YES isNeedDeal:YES parameters:parameters responesBlock:responseBlock failuerBlcok:failureBlck];
    
}
- (NSURLSessionDataTask *)GETHttpRequestWithApiName:(NSString *)apiName parameters:(id)parameters responesBlock:(void (^)(id))responseBlock failuerBlcok:(void (^)(NSError *))failureBlck {
    return [self GETRequestWithApiName:apiName isJson:NO isFromBL:YES isNeedDeal:YES parameters:parameters responesBlock:responseBlock failuerBlcok:failureBlck];
}
- (NSURLSessionDataTask *)POSTHttpRequestWithApiName:(NSString *)apiName parameters:(id)parameters responesBlock:(void (^)(id))responseBlock failuerBlcok:(void (^)(NSError *))failureBlck {
    return [self POSTRequestWithApiName:apiName isJson:NO isFromBL:YES isNeedDeal:YES parameters:parameters responesBlock:responseBlock failuerBlcok:failureBlck];
}
- (NSURLSessionDataTask *)POSTOtherRequestWithUrl:(NSString *)url parameters:(id)parameters responesBlock:(void (^)(id))responseBlock failuerBlcok:(void (^)(NSError *))failureBlck {
    return [self POSTRequestWithApiName:url isJson:YES isFromBL:NO isNeedDeal:NO parameters:parameters responesBlock:responseBlock failuerBlcok:failureBlck];
}
- (NSURLSessionDataTask *)GETOtherRequestWithUrl:(NSString *)url parameters:(id)parameters responesBlock:(void (^)(id))responseBlock failuerBlcok:(void (^)(NSError *))failureBlck {
    return [self GETRequestWithApiName:url isJson:YES isFromBL:NO isNeedDeal:NO parameters:parameters responesBlock:responseBlock failuerBlcok:failureBlck];
}

- (NSURLSessionDataTask *)uploadImageWithImage:(id)image
                                       apiName:(NSString *)apiName
                                       keyName:(NSString *)keyName
                                      progress:(void (^)(NSProgress *))progressBlock
                                 responesBlock:(void (^)(id))responseBlock
                                  failuerBlcok:(void (^)(NSError *))failureBlck {
    //    如果传图片统一压缩 具体的压缩比例待定 这边可以对图片进行统一处理
    if ([image isKindOfClass:[UIImage class]]) {
        UIImage *_image = (UIImage *)image;
        image = UIImageJPEGRepresentation(_image, 0.6);
    }
    NSURLSessionDataTask *task = [self uploadFileWithApiName:apiName
                                                        file:image
                                                  parameters:nil
                                                        name:keyName
                                                  fileSuffix:@"jpg"
                                                    mimeType:@"image/jpeg"
                                                    progress:progressBlock
                                               responesBlock:responseBlock failuerBlcok:failureBlck];
    
    return task;
    
}
- (NSURLSessionDataTask *)uploadFileWithApiName:(NSString *)apiName
                                           file:(NSData *)file
                                     parameters:(id)parameters
                                           name:(NSString *)name
                                     fileSuffix:(NSString *)fileSuffix
                                       mimeType:(NSString *)mimeType
                                       progress:(void (^)(NSProgress *))progressBlock
                                  responesBlock:(void (^)(id))responseBlock
                                   failuerBlcok:(void (^)(NSError *))failureBlck {
    NSString  *fileName = [NSString stringWithFormat:@"%ld.%@", (long)([[NSDate date] timeIntervalSince1970]),fileSuffix];
    NSMutableDictionary *params = [self getPublicParametersWithDic:parameters];
#warning requestUrl
    NSString *requestUrl = @"";
    NSURLSessionDataTask *task = nil;
    @weakify(self);
    task = [_network uploadWithURL:requestUrl
                        parameters:params
         constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
             [formData appendPartWithFileData:file name:name fileName:fileName mimeType:mimeType];
         }
                          progress:^(NSProgress *progress) {
                              NSLog(@"🍺🍺🍺🍺🍺上传了 %lld ,%lld 比例: %f \n",progress.totalUnitCount ,progress.completedUnitCount,progress.fractionCompleted);
                              BLOCK_EXEC(progressBlock,progress);
                              
                          }
                           success:^(NSURLSessionDataTask *task, id response) {
                               
                               BLNetworkingLog(params, requestUrl, response);
                               [self.runTaskArray removeObject:task];
                               [self handlerResponse:response
                                          isNeedDeal:NO
                                       responesBlock:responseBlock
                                        failuerBlcok:failureBlck];
                               
                           }
                           failure:^(NSURLSessionDataTask *task, NSError *error) {
                               @strongify(self);
                               [self.runTaskArray removeObject:task];
                               BLNetworkingErrorLog(params, requestUrl, error);
                               BLOCK_EXEC(failureBlck,error);
                               
                           }];
    [self.runTaskArray addObject:task];
    return task;
    
}
- (void)downloadWithApiName:(NSString *)apiName
                destination:(NSURL *(^)(NSURL *, NSURLResponse *))destination
                   progress:(void (^)(NSProgress *))progressBlock
          completionHandler:(void (^)(NSURLResponse *, NSURL *, NSError *))completionBlock {
    
    NSString *requestUrl = @"";
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    @weakify(self);
    __block NSURLSessionDownloadTask *downloadTask = nil;
    downloadTask = [_network.manager downloadTaskWithRequest:request progress:progressBlock destination:destination completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        @strongify(self);
        NSLog(@"downloadfile path 🍺🍺🍺🍺🍺🍺🍺%@🍺🍺🍺🍺🍺\n",filePath);
        [self.runTaskArray removeObject:downloadTask];
        BLOCK_EXEC(completionBlock,response,filePath,error);
    }];
    [downloadTask resume];
    [self.runTaskArray addObject:downloadTask];
    
}
- (void)groupTaskWithConfiguration:(NSArray<BLGroupTaskConfiguration *> *)configurations
                       groupNotify:(void (^)(void))notify {
    [_network groupTaskWithConfiguration:configurations groupNotify:notify];
    
}
/**
 取消所有操作
 */
- (void)cancelAllCurrentRunTask {
    for (NSURLSessionTask *task in self.runTaskArray) {
        if ([task isKindOfClass:[NSURLSessionDataTask class]]) {
            [task cancel];
        }
    }
}
#pragma mark - 私有方法
- (NSURLSessionDataTask *)GETRequestWithApiName:(NSString *)apiName
                                         isJson:(BOOL)isJson
                                       isFromBL:(BOOL)isFromBL
                                     isNeedDeal:(BOOL)isNeedDeal
                                     parameters:(id)parameters
                                  responesBlock:(void (^)(id))responseBlock
                                   failuerBlcok:(void (^)(NSError *))failureBlck {
    _network.manager.requestSerializer = isJson ? [AFJSONRequestSerializer serializer] :[AFHTTPRequestSerializer serializer];
    NSMutableDictionary *params = [self getPublicParametersWithDic:parameters];
    
    NSString *requestUrl = isFromBL ? @"" : apiName;
    NSURLSessionDataTask *task = nil;
    @weakify(self);
    task = [_network GETRequest:requestUrl
                     parameters:params
                        success:^(NSURLSessionDataTask *task, id response) {
                            @strongify(self);
                            BLNetworkingLog(params, requestUrl, response);
                            [self.runTaskArray removeObject:task];
                            [self handlerResponse:response
                                       isNeedDeal:isNeedDeal
                                    responesBlock:responseBlock
                                     failuerBlcok:failureBlck];
                            
                        }
                        failure:^(NSURLSessionDataTask *task, NSError *error) {
                            @strongify(self);
                            [self.runTaskArray removeObject:task];
                            BLNetworkingErrorLog(params, requestUrl, error);
                            BLOCK_EXEC(failureBlck,error);
                        }];
    [self.runTaskArray addObject:task];
    return task;
    
}
- (NSURLSessionDataTask *)POSTRequestWithApiName:(NSString *)apiName
                                          isJson:(BOOL)isJson
                                        isFromBL:(BOOL)isFromBL
                                      isNeedDeal:(BOOL)isNeedDeal
                                      parameters:(id)parameters
                                   responesBlock:(void (^)(id))responseBlock
                                    failuerBlcok:(void (^)(NSError *))failureBlck {
    _network.manager.requestSerializer = isJson ? [AFJSONRequestSerializer serializer] :[AFHTTPRequestSerializer serializer];
    NSMutableDictionary *params = [self getPublicParametersWithDic:parameters];
    NSString *requestUrl = isFromBL ? @"" : apiName;
    NSURLSessionDataTask *task = nil;
    @weakify(self);
    task = [_network POSTRequest:requestUrl
                      parameters:params
                         success:^(NSURLSessionDataTask *task, id response) {
                             @strongify(self);
                             BLNetworkingLog(params, requestUrl, response);
                             [self.runTaskArray removeObject:task];
                             [self handlerResponse:response
                                        isNeedDeal:isNeedDeal
                                     responesBlock:responseBlock
                                      failuerBlcok:failureBlck];
                             
                         }
                         failure:^(NSURLSessionDataTask *task, NSError *error) {
                             @strongify(self);
                             [self.runTaskArray removeObject:task];
                             BLNetworkingErrorLog(params, requestUrl, error);
                             BLOCK_EXEC(failureBlck,error);
                             
                         }];
    [self.runTaskArray addObject:task];
    return task;
    
}
/**
 处理返回的请求
 
 @param response 返回的东西
 @param responseBlock 成功回调
 @param failureBlck 失败的回调
 */
- (void)handlerResponse:(id)response
             isNeedDeal:(BOOL)isNeedDeal
          responesBlock:(void(^)(id response))responseBlock
           failuerBlcok:(void(^)(NSError *error))failureBlck
{
    if (![response isKindOfClass:[NSDictionary class]]) {
        BLOCK_EXEC(failureBlck,BLNetworkError(-1, @"服务器返回数据异常!"));
        return;
    }
    if (isNeedDeal) {
        BOOL isSuccess = [response[@"success"] boolValue];
        if (isSuccess) {
            BLOCK_EXEC(responseBlock,response);
        } else {
//            处理token过期的操作
            if (!kStringIsEmpty(response[@"alertMsg"])) {
                if ([response[@"code"] integerValue] == 4) {

                }
                BLOCK_EXEC(failureBlck,BLNetworkError([response[@"code"] integerValue], response[@"alertMsg"]))
            } else if (!kStringIsEmpty(response[@"error-message"])) {
                BLOCK_EXEC(failureBlck,BLNetworkError(101, response[@"error-message"]))
            } else {
                BLOCK_EXEC(failureBlck,BLNetworkError(1, @"服务器开了个小差"))
            }
        }

    } else {
//        处理token过期的操作
        BOOL isSuccess = [response[@"success"] boolValue];
        if (!isSuccess) {
            if (!kStringIsEmpty(response[@"alertMsg"])) {
                if ([response[@"code"] integerValue] == 4) {
             
                }
                BLOCK_EXEC(failureBlck,BLNetworkError([response[@"code"] integerValue], response[@"alertMsg"]))
            }
        }
        BLOCK_EXEC(responseBlock,response);
    }
}

/**
 添加请求的公共参数
 
 @param dic 原始参数
 @return 入参
 */
- (NSMutableDictionary *)getPublicParametersWithDic:(NSDictionary *)dic {
    
    return [NSMutableDictionary dictionaryWithDictionary:dic];
}


#pragma mark - 懒加载
- (NSMutableArray *)runTaskArray {
    if (!_runTaskArray) {
        _runTaskArray = [NSMutableArray array];
    }
    return _runTaskArray;
}
@end
