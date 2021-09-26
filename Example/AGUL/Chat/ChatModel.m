//
//  ChatModel.m
//  UUChatTableView
//
//  Created by shake on 15/1/6.
//  Copyright (c) 2015年 uyiuyao. All rights reserved.
//

#import "ChatModel.h"

#import "UUMessage.h"
#import "UUMessageFrame.h"

@implementation ChatModel

- (void)populateRandomDataSource {
    self.dataSource = [NSMutableArray array];
    [self.dataSource addObjectsFromArray:[self additems:5]];
}

- (void)addRandomItemsToDataSource:(NSInteger)number{
    
    for (int i=0; i<number; i++) {
        [self.dataSource insertObject:[[self additems:1] firstObject] atIndex:0];
    }
}

- (void)recountFrame {
	[self.dataSource enumerateObjectsUsingBlock:^(UUMessageFrame * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		obj.message = obj.message;
	}];
}

// 添加自己的item
- (void)addSpecifiedItem:(NSDictionary *)dic {
    UUMessageFrame *messageFrame = [[UUMessageFrame alloc]init];
    UUMessage *message = [[UUMessage alloc] init];
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    
    NSString *URLStr = @"https://avatars3.githubusercontent.com/u/12079614?s=460&v=4";//@"http://img0.bdstatic.com/img/image/shouye/xinshouye/mingxing16.jpg";
    [dataDic setObject:@(UUMessageFromMe) forKey:@"from"];
    [dataDic setObject:[[NSDate date] description] forKey:@"strTime"];
	[dataDic setObject:@"Judy" forKey:@"strName"];
    [dataDic setObject:URLStr forKey:@"strIcon"];
    
    [message setWithDict:dataDic];
    [message minuteOffSetStart:previousTime end:dataDic[@"strTime"]];
    messageFrame.showTime = message.showDateLabel;
    [messageFrame setMessage:message];
    
    if (message.showDateLabel) {
        previousTime = dataDic[@"strTime"];
    }
    [self.dataSource addObject:messageFrame];
}

