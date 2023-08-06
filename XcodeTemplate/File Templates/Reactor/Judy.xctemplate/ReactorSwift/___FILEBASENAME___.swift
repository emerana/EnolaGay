//___FILEHEADER___

import Foundation
import EnolaGay
import ReactorKit
import RxCocoa

/// <#反应器名#>
final class ___FILEBASENAMEASIDENTIFIER___: Reactor {

    enum Action {
        /// 重新载入数据
        case loadData
        /// 加载下一页
        case loadNextPage
    }
    
    enum Mutation {
        /// 设置数据源
        case setDataSource(result: Result<([<#DataSourceModel#>], Int?), AppError>)
        /// 添加数据源
        case appendDataSource(result: Result<([<#DataSourceModel#>], Int?), AppError>)
        
        /// 设置当前加载数据的刷新状态
        case setRefreshStatus(refreshType: RefreshAction)
        /// 结束上下拉刷新状态
        case setEndRefreshStatus
    }
    
    struct State {
        /// 下一页页码
        var nextPage: Int?
        /// 当前加载数据的类型
        var refreshAction = RefreshAction.none
        /// 是否没有更多数据
        var isNoMoreData = false
        
        /// 数据源
        var dataSource = [<#PraiseModel#>]()
    }
    
    let initialState = State()
    
    
    func mutate(action: Action) -> Observable<Mutation> {
        guard User.token != nil else { return Observable.just(Mutation.setEndRefreshStatus) }

        switch action {
//        case .loadData:
//            let praiseRequest = PraiseRequest(token: User.token!, pageNum: 1)
//            return Observable.concat([
//                praiseRequest.praisePublisher
//                    .map { Mutation.setDataSource(result: $0) },
//                // 设置刷新状态为重新载入
//                Observable.just(Mutation.setRefreshStatus(refreshType: .refresh)),
//            ])
        }
    }
    
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setEndRefreshStatus:
            newState.refreshAction = .none
        }
        return newState
    }

}
