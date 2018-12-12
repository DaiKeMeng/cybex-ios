//
//  ETO.swift
//  cybexMobile
//
//  Created by DKM on 2018/8/28.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import HandyJSON
import DifferenceKit
import RxSwift
import RxCocoa
import Localize_Swift

struct ETOBannerModel: HandyJSON {
    var id: String = ""
    var addsBannerMobile: String = ""
    var addsBannerMobileLangEn: String = ""

    mutating func mapping(mapper: HelpingMapper) {
        mapper <<< self.addsBannerMobile <-- "adds_banner_mobile"
        mapper <<< self.addsBannerMobileLangEn <-- "adds_banner_mobile__lang_en"
    }
}

enum UserKYCStatus: String, HandyJSONEnum {
    case notStart = "not_start"
    case ok = "ok"
}

enum UserStatus: String, HandyJSONEnum {
    case unstart = "unstart"
    case waiting = "waiting"
    case ok = "ok"
    case reject = "reject"
}

struct ETOUserAuditModel: HandyJSON {
    var kycStatus: UserKYCStatus = .notStart //not_start, ok
    var status: UserStatus = .unstart //unstart: 没有预约 waiting,ok,reject

    mutating func mapping(mapper: HelpingMapper) {
        mapper <<< self.kycStatus <-- "kyc_status"
    }
}

struct ETOShortProjectStatusModel: HandyJSON {
    var currentPercent: Double = 0
    var status: ProjectState? //finish pre ok
    var finishAt: Date!

    mutating func mapping(mapper: HelpingMapper) {
        mapper <<<
            self.finishAt <-- ("finish_at", GemmaDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss"))
        mapper <<< self.currentPercent <-- "current_percent"
    }
}

struct ETOUserModel: HandyJSON {
    var currentBaseTokenCount: Double = 0

    mutating func mapping(mapper: HelpingMapper) {
        mapper <<< self.currentBaseTokenCount <-- "current_base_token_count"
    }
}

enum ETOTradeHistoryStatus: String, HandyJSONEnum {
    case ok = ""

    case projectNotExist = "1"
    case userNotInWhiteList = "2"
    case userFallShort = "3"
    case notInCrowding = "4"
    case projectControlClosed = "5"
    case currencyError = "6"
    case crowdLimit = "7"
    case userCrowdLimit = "8"
    case notMatchUserCrowdMinimum = "9"
    case projectLimitLessThanUserMinimum = "10"
    case userResidualLessThanUserMinimum = "11"
    case portionMoreThanProjectTotalLimit = "12"
    case portionMoreThanUserLimit = "13"
    case moreThanAccuracy = "14"
    case transferWithLockup = "15"
    case fail = "101"

    func showTitle() -> String {
        if let reason = self.rawValue.int {
            switch reason {
            case 1...11, 15:
                return R.string.localizable.eto_invalid_sub.key.localized()
            case 12...14:
                return R.string.localizable.eto_invalid_partly_sub.key.localized()
            case 16:
                return R.string.localizable.eto_refund.key.localized()
            default:
                return R.string.localizable.eto_receive_success.key.localized()
            }
        } else {
            return R.string.localizable.eto_receive_success.key.localized()
        }
    }
}

enum ETOIEOType: String, HandyJSONEnum {
    case receive
    case send

    func showTitle() -> String {
        switch self {
        case .receive:
            return R.string.localizable.eto_record_send.key.localized()
        case .send:
            return R.string.localizable.eto_record_receive.key.localized()
        }
    }
}

struct ETOTradeHistoryModel: HandyJSON, Differentiable, Equatable, Hashable {
    var projectId: Int = 0
    var projectName: String = ""
    var ieoType: ETOIEOType = .receive //receive: 参与ETO send: 到账成功
    var reason: ETOTradeHistoryStatus = .ok
    var createdAt: Date!
    var tokenCount: String = ""
    var token: String = ""

