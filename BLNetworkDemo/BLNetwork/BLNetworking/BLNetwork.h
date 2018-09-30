//
//  BLNetwork.h
//  BLFast
//
//  Created by lightning on 2018/6/27.
//  Copyright © 2018年 lightning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

/**
 变啦网络请求方式

 - BLHTTPMethodGET: get请求方式
 - BLHTTPMethodPOST: post请求方式
 */
typedef NS_ENUM(NSInteger, BLHTTPMethod) {
    BLHTTPMethodGET,
    BLHTTPMethodPOST
};

/**
 成功回调

 @param task 任务
 @param response 响应结果
 */
typedef void(^SuccessBlock)(NSURLSessionDataTask *task,id response);

/**
 失败回调

 @param task 任务
 @param error 失败错误
 */
typedef void(^FailureBlock)(NSURLSessionDataTask *task,NSError *error);

/**
 变啦组任务配置
 */
@interface BLGroupTaskConfiguration : NSObject

/**
 请求方式
 */
@property (nonatomic, assign) BLHTTPMethod method;

/**
 请求链接
 */
@property (nonatomic, strong) NSString *url;

/**
 请求参数
 */
@property (nonatomic, strong) NSDictionary *parameters;

/**
 成功回调
 */
@property (nonatomic, copy) SuccessBlock successBlock;

/**
 失败回调
 */
@property (nonatomic, copy) FailureBlock failBlock;


/**
 添加构建配置

 @param method 请求方式
 @param url 请求api
 @param parameters 请求参数
 @param success 成功回调
 @param fail 失败回调
 */
- (void)addConfigurationWithMethod:(BLHTTPMethod)method
                           apiName:(NSString *)url
                        parameters:(NSDictionary *)parameters
                           success:(SuccessBlock)success
                              fail:(FailureBlock)fail;
@end


@interface BLNetwork : NSObject

/**
 AFN的管理类
 */
@property (nonatomic, strong, readonly) AFHTTPSessionManager *manager;

/**
 约定外部初始化方式禁止通过init的方式创建

 @return 实例对象
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 工厂创建方法

 @return 当前类
 */
+ (instancetype)network;


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
                             failure:(FailureBlock)failure;

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
                              failure:(FailureBlock)failure;

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
                                         failure:(FailureBlock)failure;

/**
 组任务

 @param configurations 配置组任务
 @param notify 任务回调
 */
- (void)groupTaskWithConfiguration:(NSArray<BLGroupTaskConfiguration*> *)configurations
                       groupNotify:(void(^)(void))notify;


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
                                failure:(FailureBlock)failure;

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
                            completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler;

/**
 联网状态

 @return YES 网络正常 NO 网络不可用
 */
- (BOOL)checkNetworkIsAvailable;



@end
