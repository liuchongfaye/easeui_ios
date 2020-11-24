//
//  EMMessageCell.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/25.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMMessageCell.h"

#import "EMMessageStatusView.h"

#import "EMMsgTextBubbleView.h"
#import "EMMsgImageBubbleView.h"
#import "EMMsgAudioBubbleView.h"
#import "EMMsgVideoBubbleView.h"
#import "EMMsgLocationBubbleView.h"
#import "EMMsgFileBubbleView.h"
#import "EMMsgExtGifBubbleView.h"

@interface EMMessageCell()

@property (nonatomic, strong) UIImageView *avatarView;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) EMMessageStatusView *statusView;

@property (nonatomic, strong) UIButton *readReceiptBtn;//阅读回执按钮

@property (nonatomic, strong) EMViewModel *viewModel;

@end

@implementation EMMessageCell

- (instancetype)initWithDirection:(EMMessageDirection)aDirection
                             type:(EMMessageType)aType
                        viewModel:(EMViewModel*)viewModel

{
    NSString *identifier = [EMMessageCell cellIdentifierWithDirection:aDirection type:aType];
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    if (self) {
        _direction = aDirection;
        _viewModel = viewModel;
        [self _setupViewsWithType:aType];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Class Methods

+ (NSString *)cellIdentifierWithDirection:(EMMessageDirection)aDirection
                                     type:(EMMessageType)aType
{
    NSString *identifier = @"EMMsgCellDirectionSend";
    if (aDirection == EMMessageDirectionReceive) {
        identifier = @"EMMsgCellDirectionRecv";
    }
    
    if (aType == EMMessageTypeText || aType == EMMessageTypeExtCall) {
        identifier = [NSString stringWithFormat:@"%@Text", identifier];
    } else if (aType == EMMessageTypeImage) {
        identifier = [NSString stringWithFormat:@"%@Image", identifier];
    } else if (aType == EMMessageTypeVoice) {
        identifier = [NSString stringWithFormat:@"%@Voice", identifier];
    } else if (aType == EMMessageTypeVideo) {
        identifier = [NSString stringWithFormat:@"%@Video", identifier];
    } else if (aType == EMMessageTypeLocation) {
        identifier = [NSString stringWithFormat:@"%@Location", identifier];
    } else if (aType == EMMessageTypeFile) {
        identifier = [NSString stringWithFormat:@"%@File", identifier];
    } else if (aType == EMMessageTypeExtGif) {
        identifier = [NSString stringWithFormat:@"%@ExtGif", identifier];
    } else if (aType == EMMessageTypeCustom) {
        identifier = [NSString stringWithFormat:@"%@Custom", identifier];
    }
    
    return identifier;
}

#pragma mark - Subviews

- (void)_setupViewsWithType:(EMMessageType)aType
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
    
    _avatarView = [[UIImageView alloc] init];
    _avatarView.contentMode = UIViewContentModeScaleAspectFit;
    _avatarView.backgroundColor = [UIColor clearColor];
    _avatarView.userInteractionEnabled = YES;
    if (_viewModel.avatarStyle == RoundedCorner) {
        _avatarView.layer.cornerRadius = _viewModel.avatarCornerRadius;
    }
    if (_viewModel.avatarStyle == Circular) {
        _avatarView.layer.cornerRadius = _viewModel.avatarLength / 2;
    }
    [self.contentView addSubview:_avatarView];
    if (self.direction == EMMessageDirectionSend) {
        [_avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(15);
            make.right.equalTo(self.contentView).offset(-componentSpacing);
            make.width.height.equalTo(@(_viewModel.avatarLength));
        }];
    } else {
        [_avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(15);
            make.left.equalTo(self.contentView).offset(componentSpacing);
            make.width.height.equalTo(@(_viewModel.avatarLength));
        }];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:13];
        _nameLabel.textColor = [UIColor grayColor];
        if (_model.message.chatType != EMChatTypeChat) {
            [self.contentView addSubview:_nameLabel];
            [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.avatarView);
                make.left.equalTo(self.avatarView.mas_right).offset(8);
                make.right.equalTo(self.contentView).offset(-componentSpacing);
            }];
        }
    }
    
    _bubbleView = [self _getBubbleViewWithType:aType];
    _bubbleView.userInteractionEnabled = YES;
    _bubbleView.clipsToBounds = YES;
    [self.contentView addSubview:_bubbleView];
    if (self.direction == EMMessageDirectionReceive || (_viewModel.msgArrangementStyle == ArrangementlLeft && _model.message.chatType != EMChatTypeGroupChat)) {
        [_bubbleView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (_model.message.chatType != EMChatTypeChat) {
                make.top.equalTo(self.nameLabel.mas_bottom).offset(3);
            } else {
                make.top.equalTo(self.avatarView);
            }
            make.bottom.equalTo(self.contentView).offset(-15);
            make.left.equalTo(self.avatarView.mas_right).offset(componentSpacing);
            make.right.lessThanOrEqualTo(self.contentView).offset(-70);
        }];
    } else {
        [_bubbleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.avatarView);
            make.bottom.equalTo(self.contentView).offset(-15);
            make.left.greaterThanOrEqualTo(self.contentView).offset(70);
            make.right.equalTo(self.avatarView.mas_left).offset(-componentSpacing);
        }];
    }

    _statusView = [[EMMessageStatusView alloc] init];
    [self.contentView addSubview:_statusView];
    if (self.direction == EMMessageDirectionSend) {
        [_statusView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.bubbleView.mas_centerY);
            make.right.equalTo(self.bubbleView.mas_left).offset(-5);
            make.height.equalTo(@(componentSpacing * 2));
        }];
        __weak typeof(self) weakself = self;
        [_statusView setResendCompletion:^{
            if (weakself.delegate && [weakself.delegate respondsToSelector:@selector(messageCellDidResend:)]) {
                [weakself.delegate messageCellDidResend:weakself.model];
            }
        }];
    } else {
        _statusView.backgroundColor = [UIColor redColor];
        _statusView.clipsToBounds = YES;
        _statusView.layer.cornerRadius = 4;
        [_statusView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.bubbleView);
            make.left.equalTo(self.bubbleView.mas_right).offset(5);
            make.width.height.equalTo(@8);
        }];
    }
    
    [self setCellIsReadReceipt];
}

