//
//  BDD.swift
//  Quicker
//
//  Created by jimlai on 2018/4/16.
//  Copyright © 2018年 jimlai. All rights reserved.
// Borrowed (with minor mods) from jimLai: https://github.com/swift2931/Quicker

import Foundation

func describe(_ description: String, _ cls: @escaping () -> ()) {
    recursive(cls)
}

func given(_ description: String, _ cls: @escaping () -> ()) {
    recursive(cls)
}

func and(_ description: String, _ cls: @escaping () -> ()) {
    recursive(cls)
}

func with(_ description: String, _ cls: @escaping () -> ()) {
    recursive(cls)
}

func when(_ description: String, _ cls: @escaping () -> ()) {
    recursive(cls)
}

func then(_ description: String, _ cls: @escaping () -> ()) {
    Node.cur?.its[description] = cls
}


func when<T>(_ description: String, _ td: T, _ cls: @escaping () -> ()) {

}
func it(_ description: String, _ cls: @escaping () -> ()) {
    Node.cur?.its[description] = cls
}
func beforeEach(_ description: String, _ cls: @escaping () -> ()) {
    Node.cur?.before[description] = cls
}

func recursive(_ cls: @escaping () -> ()) {
    let n = Node(cls)
    Node.cur?.nodes.append(n)
    n.parent = Node.cur
    Node.cur = n
    //n.before += n.parent?.before ?? [:] @todo
    n.cls()
    n.before.forEach { desc, cls in 
        print(desc)
        print(String(repeating: "—", count: desc.count))
        cls()
    }
    
    n.its.forEach { desc, cls in 
        print("\ntest:" << desc)
        print(String(repeating: "—", count: desc.count))
        cls()
    }
    Node.cur = n.parent
}

class Node {
    static var head = Node({})
    static var cur: Node? = head
    var parent: Node?
    var nodes = [Node]()
    let cls: () -> ()
    var before = [String: () -> ()]()
    var its = [String: () -> ()]()
    init(_ cls: @escaping () -> ()) {
        self.cls = cls
    }
}
