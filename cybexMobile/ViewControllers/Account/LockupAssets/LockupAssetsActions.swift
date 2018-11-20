//
//  LockupAssetsActions.swift
//  cybexMobile
//
//  Created DKM on 2018/5/15.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import SwiftyJSON
import RxCocoa
import RxSwift

// MARK: - State
struct LockupAssetsState: BaseState {
    var pageState: BehaviorRelay<PageState> = BehaviorRelay(value: .initial)
    var context: BehaviorRelay<RouteContext?> = BehaviorRelay(value: nil)

    var data: BehaviorRelay<LockUpAssetsVMData> = BehaviorRelay(value: LockUpAssetsVMData(datas: []))
    var ethPrice: Double = 0
}

struct FetchedLockupAssetsData: Action {
  let data: [LockUpAssetsMData]
}

struct LockUpAssetsVMData: Equatable {
  var datas: [LockupAssteData]
}
struct LockupAssteData: Equatable {
  var icon: String = ""
  var name: String = ""
  var amount: String = ""
  var RMBCount: String = ""
  var progress: String = ""
  var endTime: String = ""
}
