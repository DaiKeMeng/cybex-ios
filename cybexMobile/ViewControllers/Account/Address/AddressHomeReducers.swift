//
//  AddressHomeReducers.swift
//  cybexMobile
//
//  Created koofrank on 2018/8/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func addressHomeReducer(action: Action, state: AddressHomeState?) -> AddressHomeState {
    return AddressHomeState(isLoading: loadingReducer(state?.isLoading, action: action),
                            page: pageReducer(state?.page, action: action),
                            errorMessage: errorMessageReducer(state?.errorMessage, action: action),
                            property: addressHomePropertyReducer(state?.property, action: action),
                            callback: state?.callback ?? AddressHomeCallbackState())
}

func addressHomePropertyReducer(_ state: AddressHomePropertyState?, action: Action) -> AddressHomePropertyState {
    let state = state ?? AddressHomePropertyState()

    switch action {
    default:
        break
    }

    return state
}
