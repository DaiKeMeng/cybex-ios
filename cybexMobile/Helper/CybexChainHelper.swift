//
//  CybexChainHelper.swift
//  cybexMobile
//
//  Created by koofrank on 2018/12/11.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import Localize_Swift
import SwiftTheme
import SwiftyJSON
import SwiftyUserDefaults
import cybex_ios_core_cpp

func getChainId(callback:@escaping(String) -> Void) {
    if CybexConfiguration.shared.chainID.isEmpty {
        let requeset = GetChainIDRequest { (id) in
            if let id = id as? String {
                callback(id)
            } else {
                callback("")
            }
        }
        CybexWebSocketService.shared.send(request: requeset)
    } else {
        callback(CybexConfiguration.shared.chainID)
    }
}

typealias BlockChainParamsType = (chain_id: String, block_id: String, block_num: Int32)
func blockchainParams(callback: @escaping(BlockChainParamsType) -> Void) {
    getChainId { (chainID) in
        let requeset = GetObjectsRequest(ids: [ObjectID.dynamicGlobalPropertyObject.rawValue.snakeCased()]) { (infos) in
            if let infos = infos as? (block_id: String, block_num: String) {
                callback((chain_id: chainID, block_id: infos.block_id, block_num: Int32(infos.block_num)!))
            }
        }
        CybexWebSocketService.shared.send(request: requeset)
    }
}

func calculateFee(_ operation: String,
                  focusAssetId: String,
                  operationID: ChainTypesOperations = .limitOrderCreate,
                  filterRepeat: Bool = true,
                  completion:@escaping (_ success: Bool,
    _ amount: Decimal,
    _ assetID: String) -> Void) {
    let request = GetRequiredFees(response: { (data) in
        if let fees = data as? [Fee], let cybAmount = fees.first?.amount.decimal(), let cyb = UserManager.shared.balances.value?.filter({ (balance) -> Bool in
            return balance.assetType == AssetConfiguration.CybexAsset.CYB.id
        }).first?.balance.decimal() {
            if cyb >= cybAmount {
                let amount = getRealAmount(AssetConfiguration.CybexAsset.CYB.id, amount: cybAmount.string)

                completion(true, amount, AssetConfiguration.CybexAsset.CYB.id)
            } else {
                let request = GetRequiredFees(response: { (data) in
                    if let fees = data as? [Fee], let baseAmount = fees.first?.amount.decimal() {
                        if let base = UserManager.shared.balances.value?.filter({ (balance) -> Bool in
                            return balance.assetType == focusAssetId
                        }).first {
                            if base.balance.decimal() >= baseAmount {
                                let amount = getRealAmount(focusAssetId, amount: baseAmount.string)

                                completion(true, amount, focusAssetId)
                            } else {//余额不足
                                completion(false, getRealAmount(AssetConfiguration.CybexAsset.CYB.id, amount: cybAmount.string), AssetConfiguration.CybexAsset.CYB.id)

                            }
                        } else {
                            completion(false, getRealAmount(AssetConfiguration.CybexAsset.CYB.id, amount: cybAmount.string), AssetConfiguration.CybexAsset.CYB.id)
                        }
                    } else {
                        completion(false, getRealAmount(AssetConfiguration.CybexAsset.CYB.id, amount: cybAmount.string), AssetConfiguration.CybexAsset.CYB.id)
                    }
                }, operationStr: operation, assetID: focusAssetId, operationID: operationID)

                CybexWebSocketService.shared.send(request: request)
            }

        } else {
            completion(false, 0, "")
        }
    }, operationStr: operation, assetID: AssetConfiguration.CybexAsset.CYB.id, operationID: operationID)

    CybexWebSocketService.shared.send(request: request)
}

