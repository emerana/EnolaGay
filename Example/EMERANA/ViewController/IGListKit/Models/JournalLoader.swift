import Foundation

class JournalEntryLoader {
    
    var entries = [Model]()
    
    func loadLatest() {
        
        let entries = [
            Model(
                date: "2019年12月19日16:07:55",
                msg: "大家好我是VAE，这是我即将发表的首张独创专辑自定义里面的一首推荐曲目，词曲编曲都是我自己，希望这首歌曲能在这个寒冷的冬天带给大家一种温暖的感觉。",
                user: "EMERANA"
            ),
            Model(
                date: "2019年12月19日16:17:55",
                msg: "天空好想下雨，我好想住你隔壁,傻站在你家楼下抬起头数乌云，如果场景里出现一架钢琴我会唱歌给你听，哪怕好多盆水往下淋。",
                user: "EnolaGay"
            ),
            Model(
                date: "2019年12月19日16:32:55",
                msg: "夏天快要过去，请你少买冰淇淋，天凉就别穿短裙，别再那么淘气，如果有时不那么开心，我愿意将格洛米借给你，你其实明白我心意。",
                user: "Judy"
            ),
            Model(
                date: "2019年12月19日16:27:55",
                msg: "为你唱这首歌 没有什么风格，它仅仅代表着 我想给你快乐，为你解冻冰河，为你做一只扑火的飞蛾，没有什么事情是不值得，为你唱这首歌 没有什么风格，它仅仅代表着，我希望你快乐，为你辗转反侧 为你放弃世界有何不可，夏末秋凉里带一点温热 有换季的颜色。",
                user: "醉翁之意"
            ),
            Model(
                date: "2019-12-19 17:49:38",
                msg: "风筝误，误了梨花花又开\n风筝误，误了金钗雪里埋\n风筝误，悟满相思挂苍苔\n听雨声，数几声，风会来\n风筝误，误了梨花花又开\n风筝误，捂了金钗雪里埋\n风筝误，悟满相思挂苍苔\n听雨声，数几声，风会来\n风筝误\n悟了一句\n情似露珠\n谁约我，又在这，风烟处\n风筝误。",
                user: "醉翁之意"
            ),
        ]
        self.entries = entries
    }
    
}

//import IGListKit

class Model: NSObject {
    
    let date: String
    let msg: String
    let user: String
    
    init(date: String, msg: String, user: String) {
        self.date = date
        self.msg = msg
        self.user = user
    }
    
}
