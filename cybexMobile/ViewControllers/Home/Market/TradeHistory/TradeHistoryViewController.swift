//
//  TradeHistoryViewController.swift
//  cybexMobile
//
//  Created koofrank on 2018/4/8.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift
import Localize_Swift

enum TradeHistoryPageType {
    case market
    case trade
}

struct TradeHistoryViewModel {
    var pay: Bool
    var price: String
    var quoteVolume: String
    var baseVolume: String
    var time: String
}

class TradeHistoryViewController: BaseViewController {

    @IBOutlet weak var historyView: TradeHistoryView!

    var coordinator: (TradeHistoryCoordinatorProtocol & TradeHistoryStateManagerProtocol)?

    var pageType: TradeHistoryPageType = .market

    var pair: Pair? {
        didSet {
            if pair != oldValue {
                self.coordinator?.resetData()
            }
            refreshView()
        }
    }

    var data: [TradeHistoryViewModel]? {
        didSet {
            if self.historyView != nil {
                self.historyView.data = data
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupEvent()
    }

    func refreshView() {
        guard let pair = pair, let baseInfo = appData.assetInfo[(pair.base)], let quoteInfo = appData.assetInfo[(pair.quote)] else { return }
        if self.view.width == 320 {
            self.historyView.price.font  = UIFont.systemFont(ofSize: 11)
            self.historyView.amount.font  = UIFont.systemFont(ofSize: 11)
            self.historyView.sellAmount.font  = UIFont.systemFont(ofSize: 11)
            self.historyView.time.font = UIFont.systemFont(ofSize: 11)
        }

        self.historyView.price.text  = R.string.localizable.trade_history_price.key.localized() + "(" + baseInfo.symbol.filterJade + ")"
        self.historyView.amount.text  = R.string.localizable.trade_history_amount.key.localized() + "(" + quoteInfo.symbol.filterJade + ")"
        self.historyView.sellAmount.text  = R.string.localizable.trade_history_total.key.localized() + "(" + baseInfo.symbol.filterJade + ")"
        self.historyView.time.text = R.string.localizable.my_history_time.key.localized()

        self.coordinator?.fetchData(pair)
    }

    func setupEvent() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: LCLLanguageChangeNotification),
                                               object: nil,
                                               queue: nil,
                                               using: { [weak self] _ in
            guard let `self` = self else { return }
            self.refreshView()
        })
    }
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name(rawValue: LCLLanguageChangeNotification),
                                                  object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func configureObserveState() {
        self.coordinator!.state.property.data.asObservable()
            .subscribe(onNext: {[weak self] (_) in
                guard let `self` = self else { return }

                self.convertToData()
                self.coordinator?.updateMarketListHeight(500)
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

    }

    func convertToData() {
        if let data = self.coordinator?.state.property.data.value {
            
            var showData: [TradeHistoryViewModel] = []

            for itemData in data {
                let curData = itemData

                let operation = curData[0]
//                let receive = curData[1]
                let time = curData[1].stringValue
                let pay = operation["pays"]
                let receive = operation["receives"]
                let base = operation["fill_price"]["base"]
                let quote = operation["fill_price"]["quote"]
                let baseInfo = appData.assetInfo[pair!.base]!
                let quoteInfo = appData.assetInfo[pair!.quote]!
                let basePrecision = pow(10, baseInfo.precision)
                let quotePrecision = pow(10, quoteInfo.precision)

                if base["asset_id"].stringValue == pair?.base {
                
                    let quoteVolume = Decimal(string: quote["amount"].stringValue)! / quotePrecision
                    let baseVolume = Decimal(string: base["amount"].stringValue)! / basePrecision
                    let payVolume = Decimal(string: receive["amount"].stringValue)! / quotePrecision
                    let receiveVolume = Decimal(string: pay["amount"].stringValue)! / basePrecision

                    let price = baseVolume / quoteVolume
                    let tradePrice = price.tradePrice()
                    let viewModel = TradeHistoryViewModel(
                        pay: false,
                        price: tradePrice.price,
                        quoteVolume: payVolume.stringValue.suffixNumber(digitNum: 10 - tradePrice.pricision),
                        baseVolume: receiveVolume.stringValue.suffixNumber(digitNum: tradePrice.pricision),
                        time: time.dateFromISO8601!.string(withFormat: "HH:mm:ss"))
                    showData.append(viewModel)
                }
                else {
                    let quoteVolume = Decimal(string: base["amount"].stringValue)! / quotePrecision
                    let baseVolume = Decimal(string: quote["amount"].stringValue)! / basePrecision
                    
                    let payVolume = Decimal(string: pay["amount"].stringValue)! / quotePrecision
                    let receiveVolume = Decimal(string: receive["amount"].stringValue)! / basePrecision

                    let price = baseVolume / quoteVolume

                    let tradePrice = price.tradePrice()
                    let viewModel = TradeHistoryViewModel(
                        pay: true,
                        price: tradePrice.price,
                        quoteVolume: payVolume.stringValue.suffixNumber(digitNum: 10 - tradePrice.pricision),
                        baseVolume: receiveVolume.stringValue.suffixNumber(digitNum: tradePrice.pricision),
                        time: time.dateFromISO8601!.string(withFormat: "HH:mm:ss"))
                    showData.append(viewModel)
                }

            }
            self.data = showData
        }
    }
}
extension TradeHistoryViewController: TradePair {
    var pariInfo: Pair {
        get {
            return self.pair!
        }
        set {
            self.pair = newValue
        }
    }

    func refresh() {
        refreshView()
    }
}
