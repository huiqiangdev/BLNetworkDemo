//
//  BLNetwork.m
//  BLFast
//
//  Created by lightning on 2018/6/27.
//  Copyright © 2018年 lightning. All rights reserved.
//  网络请求基类

#import "BLNetwork.h"

@implementation BLGroupTaskConfiguration
- (void)addConfigurationWithMethod:(BLHTTPMethod)method
                           apiName:(NSString *)url
                        parameters:(NSDictionary *)parameters
                           success:(SuccessBlock)success
                              fail:(FailureBlock)fail {
    
    _method = method;
#warning 这个地方拼接URL
//    _url = BLRequestUrl(BLBaseUrl, url);
    _parameters = parameters;
    _successBlock = success;
    _failBlock = fail;
    
}
@end

@interface BLNetwork ()

/**
 组任务队列
 */
@property (nonatomic, strong) dispatch_group_t dataGroup;

/**
 任务队列
 */
@property (nonatomic, strong) dispatch_queue_t dataQueue;
@end

@implementation BLNetwork

/**
 约定外部初始化方式禁止通过init的方式创建
 
 @return 实例对象
 */
- (instancetype)init {
    if (self = [super init]) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _manager = [[AFHTTPSessionManager alloc]initWithBaseURL:nil sessionConfiguration:configuration];
        _manager.requestSerializer.timeoutInterval = 30.f;
    }
    return self;
}

/**
 工厂创建方法
 
 @return 当前类
 */
+ (instancetype)network {
    return [[self alloc] init];
}


/**
 Get请求方式
 
 @param url 链接
 @param parameters 参数
 @param success 成功回调
 @param failure 失败回调
 @return 当前任务task
 */
- (NSURLSessionDataTask *)GETRequest:(NSString *)url
                          parameters:(id)parameters
                             success:(SuccessBlock)success
                             failure:(FailureBlock)failure {
    NSURLSessionDataTask *task = [self dataTaskWithHTTPMethod:BLHTTPMethodGET
                                                    URLString:url
                                                   parameters:parameters
                                                      success:success
                                                      failure:failure];
    [task resume];
    return task;
}

/**
 POST请求方式
 
 @param url 链接
 @param parameters 请求参数
 @param success 成功回调
 @param failure 失败回调
 @return 当前task任务
 */
- (NSURLSessionDataTask *)POSTRequest:(NSString *)url
                           parameters:(id)parameters
                              success:(SuccessBlock)success
                              failure:(FailureBlock)failure {
    NSURLSessionDataTask *task = [self dataTaskWithHTTPMethod:BLHTTPMethodPOST
                                                    URLString:url
                                                   parameters:parameters
                                                      success:success
                                                      failure:failure];
    [task resume];
    return task;
    
}

/**
 创建一个网络请求任务
 
 @param method 请求方式
 @param URLString 链接
 @param parameters 参数
 @param success 成功回调
 @param failure 失败回调
 @return dataTask
 */
- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(BLHTTPMethod)method
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                         success:(SuccessBlock)success
                                         failure:(FailureBlock)failure {
    if (![self checkNetworkIsAvailable]) {
//        弹出网络不可用提示
        return [NSURLSessionDataTask new];
    }
    NSString *methodString = @{@(BLHTTPMethodGET):@"GET",
                               @(BLHTTPMethodPOST):@"POST"}[@(method)];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    });
    
    NSURLSessionDataTask *dataTask = [self dataTaskWithHTTPMethod:methodString
                                                        URLString:URLString
                                                       parameters:parameters
                                                   uploadProgress:nil
                                                 downloadProgress:nil
                                                          success:^(NSURLSessionDataTask *task, id response) {
                                                              [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                                              if (success) {
                                                                  success(task, response);
                                                              }
                                                          } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                                              [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                                              if (failure) {
                                                                  failure(task, error);
                                                              }
                                                          }];
    return dataTask;
    
    
}

/**
 组任务
 
 @param configurations 配置组任务
 @param notify 任务回调
 */
