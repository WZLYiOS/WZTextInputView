//
//  WZTextInputFormatterType.swift
//  Created on 2022/1/11
//  Description <#文件描述#>
//  PD <#产品文档地址#>
//  Design <#设计文档地址#>
//  Copyright © 2022 WZLY. All rights reserved.
//  @author 邱啟祥(739140860@qq.com)   
//

import Foundation

/// MARK - 格式类型
public enum WZTextInputFormatterType: CustomStringConvertible {
    
    case `default`
    case phoneNumber
    case chinese
    case idCard
    case number
    case alphabet
    case numberAndAlphabet
    case space
    case custom(regexString: String)
    
    /// 格式
    public var regexString: String? {
        switch self {
        case .phoneNumber:
            return "^\\d{0,11}$"
        case .chinese:
            return "^[\\u4e00-\\u9fa5]{0,}$"
        case .numberAndAlphabet:
            return "^[A-Za-z0-9]+$"
        case .idCard:
            return "^\\d{1,17}[0-9Xx]?$"
        case .number:
            return "^\\d*$"
        case .alphabet:
            return "^[a-zA-Z]*$"
        case .space:
            return "^[\\S]*$"
        case let .custom(regexString):
            return regexString
        default:
            return nil
        }
    }
    
    /// 描述
    public var description: String {
        switch self {
        case .default:
            return "默认不限制"
        case .phoneNumber:
            return "只能输入手机号码"
        case .chinese:
            return "只能输入中文"
        case .numberAndAlphabet:
            return "数字加英文"
        case .idCard:
            return "身份证号码"
        case .number:
            return "数字"
        case .alphabet:
            return "字母"
        case .space:
            return "空格"
        case .custom:
            return "自定义"
        }
    }
}