- (void)setCellIsReadReceipt{
    _readReceiptBtn = [[UIButton alloc]init];
    _readReceiptBtn.layer.cornerRadius = 5;
    //[_readReceiptBtn setTitle:self.model.readReceiptCount forState:UIControlStateNormal];
    _readReceiptBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    _readReceiptBtn.backgroundColor = [UIColor lightGrayColor];
    [_readReceiptBtn.titleLabel setTextColor:[UIColor whiteColor]];
    _readReceiptBtn.titleLabel.font = [UIFont systemFontOfSize: 10.0];
    [_readReceiptBtn addTarget:self action:@selector(readReceiptDetilAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_readReceiptBtn];
    if(self.direction == EMMessageDirectionSend) {
        [_readReceiptBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bubbleView.mas_bottom).offset(2);
            make.right.equalTo(self.bubbleView.mas_right);
            make.width.equalTo(@130);
            make.height.equalTo(@15);
        }];
    }
}

- (EMMessageBubbleView *)_getBubbleViewWithType:(EMMessageType)aType
{
    EMMessageBubbleView *bubbleView = nil;
    switch (aType) {
        case EMMessageTypeText:
        case EMMessageTypeExtCall:
            bubbleView = [[EMMsgTextBubbleView alloc] initWithDirection:self.direction type:aType viewModel:_viewModel];
            break;
        case EMMessageTypeImage:
            bubbleView = [[EMMsgImageBubbleView alloc] initWithDirection:self.direction type:aType viewModel:_viewModel];
            break;
        case EMMessageTypeVoice:
            bubbleView = [[EMMsgAudioBubbleView alloc] initWithDirection:self.direction type:aType viewModel:_viewModel];
            break;
        case EMMessageTypeVideo:
            bubbleView = [[EMMsgVideoBubbleView alloc] initWithDirection:self.direction type:aType viewModel:_viewModel];
            break;
        case EMMessageTypeLocation:
            bubbleView = [[EMMsgLocationBubbleView alloc] initWithDirection:self.direction type:aType viewModel:_viewModel];
            break;
        case EMMessageTypeFile:
            bubbleView = [[EMMsgFileBubbleView alloc] initWithDirection:self.direction type:aType viewModel:_viewModel];
            break;
        case EMMessageTypeExtGif:
            bubbleView = [[EMMsgExtGifBubbleView alloc] initWithDirection:self.direction type:aType viewModel:_viewModel];
            break;
        case EMMessageTypeCustom:
            break;
        default:
            break;
    }
    if (bubbleView) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bubbleViewTapAction:)];
        [bubbleView addGestureRecognizer:tap];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(bubbleViewLongPressAction:)];
        [bubbleView addGestureRecognizer:longPress];
    }
    
    return bubbleView;
}

#pragma mark - Setter

- (void)setModel:(EMMessageModel *)model
{
    _model = model;
    self.bubbleView.model = model;
    if (model.direction == EMMessageDirectionSend) {
        [self.statusView setSenderStatus:model.message.status isReadAcked:model.message.isReadAcked];
    } else {
        if (model.userDataDelegate.Nickname && [model.userDataDelegate.Nickname length] != 0) {
            self.nameLabel.text = model.userDataDelegate.Nickname;
        } else {
            self.nameLabel.text = model.message.from;
        }
        if (model.type == EMMessageBodyTypeVoice) {
            self.statusView.hidden = model.message.isReadAcked;
        }
    }
    if (model.userDataDelegate.avatarImg) {
        _avatarView.image = model.userDataDelegate.avatarImg;
    } else {
        _avatarView.image = [UIImage imageNamed:@"defaultAvatar"];
    }
    if (model.message.isNeedGroupAck) {
        self.readReceiptBtn.hidden = NO;
        [self.readReceiptBtn setTitle:_model.readReceiptCount forState:UIControlStateNormal];
    } else{
        self.readReceiptBtn.hidden = YES;
    }
}

#pragma mark - Action

- (void)readReceiptDetilAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageReadReceiptDetil:)]) {
        [self.delegate messageReadReceiptDetil:self];
    }
}

- (void)bubbleViewTapAction:(UITapGestureRecognizer *)aTap
{
    if (aTap.state == UIGestureRecognizerStateEnded) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(messageCellDidSelected:)]) {
            [self.delegate messageCellDidSelected:self];
        }
    }
}

- (void)bubbleViewLongPressAction:(UILongPressGestureRecognizer *)aLongPress
{
    if (aLongPress.state == UIGestureRecognizerStateBegan) {
        if (self.model.type == EMMessageTypeText) {
            EMMsgTextBubbleView *textBubbleView = (EMMsgTextBubbleView*)self.bubbleView;
            textBubbleView.textLabel.backgroundColor = [UIColor colorWithRed:156/255.0 green:206/255.0 blue:243/255.0 alpha:1.0];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(messageCellDidLongPress:)]) {
            [self.delegate messageCellDidLongPress:self];
        }
    }
}

@end