- (void)groupTaskWithConfiguration:(NSArray<BLGroupTaskConfiguration*> *)configurations
                       groupNotify:(void(^)(void))notify {
    for (BLGroupTaskConfiguration *configuration in configurations) {
        dispatch_group_enter(self.dataGroup);
        dispatch_group_async(self.dataGroup, self.dataQueue, ^{
            [[self dataTaskWithHTTPMethod:configuration.method
                                URLString:configuration.url
                               parameters:configuration.parameters success:^(NSURLSessionDataTask *task, id response) {
                                   dispatch_group_leave(self.dataGroup);
                                   if (configuration.successBlock) {
                                       configuration.successBlock(task, response);
                                   }
                               } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                   dispatch_group_leave(self.dataGroup);
                                   if (configuration.failBlock) {
                                       configuration.failBlock(task, error);
                                   }
                                   
                               }] resume];
            
        });
    }
    dispatch_group_notify(self.dataGroup, dispatch_get_main_queue(), ^{
        if (notify) {
            notify();
        }
    });
    
}


/**
 上传任务
 
 @param URLString 链接
 @param parameters 参数
 @param block 上传附带的表单数据
 @param uploadProgress 上传进度
 @param success 成功回调
 @param failure 失败回调
 @return 当前任务
 */
- (NSURLSessionDataTask *)uploadWithURL:(NSString *)URLString
                             parameters:(id)parameters
              constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                               progress:(void (^)(NSProgress *progress))uploadProgress
                                success:(SuccessBlock)success
                                failure:(FailureBlock)failure {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    });
    
    NSURLSessionDataTask *task = [_manager POST:URLString
                                     parameters:parameters
                      constructingBodyWithBlock:block
                                       progress:uploadProgress
                                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                            success(task, responseObject);
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                
                                                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                            });
                                        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                            failure(task, error);
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                
                                                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                            });
                                        }];
    return task;
}

/**
 下载任务
 
 @param URLString 链接
 @param downloadProgressBlock 下载进度
 @param destination 文件目标地址
 @param completionHandler 完成操作
 @return 下载任务
 */
- (NSURLSessionDownloadTask *)downLoadWithURL:(NSString *)URLString
                                     progress:(void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                                  destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                            completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler {
    NSURL *URL = [NSURL URLWithString:URLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSessionDownloadTask *downloadTask = nil;
    downloadTask = [_manager downloadTaskWithRequest:request
                                            progress:downloadProgressBlock
                                         destination:destination
                                   completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                                       completionHandler(response, filePath, error);
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           
                                           [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                       });
                                       
                                   }];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    });
    
    [downloadTask resume];
    return downloadTask;
}
- (BOOL)checkNetworkIsAvailable {
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    //开始监测网络状态
    [manager startMonitoring];
    
    //结果回调
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusNotReachable) {
            
            return;
        }
    }];
    
    return YES;
}
#pragma mark - 私有方法

/**
 创建一个dataTask任务
 
 @param method 方法
 @param URLString 链接
 @param parameters 参数
 @param uploadProgress 上传进度
 @param downloadProgress 下载进度
 @param success 成功回调
 @param failure 失败回调
 @return task任务
 */
- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                  uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgress
                                downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgress
                                         success:(void (^)(NSURLSessionDataTask *, id))success
                                         failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [_manager.requestSerializer requestWithMethod:method URLString:[[NSURL URLWithString:URLString relativeToURL:_manager.baseURL] absoluteString] parameters:parameters error:&serializationError];
    if (serializationError) {
        if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(_manager.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
#pragma clang diagnostic pop
        }
        
        return nil;
    }
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [_manager dataTaskWithRequest:request
                              uploadProgress:uploadProgress
                            downloadProgress:downloadProgress
                           completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   if (error) {
                                       if (failure) {
                                           failure(dataTask, error);
                                       }
                                   } else {
                                       if (success) {
                                           success(dataTask, responseObject);
                                       }
                                   }
                               });
                           }];
    return dataTask;
}

#pragma mark - 懒加载

- (dispatch_group_t)dataGroup {
    if (!_dataGroup) {
        _dataGroup = dispatch_group_create();
        
    }
    return _dataGroup;
}
- (dispatch_queue_t)dataQueue {
    if (!_dataQueue) {
        _dataQueue = dispatch_queue_create("com.bianla.data.queue", DISPATCH_QUEUE_PRIORITY_DEFAULT);
    }
    return _dataQueue;
}

@end
