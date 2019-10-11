//
//  StorageService.swift
//  SomariKit
//
//  Created by Kazuki Yamamoto on 2019/10/11.
//  Copyright © 2019 Kazuki Yamamoto. All rights reserved.
//

import Foundation

public protocol StorageService {
    func add<Value: Encodable>(key: String, _ value: Value, completion: @escaping (Result<Value, Error>) -> Void)
    func get<Value: Decodable>(key: String, completion: @escaping (Result<[Value], Error>) -> Void)
}