// 添加聊天item（一个cell内容）
static NSString *previousTime = nil;
- (NSArray<UUMessageFrame *> *)additems:(NSInteger)number {
    
    NSMutableArray<UUMessageFrame *> *result = [NSMutableArray array];
    NSArray *contentList = [[NSArray alloc]initWithObjects:
                            @"这个App怎么了？",
                            @"这个App被我限制使用了，只有不到20%的几率可以正常进入界面。",
                            @"有没有恢复的方法？",
                            @"当然有，而且很简单。只要吾诺瀚卓赶紧把所有拖欠的工资发了就可以恢复正常使用。",
                            @"那么你是谁？",
                            @"我是吾诺瀚卓所有未及时收到工资的员工代表。",
                            @"为什么这么做？",
                            @"吾诺瀚卓拖欠我们好几个月的工资，现在我们都没法生活了。",
                            @"不是说了这个月30号一定会发你们去年的工资吗？",
                            @"你们每个月都说这个月30号发。",
                            @"这次是真的，2018年6月30号一定会准时发工资。",
                            @"4月份也说是真的，结果连3月份的工资还没发。",
                            @"如果这个月还没有发，那就是因为这次公司旅游，推后几天，我们旅游回来就发，绝对不会拖太久，且把之前未发的工资一次性补上。",
                            @"顾灵波和吕庆私下跟我说要提拔我，给我升职加薪，这招缓兵之计估计你们都用烂了吧？",
                            @"你们可以直接来找我，不要乱动客户的App，你私底下来跟我谈好吗？",
                            @"跟你们谈了一年多了，还谈啥，是不是又要给我们画大饼说两个月后让我当CEO？请先把工资发了再谈。",
                            @"告诉我你到底是谁？",
                            @"我说过，我是吾诺瀚卓所有未及时收到工资的员工代表。",
                            @"这样吧，找个时间我们单独谈谈，公司马上要搬迁了，到时候让你做APP部门经理，有信心吗？",
                            @"好的。发了工资我一定会找个星巴克约你谈谈APP部门经理的事情。",
                            @"为什么非要用这种卑鄙无耻下流的手段？你们从加入我们吾诺瀚卓开始，就注定了一个愿打一个愿挨。既然加入了就要为吾诺瀚卓卖命，就要无条件为吾诺瀚卓无私奉献，在要工资前，你们就不想想你们值得这些工资吗？这点困难都扛不住趁早滚出吾诺瀚卓！",
                            @"那我愿打，你可愿挨？我们只想告诉你，欠债还钱，杀人偿命。",
                            @"他娘的，你到底要怎么样？我们吾诺瀚卓一百多号员工，成立九年之久，还会欠你们这点钱吗？不就拖欠了不到一年就他妈叽叽歪歪，还搞手段！这算什么本事？吾诺瀚卓一百多号员工，成立九年之久。里面哪个人不是兢兢业业废寝忘食，为什么人家就可以做的半年不发工资依然如此为吾诺瀚卓卖命，而你才几个月没发工资？你们这点小命值几个钱？说难听点就是古代的叫花子，贱命一条。你们那点劳动力也就那样，人家有的人连续通宵好几天都不带喊累的，你们呢，才通几个宵就一个个叫困，至于吗？不要以为吾诺瀚卓离开了你们就会倒闭。哪怕现在就把整个技术部开除了，分分钟招来一帮愿意全天28个小时在公司工作的优秀员工，且个个比你们出色，还不发牢骚。看你们一个个贱婢样的，身在福中不知福。虽然说是早上8:30上班，晚上6点下班，但周末可以9点到啊。每天加班到晚上10点我们会为你点外卖，你看看别的公司哪家能做到？而且吾诺瀚卓加班到半夜的第二天可以晚到半小时，加班到凌晨3点的可以第二天下午来上班，试问还有哪家公司能做到如此出类拔萃超群绝伦？",
                            @"公司成立九年之久，看来得罪了不少人，不过我们并不关心。既然不会欠这点钱，那你倒是赶紧还啊，啰嗦一大堆不就是想赖账。九年了，估计糟蹋了不少客户和员工吧？我和一个朋友合租，她也是每天八小时工作时间。但是今年我至少有3个月的时间没有在白天见过她了，晚上我回家的时候她已经睡着了，早上我上班的时候她还没醒，我都忙成啥了？别说什么谈恋爱结婚生孩子了，连他妈生病都得挑日子生。明天她要出国旅游了，吾诺瀚卓居然连我们的工资都没发！你们这狗屁公司还有没有人性？别一天到晚拿那什么拼命三郎的精神来忽悠人。命只有一条，就算拼，也不拼给你们这种即无耻又混蛋的公司，吾诺瀚卓压根配不上！",
                            @"行了，啥也甭说了。等我们公司再坑到几个客户打款了就给你们发工资。",
                            @"请耐心等待法院执行通知书。谢谢",
                            nil];
    
    for (int i=0; i<contentList.count; i++) {
        
//        NSDictionary *dataDic = [self getDic];
        /* 此处自定义消息内容 */
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        
        // 设置文本消息
        [dictionary setObject:contentList[i] forKey:@"strContent"];

        // TODO: 此处设置消息来源：对方还是自己
        
        int userType = UUMessageFromMe;
        if (i%2 == 0) {
            userType = UUMessageFromOther;
        } else {
            userType = UUMessageFromMe;
        }
        
        [dictionary setObject:@(userType) forKey:@"from"];
        // TODO: 设置用户名及头像
        if (userType == 0){  // 自己
            [dictionary setObject:@"孙悟空" forKey:@"strName"];
            [dictionary setObject:@"me.jpg" forKey:@"strIcon"];
        } else {    // 对方
            [dictionary setObject:@"吾诺瀚卓" forKey:@"strName"];
            [dictionary setObject:@"unohacha.jpg" forKey:@"strIcon"];
        }
        
        // TODO: 此处设置消息类型
        [dictionary setObject:@(UUMessageTypeText) forKey:@"type"];

        // TODO: 此处设置消息时间
        NSDate *date = [[NSDate date]dateByAddingTimeInterval:arc4random()%1000*(dateNum++) ];
        [dictionary setObject:[date description] forKey:@"strTime"];
        
        UUMessageFrame *messageFrame = [[UUMessageFrame alloc]init];
        UUMessage *message = [[UUMessage alloc] init];
        [message setWithDict:dictionary];
        [message minuteOffSetStart:previousTime end:dictionary[@"strTime"]];
        // 不显示时间
        messageFrame.showTime = message.showDateLabel;//false;//message.showDateLabel;
        [messageFrame setMessage:message];
        if (message.showDateLabel) {
            previousTime = dictionary[@"strTime"];
        }
        [result addObject:messageFrame];
    }
    return result;
}

