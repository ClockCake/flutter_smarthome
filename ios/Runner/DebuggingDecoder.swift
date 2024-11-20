//
//  DebuggingDecoder.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/8/2.
//  自定义解码器,方便定位JSON 解析错误

import Foundation

// 定义一个继承自 JSONDecoder 的类 DebuggingDecoder，并显式声明其遵循 @unchecked Sendable 协议
class DebuggingDecoder: JSONDecoder, @unchecked Sendable {
    // 使用私有变量 _errorContext 来存储错误上下文
    // 由于数组不是线程安全的容器，因此需要额外处理，使用 NSLock 进行线程同步
    private var _errorContext: [String] = []
    private let lock = NSLock() // 创建一个锁对象

    // 公开的 errorContext 属性，通过加锁的方式来实现线程安全
    var errorContext: [String] {
        get {
            lock.lock() // 加锁，防止其他线程同时访问
            defer { lock.unlock() } // 在返回前解锁
            return _errorContext
        }
        set {
            lock.lock() // 加锁，防止其他线程同时访问
            defer { lock.unlock() } // 在方法结束前解锁
            _errorContext = newValue
        }
    }

    // 重写 decode 方法，添加错误处理的调试信息
    override func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        do {
            // 调用父类的 decode 方法
            return try super.decode(type, from: data)
        } catch let DecodingError.dataCorrupted(context) {
            // 处理数据损坏的错误
            print("Data corrupted: \(context.debugDescription)")
            print("Coding path: \(errorContext + context.codingPath.map { $0.stringValue })")
            throw DecodingError.dataCorrupted(context)
        } catch let DecodingError.keyNotFound(key, context) {
            // 处理键未找到的错误
            print("Key '\(key.stringValue)' not found: \(context.debugDescription)")
            print("Coding path: \(errorContext + context.codingPath.map { $0.stringValue })")
            throw DecodingError.keyNotFound(key, context)
        } catch let DecodingError.valueNotFound(type, context) {
            // 处理值未找到的错误
            print("Value of type '\(type)' not found: \(context.debugDescription)")
            print("Coding path: \(errorContext + context.codingPath.map { $0.stringValue })")
            throw DecodingError.valueNotFound(type, context)
        } catch let DecodingError.typeMismatch(type, context) {
            // 处理类型不匹配的错误
            print("Type mismatch for type '\(type)': \(context.debugDescription)")
            print("Coding path: \(errorContext + context.codingPath.map { $0.stringValue })")
            throw DecodingError.typeMismatch(type, context)
        } catch {
            // 捕获所有其他错误
            print("Decoding error: \(error)")
            throw error
        }
    }
}