    mutating func mapping(mapper: HelpingMapper) {
        mapper <<<
            self.createdAt <-- GemmaDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss")
        mapper <<< self.projectId <-- "project_id"
        mapper <<< self.projectName <-- "project_name"
        mapper <<< self.ieoType <-- "ieo_type"
        mapper <<< self.createdAt <-- "created_at"
        mapper <<< self.tokenCount <-- "token_count"
    }

    static func == (lhs: ETOTradeHistoryModel, rhs: ETOTradeHistoryModel) -> Bool {
        return lhs.projectId == rhs.projectId &&
            lhs.projectName == rhs.projectName &&
            lhs.ieoType == rhs.ieoType &&
            lhs.reason == rhs.reason &&
            lhs.createdAt == rhs.createdAt &&
            lhs.tokenCount == rhs.tokenCount &&
            lhs.token == rhs.token
    }

    var hashValue: Int {
        return projectId
    }
}

class ETOProjectModel: HandyJSON {
    var id: Int = 0
    var addsLogoMobile: String = ""
    var addsLogoMobileLangEn: String = ""
    var addsKeyword: String = ""
    var addsKeywordLangEn: String = ""
    var addsAdvantage: String = ""
    var addsAdvantageLangEn: String = ""
    var addsWebsite: String = ""
    var addsWebsiteLangEn: String = ""
    var addsDetail: String = ""
    var addsDetailLangEn: String = ""
    var addsShareMobil: String = ""
    var addsShareMobilLangEn: String = ""
    var addsBuyDesc: String = ""
    var addsBuyDescLangEn: String = ""
    var addsWhitelist: String = ""
    var addsWhitelistLangEn: String = ""
    var addsWhitepaper: String = ""
    var addsWhitepaperLangEn: String = ""
    var addsTokenTotal: String = ""
    var addsTokenTotalLangEn: String = ""

    var status: ProjectState? // finish pre ok
    var name: String = ""
    var receiveAddress: String = ""
    var currentPercent: Double = 0

    var startAt: Date?
    var endAt: Date?
    var finishAt: Date?
    var offerAt: Date?
    var lockAt: Date?
    var createAt: Date?

    var tokenName: String = ""
    var baseTokenName: String = ""
    var rate: Int = 0 //1 base

    var baseMaxQuota: Double = 0
    var baseAccuracy: Int = 0
    var baseMinQuota: Double = 0

    var project: String = ""

    var isUserIn: String = "0" // 0不准预约 1可以预约

    var tTotalTime: String = ""