// 如下:群聊（groupChat）
static int dateNum = 10;
- (NSDictionary *)getDic {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    int randomNum = arc4random()%5;
    if (randomNum == UUMessageTypePicture) {
        [dictionary setObject:[UIImage imageNamed:[NSString stringWithFormat:@"%u.jpeg",arc4random()%2]] forKey:@"picture"];
    } else {
        // 文字出现概率4倍于图片（暂不出现Voice类型）
        randomNum = UUMessageTypeText;
        [dictionary setObject:[self getRandomString] forKey:@"strContent"];
    }
    NSDate *date = [[NSDate date]dateByAddingTimeInterval:arc4random()%1000*(dateNum++) ];
    // 此处设置消息来源：对方还是自己
    [dictionary setObject:@(UUMessageFromOther) forKey:@"from"];
    [dictionary setObject:@(randomNum) forKey:@"type"];
    [dictionary setObject:[date description] forKey:@"strTime"];
    // 这里判断是否是私人会话、群会话
    int index = _isGroupChat ? arc4random()%6 : 0;
    [dictionary setObject:[self getName:index] forKey:@"strName"];
    [dictionary setObject:[self getImageStr:index] forKey:@"strIcon"];
    
    return dictionary;
}

- (NSString *)getRandomString {
    /*
    NSString *lorumIpsum = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent non quam ac massa viverra semper. Maecenas mattis justo ac augue volutpat congue. Maecenas laoreet, nulla eu faucibus gravida, felis orci dictum risus, sed sodales sem eros eget risus. Morbi imperdiet sed diam et sodales.";
    
    NSArray *lorumIpsumArray = [lorumIpsum componentsSeparatedByString:@" "];
    
    int r = arc4random() % [lorumIpsumArray count];
    r = MAX(6, r); // no less than 6 words
    NSArray *lorumIpsumRandom = [lorumIpsumArray objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, r)]];
    */
    return @"大家好我是VAE，这是我即将发表的首张独创专辑自定义里面的一首推荐曲目，词曲编曲都是我自己，希望这首歌曲，能在这个寒冷的冬天带给大家一种温暖的感觉";//[NSString stringWithFormat:@"%@!!", [lorumIpsumRandom componentsJoinedByString:@" "]];
}

- (NSString *)getImageStr:(NSInteger)index{
    /*
    NSArray *array = @[@"http://www.120ask.com/static/upload/clinic/article/org/201311/201311061651418413.jpg",
                       @"http://p1.qqyou.com/touxiang/uploadpic/2011-3/20113212244659712.jpg",
                       @"http://www.qqzhi.com/uploadpic/2014-09-14/004638238.jpg",
                       @"http://e.hiphotos.baidu.com/image/pic/item/5ab5c9ea15ce36d3b104443639f33a87e950b1b0.jpg",
                       @"http://ts1.mm.bing.net/th?&id=JN.C21iqVw9uSuD2ZyxElpacA&w=300&h=300&c=0&pid=1.9&rs=0&p=0",
                       @"http://ts1.mm.bing.net/th?&id=JN.7g7SEYKd2MTNono6zVirpA&w=300&h=300&c=0&pid=1.9&rs=0&p=0"];
     */
//    return array[index];
    return @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1529573483289&di=d33c54724c9801ce7aaf4beb99e87eb7&imgtype=0&src=http%3A%2F%2Ftva4.sinaimg.cn%2Fcrop.0.0.639.639.180%2F8a7123fejw8f25y2bhuzyj20hs0hrmya.jpg";
}

- (NSString *)getName:(NSInteger)index{
    NSArray *array = @[@"吾诺瀚卓", @"Judy", @"吃瓜群众", @"顾林波", @"林海伦", @"吕庆"];
    return array[index];
}
@end
