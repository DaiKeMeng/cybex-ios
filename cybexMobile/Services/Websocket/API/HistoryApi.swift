//
//  HistoryApi.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/21.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import JSONRPCKit
import SwiftyJSON

enum HistoryCatogery: String {
    case getMarketHistory
    case getFillOrderHistory
    case getAccountHistory
}

struct AssetPairQueryParams {
    var firstAssetId: String
    var secondAssetId: String
    var timeGap: Int
    var startTime: Date
    var endTime: Date
}

struct GetAccountHistoryRequest: JSONRPCKit.Request, JSONRPCResponse {
    var accountID: String
    var response: RPCSResponse
    var method: String {
        return "call"
    }

    var parameters: Any? {
        return [ApiCategory.history,
                HistoryCatogery.getAccountHistory.rawValue.snakeCased(),
                [accountID, ObjectID.operationHistoryObject.rawValue.snakeCased(),
                 "100",
                 ObjectID.operationHistoryObject.rawValue.snakeCased()]
        ]
    }

    func transferResponse(from resultObject: Any) throws -> Any {
        if let response = resultObject as? [[String: Any]] {
            var fillOrders: [FillOrder] = []
            var transferRecords: [TransferRecord] = []
            for item in response {
                if let opItem = item["op"] as? [Any],
                    let opcode = opItem[0] as? Int,
                    var operation = opItem[1] as? [String: Any],
                    let blockNum = item["block_num"] {
                    operation["block_num"] = blockNum
                    if opcode == ChainTypesOperations.fillOrder.rawValue {
                        if let fillorder = FillOrder.deserialize(from: operation) {
                            fillOrders.append(fillorder)
                        }
                    } else if opcode == ChainTypesOperations.transfer.rawValue {
                        // 转账记录
                        if let extensions = operation["extensions"] as? [Any],
                            extensions.count > 0,
                            let lockUpInfos = extensions[0] as? [Any],
                            lockUpInfos.count >= 2,
                            let lockUpInfo = lockUpInfos[1] as? [String: Any] {
                            operation["vesting_period"] = lockUpInfo["vesting_period"]
                            operation["public_key"] = lockUpInfo["public_key"]
                        }

                        if let transferRecord = TransferRecord.deserialize(from: operation) {
                            transferRecords.append(transferRecord)
                        }
                    }
                }
            }
            return (fillOrders, transferRecords)
        } else {
            throw CastError(actualValue: resultObject, expectedType: Response.self)
        }
    }
}

struct GetMarketHistoryRequest: JSONRPCKit.Request, JSONRPCResponse {
    var queryParams: AssetPairQueryParams
    var response: RPCSResponse

    var method: String {
        return "call"
    }

    var parameters: Any? {
        return [ApiCategory.history,
                HistoryCatogery.getMarketHistory.rawValue.snakeCased(),
                [queryParams.firstAssetId,
                 queryParams.secondAssetId,
                 queryParams.timeGap,
                 queryParams.startTime.iso8601,
                 queryParams.endTime.iso8601]]
    }

    func transferResponse(from resultObject: Any) throws -> Any {
        if let response = resultObject as? [[String: Any]] {
            return response.map { data in
                return Bucket.deserialize(from: data)
            }
        } else {
            throw CastError(actualValue: resultObject, expectedType: Response.self)
        }
    }
}

struct GetFillOrderHistoryRequest: JSONRPCKit.Request, JSONRPCResponse {
    var pair: Pair
    var response: RPCSResponse

    var method: String {
        return "call"
    }

    var parameters: Any? {
        return [ApiCategory.history,
                HistoryCatogery.getFillOrderHistory.rawValue.snakeCased(),
                [pair.base, pair.quote, 40]]
    }

    func transferResponse(from resultObject: Any) throws -> Any {
        let result = JSON(resultObject).arrayValue

        var data: [JSON] = []

        for value in result {
            data.append([value["op"]["pays"], value["op"]["receives"], value["time"]])
        }
        return data
    }
}
