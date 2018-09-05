//
//  ETORecordListViewViewAdapter.swift
//  cybexMobile
//
//  Created peng zhu on 2018/8/31.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

extension ETORecordListViewView {
    func adapterModelToETORecordListViewView(_ model:ETOTradeHistoryModel) {
        nameLabel.text = model.project_name
        actionLabel.text = model.ieo_type.showTitle()
        amountLabel.text = "\(model.token_count) \(model.token.filterJade)"
        timeLabel.text = model.create_at.string(withFormat: "YYYY-MM-dd HH:mm:ss")
        statusLabel.text = model.reason.showTitle()
    }
}