func calculateAssetRelation(assetIDAName: String, assetIDBName: String) -> (base: String, quote: String) {
    let relation: [String] = [AssetConfiguration.CybexAsset.USDT,
                              AssetConfiguration.CybexAsset.ETH,
                              AssetConfiguration.CybexAsset.BTC,
                              AssetConfiguration.CybexAsset.CYB].map({ $0.id })

    var indexA = -1
    var indexB = -1

    if let index = relation.index(of: assetIDAName) {
        indexA = index
    }

    if let index = relation.index(of: assetIDBName) {
        indexB = index
    }

    if indexA > -1 && indexB > -1 {
        if indexA < indexB {
            return (assetIDAName, assetIDBName)
        } else {
            return (assetIDBName, assetIDAName)
        }
    } else if indexA < indexB {
        return (assetIDBName, assetIDAName)
    } else if indexA > indexB {
        return (assetIDAName, assetIDBName)
    } else {
        if assetIDAName < assetIDBName {
            return (assetIDAName, assetIDBName)
        } else {
            return (assetIDBName, assetIDAName)
        }
    }

}

func getRealAmount(_ id: String, amount: String) -> Decimal {
    guard let asset = appData.assetInfo[id] else {
        return 0
    }

    let precisionNumber = pow(10, asset.precision)

    return amount.decimal() / precisionNumber
}

// 得到一个ID获取最后一个数据
func getUserId(_ userId: String) -> Int {
    if userId.contains(".") {
        return Int(String.init(userId.split(separator: ".").last!))!
    }
    return 0
}

func getWithdrawDetailInfo(addressInfo: String, amountInfo: String, withdrawFeeInfo: String, gatewayFeeInfo: String, receiveAmountInfo: String, isEOS: Bool, memoInfo: String) -> [NSAttributedString] {
    let address: String = R.string.localizable.utils_address.key.localized()
    let amount: String = R.string.localizable.utils_amount.key.localized()
    let gatewayFee: String = R.string.localizable.utils_withdrawfee.key.localized()
    let withdrawFee: String = R.string.localizable.utils_gatewayfee.key.localized()
    let receiveAmount: String = R.string.localizable.utils_receiveamount.key.localized()
    var memo: String = R.string.localizable.withdraw_memo.key.localized()

    let content = ThemeManager.currentThemeIndex == 0 ?  "content_dark" : "content_light"
    if isEOS && memoInfo.count > 0 && receiveAmountInfo.contains(AssetConfiguration.CybexAsset.XRP.rawValue) {
        memo = "Tag"
    }
    return (isEOS && memoInfo.count > 0) ?
        (["<name>\(address):</name><\(content)>\n\(addressInfo)</\(content)>".set(style: "alertContent"),
          "<name>\(memo):</name><\(content)>  \(memoInfo)</\(content)>".set(style: "alertContent"),
          "<name>\(amount):</name><\(content)>  \(amountInfo)</\(content)>".set(style: "alertContent"),
          "<name>\(withdrawFee):</name><\(content)>  \(withdrawFeeInfo)</\(content)>".set(style: "alertContent"),
          "<name>\(gatewayFee):</name><\(content)>  \(gatewayFeeInfo)</\(content)>".set(style: "alertContent"),
          "<name>\(receiveAmount):</name><\(content)>  \(receiveAmountInfo)</\(content)>".set(style: "alertContent")] as? [NSAttributedString])! :
        (["<name>\(address):</name><\(content)>\n\(addressInfo)</\(content)>".set(style: "alertContent"),
          "<name>\(amount):</name><\(content)>  \(amountInfo)</\(content)>".set(style: "alertContent"),
          "<name>\(withdrawFee):</name><\(content)>  \(withdrawFeeInfo)</\(content)>".set(style: "alertContent"),
          "<name>\(gatewayFee):</name><\(content)>  \(gatewayFeeInfo)</\(content)>".set(style: "alertContent"),
          "<name>\(receiveAmount):</name><\(content)>  \(receiveAmountInfo)</\(content)>".set(style: "alertContent")] as? [NSAttributedString])!
}

