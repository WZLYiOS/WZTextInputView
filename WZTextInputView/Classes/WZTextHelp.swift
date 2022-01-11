//
//  WZTextHelp.swift
//  Created on 2022/1/11
//  Description <#文件描述#>
//  PD <#产品文档地址#>
//  Design <#设计文档地址#>
//  Copyright © 2022 WZLY. All rights reserved.
//  @author 邱啟祥(739140860@qq.com)   
//

import Foundation

public struct WZTextInputNamespaceWrappable<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}
public protocol WZTextInputNamespaceCompatible: AnyObject { }
public protocol WZTextInputNamespaceCompatibleValue {}

extension WZTextInputNamespaceCompatible {
    public var wz: WZTextInputNamespaceWrappable<Self> {
        get { return WZTextInputNamespaceWrappable(self) }
        set { }
    }
    
    public static var wz: WZTextInputNamespaceWrappable<Self>.Type {
        return WZTextInputNamespaceWrappable<Self>.self
    }
}

/// 值类型
extension WZTextInputNamespaceCompatibleValue {
    public var wz: WZTextInputNamespaceWrappable<Self> {
        get { return WZTextInputNamespaceWrappable(self) }
        set { }
    }
    
    public static var wz: WZTextInputNamespaceWrappable<Self>.Type {
            return WZTextInputNamespaceWrappable<Self>.self
    }
}

extension String: WZTextInputNamespaceCompatibleValue { }


// MARK - 扩展
public extension WZTextInputNamespaceWrappable where Base == String {

    func substring(with nsrange: NSRange) -> String {
        guard let range = Range(nsrange, in: base) else { return "" }
        return String(base[range])
    }

    var length: Int {
        return base.count
    }

    subscript(i: Int) -> String {
        return self[i ..< i + 1]
    }

    subscript(r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = base.index(base.startIndex, offsetBy: range.lowerBound)
        let end = base.index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(base[start ..< end])
    }
}
