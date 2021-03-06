//
//  RechargeActions.swift
//  cybexMobile
//
//  Created DKM on 2018/6/5.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import RxCocoa
import RxSwift

// MARK: - State

struct RechargeState: BaseState {
    var pageState: BehaviorRelay<PageState> = BehaviorRelay(value: .initial)
    var context: BehaviorRelay<RouteContext?> = BehaviorRelay(value: nil)
    var withdrawIds: BehaviorRelay<[Trade]> = BehaviorRelay(value: [])
    var depositIds: BehaviorRelay<[Trade]> = BehaviorRelay(value: [])
    var withdrawData: BehaviorRelay<[Trade]> = BehaviorRelay(value: [])
    var depositData: BehaviorRelay<[Trade]> = BehaviorRelay(value: [])
    var isEmpty: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var sortedName: BehaviorRelay<String> = BehaviorRelay(value: "")
}

struct FecthWithdrawIds: Action {
    let data: [Trade]
}

struct FecthDepositIds: Action {
    let data: [Trade]
}

struct SortedByEmptyAssetAction: Action {
    let data: Bool
}

struct SortedByNameAssetAction: Action {
    let data: String
}

// MARK: - Action Creator
class RechargePropertyActionCreate: LoadingActionCreator {
    public typealias ActionCreator = (_ state: RechargeState, _ store: Store<RechargeState>) -> Action?

    public typealias AsyncActionCreator = (
        _ state: RechargeState,
        _ store: Store <RechargeState>,
        _ actionCreatorCallback: @escaping ((ActionCreator) -> Void)
        ) -> Void
}
