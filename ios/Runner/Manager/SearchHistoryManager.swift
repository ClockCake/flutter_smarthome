//
//  SearchHistoryManager.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/10/12.
//

import Foundation

class SearchHistoryManager {
    private let historyKey = "searchHistory"
    private let maxHistoryCount = 20  // 可根据需要设置历史记录的最大数量

    // 保存搜索记录
    func saveSearchRecord(_ query: String) {
        var searchHistory = getSearchHistory()
        
        // 移除重复的记录
        if let index = searchHistory.firstIndex(of: query) {
            searchHistory.remove(at: index)
        }
        
        // 将新的搜索记录添加到最前面
        searchHistory.insert(query, at: 0)
        
        // 限制历史记录的数量
        if searchHistory.count > maxHistoryCount {
            searchHistory = Array(searchHistory.prefix(maxHistoryCount))
        }
        
        UserDefaults.standard.set(searchHistory, forKey: historyKey)
    }

    // 获取搜索历史
    func getSearchHistory() -> [String] {
        return UserDefaults.standard.array(forKey: historyKey) as? [String] ?? []
    }

    // 清空搜索历史
    func clearSearchHistory() {
        UserDefaults.standard.removeObject(forKey: historyKey)
    }
}