func getOpenedOrderInfo(price: String, amount: String, total: String, fee: String, isBuy: Bool) -> [NSAttributedString] {
    let priceTitle = R.string.localizable.opened_order_value.key.localized()
    let amountTitle = R.string.localizable.withdraw_amount.key.localized()
    let totalTitle = R.string.localizable.trade_history_total.key.localized()
    let feeTitle = R.string.localizable.openedorder_fee_title.key.localized()

    let priceContentStyle = isBuy ? "content_buy" : "content_sell"
    let contentStyle = ThemeManager.currentThemeIndex == 0 ?  "content_dark" : "content_light"

    let result = fee.count == 0 ? (["<name>\(priceTitle): </name><\(priceContentStyle)>\(price)</\(priceContentStyle)>".set(style: "alertContent"),
                                    "<name>\(amountTitle): </name><\(contentStyle)>\(amount)</\(contentStyle)>".set(style: "alertContent"),
                                    "<name>\(totalTitle): </name><\(contentStyle)>\(total)</\(contentStyle)>".set(style: "alertContent")] as? [NSAttributedString])! :
        (["<name>\(priceTitle): </name><\(priceContentStyle)>\(price)</\(priceContentStyle)>".set(style: "alertContent"),
          "<name>\(amountTitle): </name><\(contentStyle)>\(amount)</\(contentStyle)>".set(style: "alertContent"),
          "<name>\(totalTitle): </name><\(contentStyle)>\(total)</\(contentStyle)>".set(style: "alertContent"),
          "<name>\(feeTitle): </name><\(contentStyle)>\(fee)</\(contentStyle)>".set(style: "alertContent") ] as? [NSAttributedString])!

    return  result
}

func getTransferInfo(_ account: String, quanitity: String, fee: String, memo: String) -> [NSAttributedString] {
    let accountTitle = R.string.localizable.transfer_account_title.key.localized()
    let quantityTitle = R.string.localizable.transfer_quantity.key.localized()
    let feeTitle = R.string.localizable.transfer_fee.key.localized()
    let memoTitle = R.string.localizable.transfer_memo.key.localized()

    let contentStyle = ThemeManager.currentThemeIndex == 0 ?  "content_dark" : "content_light"

    return memo.trimmed.count != 0 ? (["<name>\(accountTitle):</name>  <\(contentStyle)>\(account)</\(contentStyle)>".set(style: "alertContent"),
                                       "<name>\(quantityTitle):</name><\(contentStyle)>  \(quanitity)</\(contentStyle)>".set(style: "alertContent"),
                                       "<name>\(feeTitle):</name><\(contentStyle)>  \(fee)</\(contentStyle)>".set(style: "alertContent"),
                                       "<name>\(memoTitle):</name><\(contentStyle)>  \(memo)</\(contentStyle)>".set(style: "alertContent")] as? [NSAttributedString])! :
        (["<name>\(accountTitle):</name>  <\(contentStyle)>\(account)</\(contentStyle)>".set(style: "alertContent"),
          "<name>\(quantityTitle):</name><\(contentStyle)>  \(quanitity)</\(contentStyle)>".set(style: "alertContent"),
          "<name>\(feeTitle):</name><\(contentStyle)>  \(fee)</\(contentStyle)>".set(style: "alertContent")] as? [NSAttributedString])!
}

func claimLockupAsset(_ info: LockupAssteData) -> [NSAttributedString] {

    guard let name = UserManager.shared.name.value else { return []}
    let contentStyle = ThemeManager.currentThemeIndex == 0 ?  "content_dark" : "content_light"
    var result: [NSAttributedString] = []

    let quantity = R.string.localizable.transfer_quantity.key.localized()
    let account = R.string.localizable.transfer_account_title.key.localized()

    let amount = info.amount + " " +  info.name.filterJade
    let quantityInfo = "<name>\(quantity):</name> <\(contentStyle)>" + amount + "</\(contentStyle)>"
    let accountInfo = "<name>\(account):</name> <\(contentStyle)>" + name + "</\(contentStyle)>"

    result.append(quantityInfo.set(style: StyleNames.alertContent.rawValue)!)
    result.append(accountInfo.set(style: StyleNames.alertContent.rawValue)!)
    return result
}