    func mapping(mapper: HelpingMapper) {
        mapper <<< self.addsLogoMobile <-- "adds_logo_mobile"
        mapper <<< self.addsLogoMobileLangEn <-- "adds_logo_mobile__lang_en"
        mapper <<< self.addsKeyword <-- "adds_keyword"
        mapper <<< self.addsKeywordLangEn <-- "adds_keyword__lang_en"
        mapper <<< self.addsAdvantage <-- "adds_advantage"
        mapper <<< self.addsAdvantageLangEn <-- "adds_advantage__lang_en"
        mapper <<< self.addsWebsite <-- "adds_website"
        mapper <<< self.addsWebsiteLangEn <-- "adds_website__lang_en"
        mapper <<< self.addsDetail <-- "adds_detail"
        mapper <<< self.addsDetailLangEn <-- "adds_detail__lang_en"
        mapper <<< self.addsShareMobil <-- "adds_share_mobil"
        mapper <<< self.addsShareMobilLangEn <-- "adds_share_mobil__lang_en"
        mapper <<< self.addsBuyDesc <-- "adds_buy_desc"
        mapper <<< self.addsBuyDescLangEn <-- "adds_buy_desc__lang_en"
        mapper <<< self.addsWhitelist <-- "adds_whitelist"
        mapper <<< self.addsWhitelistLangEn <-- "adds_whitelist__lang_en"
        mapper <<< self.addsWhitepaper <-- "adds_whitepaper"
        mapper <<< self.addsWhitepaperLangEn <-- "adds_whitepaper__lang_en"
        mapper <<< self.addsTokenTotal <-- "adds_token_total"
        mapper <<< self.addsTokenTotalLangEn <-- "adds_token_total__lang_en"
        mapper <<< self.receiveAddress <-- "receive_address"
        mapper <<< self.currentPercent <-- "current_percent"
        mapper <<< self.tokenName <-- "token_name"
        mapper <<< self.baseTokenName <-- "base_token_name"
        mapper <<< self.baseMaxQuota <-- "base_max_quota"
        mapper <<< self.baseAccuracy <-- "base_accuracy"
        mapper <<< self.baseMinQuota <-- "base_min_quota"
        mapper <<< self.isUserIn <-- "is_user_in"
        mapper <<< self.tTotalTime <-- "t_total_time"
        mapper <<<
            self.startAt <-- ("start_at", GemmaDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss"))
        mapper <<<
            self.endAt <-- ("end_at", GemmaDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss"))
        mapper <<<
            self.finishAt <-- ("finish_at", GemmaDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss"))
        mapper <<<
            self.offerAt <-- ("offer_at", GemmaDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss"))
        mapper <<<
            self.lockAt <-- ("lock_at", GemmaDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss"))
        mapper <<<
            self.createAt <-- ("create_at", GemmaDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss"))
    }

    required init() {}
}

enum ProjectState: String, HandyJSONEnum {
    case finish = "finish"
    case pre = "pre"
    case ok = "ok"

    func description() -> String {
        switch self {
        case .finish:
            return R.string.localizable.eto_project_finish.key.localized()
        case .pre:
            return R.string.localizable.eto_project_comming.key.localized()
        case .ok:
            return R.string.localizable.eto_project_progress.key.localized()
        }
    }
}

class ETOProjectViewModel {
    var icon: String = ""
    var iconEn: String = ""
    var name: String = ""
    var keyWords: String = ""
    var keyWordsEn: String = ""
    var status: BehaviorRelay<String> = BehaviorRelay(value: "")
    var currentPercent: BehaviorRelay<String> = BehaviorRelay(value: "")
    var progress: BehaviorRelay<Double> = BehaviorRelay(value: 0)
    var projectModel: ETOProjectModel?
    var timeState: String {
        if let data = self.projectModel, let state = data.status {
            if state == .finish {
                return R.string.localizable.eto_project_time_finish.key.localized()
            } else if state == .pre {
                return R.string.localizable.eto_project_time_pre.key.localized()
            } else {
                return R.string.localizable.eto_project_time_comming.key.localized()
            }
        }
        return ""
    }

    var time: BehaviorRelay<String> = BehaviorRelay(value: "")

    var etoDetail: String {
        var result: String = ""
        if let data = self.projectModel {
            result += R.string.localizable.eto_project_name.key.localized() + data.name + "\n"
            result += R.string.localizable.eto_token_name.key.localized() + data.tokenName + "\n"
            //            var adds_token_total: String = ""
            //            var adds_token_total__lang_en: String = ""
            if data.addsTokenTotal.count != 0 || data.addsTokenTotalLangEn.count != 0 {
                if Localize.currentLanguage() == "en" {
                    result += R.string.localizable.eto_total_supply.key.localized() + data.addsTokenTotalLangEn + "\n"
                } else {
                    result += R.string.localizable.eto_total_supply.key.localized() + data.addsTokenTotal + "\n"
                }
            }

            result += R.string.localizable.eto_start_time.key.localized() + data.startAt!.string(withFormat: "yyyy/MM/dd HH:mm:ss") + "\n"
            result += R.string.localizable.eto_end_time.key.localized() + data.endAt!.string(withFormat: "yyyy/MM/dd HH:mm:ss") + "\n"
            if data.lockAt != nil {
                result += R.string.localizable.eto_start_at.key.localized() + data.lockAt!.string(withFormat: "yyyy/MM/dd HH:mm:ss") + "\n"
            }
            if data.offerAt == nil {
                result += R.string.localizable.eto_token_releasing_time.key.localized() + R.string.localizable.eto_project_immediate.key.localized() + "\n"
            } else {
                result += R.string.localizable.eto_token_releasing_time.key.localized() + data.offerAt!.string(withFormat: "yyyy/MM/dd HH:mm:ss") + "\n"
            }
            result += R.string.localizable.eto_currency.key.localized() + data.baseTokenName.filterJade + "\n"

            result += R.string.localizable.eto_exchange_ratio.key.localized() + "1" + data.baseTokenName + "=" + "\(data.rate)" + data.tokenName
        }
        return result
    }

    var projectWebsite: String {
        var result: String = ""
        if let data = self.projectModel {
            result += R.string.localizable.eto_project_online.key.localized() + data.addsWebsite + "\n"
            result += R.string.localizable.eto_project_white_Paper.key.localized() + data.addsWhitepaper + "\n"
            if data.addsDetail.count != 0 {
                result += R.string.localizable.eto_project_detail.key.localized() + data.addsDetail
            }
        }
        return result
    }

    var projectWebsiteEn: String {
        var result: String = ""
        if let data = self.projectModel {
            result += R.string.localizable.eto_project_online.key.localized() + data.addsWebsiteLangEn + "\n"
            result += R.string.localizable.eto_project_white_Paper.key.localized() + data.addsWhitepaperLangEn + "\n"
            result += R.string.localizable.eto_project_detail.key.localized() + data.addsDetailLangEn
        }
        return result
    }

    var detailTime: BehaviorRelay<String> = BehaviorRelay(value: "")
    var projectState: BehaviorRelay<ProjectState?> = BehaviorRelay(value: nil)
    init(_ projectModel: ETOProjectModel) {
        self.projectModel = projectModel
        self.name = projectModel.name
        self.keyWords = projectModel.addsKeyword
        self.keyWordsEn = projectModel.addsKeywordLangEn
        self.status.accept(projectModel.status!.description())
        self.currentPercent.accept((projectModel.currentPercent * 100).string(digits: 2, roundingMode: .down) + "%")
        self.progress.accept(projectModel.currentPercent)
        self.icon = projectModel.addsLogoMobile
        self.iconEn = projectModel.addsLogoMobileLangEn
        self.projectState.accept(projectModel.status)
        if let state = projectModel.status {
            if state == .finish {
                if projectModel.tTotalTime == "" {
                    if projectModel.finishAt != nil {
                        self.detailTime.accept(timeHandle(projectModel.finishAt!.timeIntervalSince1970 - projectModel.startAt!.timeIntervalSince1970, isHiddenSecond: false))
                        self.time.accept(timeHandle(projectModel.finishAt!.timeIntervalSince1970 - projectModel.startAt!.timeIntervalSince1970, isHiddenSecond: false))
                    }
                } else {
                    self.detailTime.accept(timeHandle(Double(projectModel.tTotalTime)!, isHiddenSecond: false))
                    self.time.accept(timeHandle(Double(projectModel.tTotalTime)!, isHiddenSecond: false))
                }
            } else if state == .pre {
                self.detailTime.accept(timeHandle(projectModel.startAt!.timeIntervalSince1970 - Date().timeIntervalSince1970))
                self.time.accept(timeHandle(projectModel.startAt!.timeIntervalSince1970 - Date().timeIntervalSince1970))
            } else {
                self.detailTime.accept(timeHandle(projectModel.endAt!.timeIntervalSince1970 - Date().timeIntervalSince1970))
                self.time.accept(timeHandle(projectModel.endAt!.timeIntervalSince1970 - Date().timeIntervalSince1970))
            }
        }
    }
}

struct AppEnableSetting: HandyJSON {
    var isETOEnabled: Bool = false
    var isShareEnabled: Bool = false
}
