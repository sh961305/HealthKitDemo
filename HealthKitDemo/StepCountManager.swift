//
//  StepCountManager.swift
//  HealthKitDemo
//
//  Created by zcon on 2019/2/27.
//  Copyright © 2019 zcon. All rights reserved.
//

import Foundation
import HealthKit

/*
 *  Step 1：先開啟專案內 Capabilities 的 HealthKit
 *  Step 2：在 info.plist 裡面新增key "NSHealthShareUsageDescription"
 */

/// 透過iOS的健康App取得使用者的步行數
class StepCountManager: NSObject
{
    static var shared = StepCountManager()
    
    let healthStore = HKHealthStore()
    let type = HKObjectType.quantityType(forIdentifier: .stepCount)!
    
    /// 檢查該裝置是否支援HealthKit
    ///
    /// - Returns: 若支援則回傳true，反之false
    class func isAvailable() -> Bool
    {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    /// 向使用者請求授權
    ///
    /// - Parameter completion: 請求授權的結果
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void)
    {
        healthStore.requestAuthorization(toShare: nil, read: Set([type]), completion: completion)
    }
    
    /// 取得今日總共的步行數
    ///
    /// - Parameter resultsHandler: 回傳結果
    func getTodayTotalCount(resultsHandler: @escaping (Int) -> Void)
    {
        queryForToday { (query, data, error) in
            
            var count = 0
            
            if let results = data as? [HKQuantitySample]
            {
                for result in results
                {
                    count += Int(result.quantity.doubleValue(for: HKUnit.count()))
                }
            }
            
            resultsHandler(count)
        }
    }
    
    func queryForTodaySortByStartDate(limit: Int = HKObjectQueryNoLimit,
                                      resultsHandler: @escaping (HKSampleQuery, [HKSample]?, Error?) -> Void)
    {
        queryForToday(limit: limit,
                      sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)],
                      resultsHandler: resultsHandler)
    }
    
    func queryForToday(limit: Int = HKObjectQueryNoLimit,
                       sortDescriptors: [NSSortDescriptor]? = nil,
                       resultsHandler: @escaping (HKSampleQuery, [HKSample]?, Error?) -> Void)
    {
        let q = query(predicate: predicateForToday(),
                      limit: limit,
                      sortDescriptors: sortDescriptors,
                      resultsHandler: resultsHandler)
        
        healthStore.execute(q)
    }
    
    func query(predicate: NSPredicate? = nil,
               limit: Int = HKObjectQueryNoLimit,
               sortDescriptors: [NSSortDescriptor]? = nil,
               resultsHandler: @escaping (HKSampleQuery, [HKSample]?, Error?) -> Void) -> HKSampleQuery
    {
        return HKSampleQuery(sampleType: type,
                             predicate: predicate,
                             limit: HKObjectQueryNoLimit,
                             sortDescriptors: sortDescriptors,
                             resultsHandler: resultsHandler)
    }
    
    func predicateForToday() -> NSPredicate
    {
        let calendar = Calendar.current
        let now = Date()
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = 0
        components.minute = 0
        components.second = 0
        
        let startDate = calendar.date(from: components)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate!)
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        
        return predicate
    }
}