func confirmDeleteWithDrawAddress(_ info: WithdrawAddress) -> [NSAttributedString] {

    let contentStyle = ThemeManager.currentThemeIndex == 0 ?  "content_dark" : "content_light"
    let isEOS = info.currency == AssetConfiguration.CybexAsset.EOS.id
    let existMemo = info.memo != nil && !info.memo!.isEmpty

    var result: [NSAttributedString] = []
    let title = "<\(contentStyle)>" +
        (isEOS ? R.string.localizable.delete_confirm_account.key.localized() : R.string.localizable.delete_confirm_address.key.localized()) +
    "</\(contentStyle)>"
    result.append(title.set(style: StyleNames.alertContent.rawValue)!)

    let note = "<name>" +
        R.string.localizable.address_mark.key.localized() +
        "：</name>" + "<\(contentStyle)>" +
        "\(info.name)" +
    "</\(contentStyle)>"
    result.append(note.set(style: StyleNames.alertContent.rawValue)!)

    let address = "<name>" +
        (isEOS ? R.string.localizable.accountTitle.key.localized() : R.string.localizable.address.key.localized()) +
        "：</name>" +
        "<\(contentStyle)>" +
        "\(info.address)" +
    "</\(contentStyle)>"
    result.append(address.set(style: StyleNames.alertContent.rawValue)!)

    if existMemo {
        let memo = "<name>" + R.string.localizable.withdraw_memo.key.localized() + "：</name>" + "<\(contentStyle)>" + "\(info.memo!)" + "</\(contentStyle)>"
        result.append(memo.set(style: StyleNames.alertContent.rawValue)!)
    }

    return result
}

func confirmDeleteTransferAddress(_ info: TransferAddress) -> [NSAttributedString] {
    let contentStyle = ThemeManager.currentThemeIndex == 0 ?  "content_dark" : "content_light"

    var result: [NSAttributedString] = []

    let title = "<\(contentStyle)>" + R.string.localizable.delete_confirm_account.key.localized() + "</\(contentStyle)>"
    result.append(title.set(style: StyleNames.alertContent.rawValue)!)

    let note = "<name>" + R.string.localizable.address_mark.key.localized() + "：</name>" + "<\(contentStyle)>" + "\(info.name)" + "</\(contentStyle)>"
    result.append(note.set(style: StyleNames.alertContent.rawValue)!)

    let address = "<name>" + R.string.localizable.accountTitle.key.localized() + "：</name>" + "<\(contentStyle)>" + "\(info.address)" + "</\(contentStyle)>"
    result.append(address.set(style: StyleNames.alertContent.rawValue)!)

    return result
}

func confirmSubmitCrowd(_ name: String, amount: String, fee: String) -> [NSAttributedString] {
    let contentStyle = ThemeManager.currentThemeIndex == 0 ?  "content_dark" : "content_light"

    var result: [NSAttributedString] = []

    let title = R.string.localizable.eto_submit_title.key.localizedFormat(name).tagText(contentStyle)
    result.append(title.set(style: StyleNames.alertContent.rawValue)!)

    let note = (R.string.localizable.transfer_quantity.key.localized() + ": ").tagText("name") + amount.tagText(contentStyle)

    result.append(note.set(style: StyleNames.alertContent.rawValue)!)

    let address = (R.string.localizable.transfer_fee.key.localized() + ": " ).tagText("name") + fee.tagText(contentStyle)
    result.append(address.set(style: StyleNames.alertContent.rawValue)!)

    return result
}

func getBalanceWithAssetId(_ asset: String) -> Balance? {
    if let balances = UserManager.shared.balances.value {
        for balance in balances {
            if balance.assetType == asset {
                return balance
            }
        }
        return nil
    }
    return nil
}

func sortNameBasedonAddress(_ names: [AddressName]) -> [String] {
    let collation = UILocalizedIndexedCollation.current()
    var newSectionsArray: [[AddressName]] = []

    for _ in 0 ..< collation.sectionTitles.count {
        let array = [AddressName]()
        newSectionsArray.append(array)
    }

    for name in names {
        let sectionNumber = collation.section(for: name, collationStringSelector: #selector(getter: AddressName.name))
        var sectionBeans = newSectionsArray[sectionNumber]

        sectionBeans.append(name)

        newSectionsArray[sectionNumber] = sectionBeans
    }

    for item in 0 ..< collation.sectionTitles.count {
        let beansArrayForSection = newSectionsArray[item]

        let sortedBeansArrayForSection = collation.sortedArray(from: beansArrayForSection, collationStringSelector: #selector(getter: AddressName.name))
        if let sortedBeans = sortedBeansArrayForSection as? [AddressName] {
            newSectionsArray[item] = sortedBeans
        }
    }

    let sortedNames = newSectionsArray.flatMap({ $0 }).map({ $0.name })

    return sortedNames
}
