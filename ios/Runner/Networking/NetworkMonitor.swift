//
//  NetworkMonitor.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/6/13.
//

import Network
import Network
import RxSwift
import RxCocoa

class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private let _isConnected = BehaviorRelay<Bool>(value: false)
    
    var isConnected: Observable<Bool> {
        return _isConnected.asObservable()
    }
    
    private init() {
        monitor = NWPathMonitor()
    }
    
    func startMonitoring() {
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?._isConnected.accept(path.status == .satisfied)
            }
        }
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
}

