//___FILEHEADER___

import UIKit
import EnolaGay
import ReactorKit
import RxCocoa
import RxSwift

/// <#界面名称#>
class ___FILEBASENAMEASIDENTIFIER___: UIViewController, StoryboardView {

    // MARK: - let property and IBOutlet
    @IBOutlet var tableView: UITableView!

    // MARK: - public var property
    
    var disposeBag = DisposeBag()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .red
        tableView.backgroundColor = .red
        
        tableView.rowHeight = UITableView.automaticDimension    // 155
        // 注册 Cell
        tableView.register(UINib(nibName: "InRoopBaseCell", bundle: nil), forCellReuseIdentifier: "Cell")

        reactor?.action.onNext(.loadData)

    }

    
    func bind(reactor: <#Reactor#>) {
        
        // State 绑定到 View
        
        // 将结果输出到列表页上
        reactor.state.map { $0.dataSource }
            .bind(to: tableView.rx.items(cellIdentifier: "Cell")) { [weak self] index, model, cell in
                if let cell = cell as? InRoopBaseCell {
                    cell.setModel(model: model)
                }
            }
            .disposed(by: disposeBag)

        // View/用户事件绑定到 action
        
        // 当用户点击某一条搜索结果
//        tableView.rx.itemSelected
//            .subscribe(onNext: { [weak self, weak reactor] indexPath in
//                guard let `self` = self else { return }
//                self.view.endEditing(true)
//                self.tableView.deselectRow(at: indexPath, animated: false)
//                guard let model = reactor?.currentState.dataSource[indexPath.row] else { return }
//
//            })
//            .disposed(by: disposeBag)

        
        // 将上下拉刷新开始的事件绑定到 action
        tableView.rx.reloadAction
            .map { Reactor.Action.loadData }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        tableView.rx.loadMoreAction
            .map { Reactor.Action.loadNextPage }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)


        // 将上下拉刷新结束的状态绑定到 tableView
        reactor.state
            .map { ($0.refreshAction, $0.isNoMoreData) }
            .bind(to: tableView.rx.endRefresh)
            .disposed(by: disposeBag)
    }


    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destinationViewController.
         // Pass the selected object to the new view controller.
     }
     */
    
}
