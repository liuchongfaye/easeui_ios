//
//  EMChatControllerProducter.h
//  EaseIM
//
//  Created by 娜塔莎 on 2020/8/6.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMChatViewController.h"
#import "EMViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMChatControllerProducter : NSObject

//生产传入对应会话类型参数的会话聊天控制器
+ (EMChatViewController *)getChatControllerInstance:(NSString *)conversationId conversationType:(EMConversationType)conType chatViewModel:(EMViewModel *)viewModel;

@end

NS_ASSUME_NONNULL_END
