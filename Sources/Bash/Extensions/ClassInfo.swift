//
//  ClassInfo.swift
//  https://stackoverflow.com/questions/42746981/list-all-subclasses-of-one-class
//
//  Created by Fatih Balsoy on 2/19/20.
//

import Foundation

struct ClassInfo : CustomStringConvertible, Equatable {
    let classObject: AnyClass
    let className: String

    init?(_ classObject: AnyClass?) {
        guard classObject != nil else { return nil }

        self.classObject = classObject!

        let cName = class_getName(classObject)
        self.className = String(cString: cName)
    }

    var superclassInfo: ClassInfo? {
        let superclassObject: AnyClass? = class_getSuperclass(self.classObject)
        return ClassInfo(superclassObject)
    }

    var description: String {
        return self.className
    }

    static func ==(lhs: ClassInfo, rhs: ClassInfo) -> Bool {
        return lhs.className == rhs.className
    }
}
