//___FILEHEADER___

import Foundation
import EnolaGay
import ReactorKit
import RxCocoa

/// <#反应器#>
final class ___FILEBASENAMEASIDENTIFIER___: Reactor {

    enum Action {
        /// 载入初始数据
        case loadData
        /// 加载下一页
        case loadNextPage
    }
    
    enum Mutation {
        /// 设置数据源
        case setDataSource(result: Result<([<#Model#>], Int?), AppError>)
        /// 添加数据源
        case appendDataSource(result: Result<([<#Model#>], Int?), AppError>)
        
        /// 设置当前加载数据的刷新状态
        case setRefreshStatus(refreshType: RefreshAction)
    }

    struct State {
        /// 下一页页码
        var nextPage: Int?
        /// 当前加载数据的引发方式
        var refreshAction = RefreshAction.none
        /// 是否没有更多数据
        var isNoMoreData: Bool { nextPage == nil }

        /// 数据源
        var dataSource = [<#PraiseModel#>]()
    }
    
    let initialState = State()
    
    
    func mutate(action: Action) -> Observable<Mutation> {
        guard let token = User.token else { return Observable.just(Mutation.setRefreshStatus(refreshType: .none)) }

        switch action {
        case .loadData:
            let request = MyCircleListRequest(token: token, pageNum: 1)
            return Observable.concat([
                request.dataPublisher
                    .map { Mutation.setDataSource(result: $0) },
                // 设置刷新状态为下拉刷新
                Observable.just(Mutation.setRefreshStatus(refreshType: .pullDown)),
            ])
        case .loadNextPage:
            guard let page = currentState.nextPage else {
                return Observable.just(Mutation.setRefreshStatus(refreshType: .none))
            }
            
            let request = MyCircleListRequest(token: token, pageNum: 1)
            return Observable.concat([
                request.dataPublisher
                    .map { Mutation.appendDataSource(result: $0) },
                Observable.just(Mutation.setRefreshStatus(refreshType: .pullUp)),
            ])
        }
    }

    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setDataSource(let result):
            switch result {
            case .success((let list, let nextPage)):
                newState.dataSource = list
                newState.nextPage = nextPage
            case .failure(let error):
                logWarning(error.localizedDescription)
            }
            
        case .appendDataSource(result: let result):
            switch result {
            case .success((let list, let nextPage)):
                newState.dataSource.append(contentsOf: list)
                newState.nextPage = nextPage
            case .failure(let error):
                logWarning(error.localizedDescription)
            }
            
        case .setRefreshStatus(refreshType: let refreshType):
            newState.refreshAction = refreshType
            
        }
        return newState
    }

}
