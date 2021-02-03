//
//  DataDragonChampionBusiness.swift
//  LeagueAPI
//
//  Created by Antoine Clop on 8/17/18.
//  Copyright © 2018 Antoine Clop. All rights reserved.
//

import Foundation

internal class DataDragonChampionBusiness {
    
    public static func getChampionDetails(iso : String,by championId: ChampionId, completion: @escaping (ChampionDetails?, String?) -> Void) {
        let filterFunction: ((String, ChampionsDetails)) -> Bool = { (keyValue) -> Bool in
            let (_, value) = keyValue
            return value.championId == championId
        }
        let filterEqualValue: String = "id=\(championId)"
        getChampionDetails(iso: iso,filterFunction: filterFunction, filterEqualValue: filterEqualValue, completion: completion)
    }
    
    public static func getChampionDetails(iso : String,byName name: String, completion: @escaping (ChampionDetails?, String?) -> Void) {
        let filterFunction: ((String, ChampionsDetails)) -> Bool = { (keyValue) -> Bool in
            let (_, value) = keyValue
            return value.name.equals(name) || value.championIdName.equals(name)
        }
        let filterEqualValue: String = "name=\(name)"
        getChampionDetails(iso: iso,filterFunction: filterFunction, filterEqualValue: filterEqualValue, completion: completion)
    }
    
    public static func getAllChampionIds(iso : String,completion: @escaping ([ChampionId]?, String?) -> Void) {
        getAllChampions(iso: iso) { (champions, error) in
            completion(champions?.map { return $0.championId }, error)
        }
    }
    
    public static func getAllChampionNames(iso : String,completion: @escaping ([String]?, String?) -> Void) {
        getAllChampions(iso: iso) { (champions, error) in
            completion(champions?.map { return $0.name }, error)
        }
    }
    
    public static func getChampions(iso: String,for role: ChampionRole, completion: @escaping ([String]?, String?) -> Void) {
        let filterFunction: ((String, ChampionsDetails)) -> Bool = { (keyValue) -> Bool in
            let (_, value) = keyValue
            return value.roles.contains { $0 == role }
        }
        getChampionsFiltered(iso: iso,filterFunction: filterFunction) { (champions, error) in
            completion(champions?.map { return $0.name }, error)
        }
    }
    
    private static func getAllChampions(iso: String, completion: @escaping ([ChampionsDetails]?, String?) -> Void) {
        let filterFunction: ((String, ChampionsDetails)) -> Bool = { (_) -> Bool in
            return true
        }
        getChampionsFiltered(iso: iso,filterFunction: filterFunction) { (champions, error) in
            completion(champions, error)
        }
    }
    
    private static func getChampionsFiltered(iso : String , filterFunction: @escaping ((String, ChampionsDetails)) -> Bool, completion: @escaping ([ChampionsDetails]?, String?) -> Void) {
        DataDragonRequester.instance.getChampionsDetails(iso: iso) { (champions, error) in
            completion(champions?.champions.filter(filterFunction).map { return $0.value }, error)
        }
    }
    
    private static func getChampionDetails(iso: String, filterFunction: @escaping ((String, ChampionsDetails)) -> Bool, filterEqualValue: String = "", completion: @escaping (ChampionDetails?, String?) -> Void) {
        getChampionsFiltered(iso: iso,filterFunction: filterFunction) { (champions, error) in
            if let champions = champions {
                if let championWithFilter = champions.first {
                    let championIdName: String = championWithFilter.championIdName
                    DataDragonRequester.instance.getChampionAdditionalDetails(name: championIdName) { (champion, error) in
                        if let champion = champion {
                            if let championAdditionalDetails = champion.champion[championIdName] {
                                let championDetails: ChampionDetails = ChampionDetails(details: championWithFilter, additionalDetails: championAdditionalDetails)
                                completion(championDetails, nil)
                            }
                            else {
                                completion(nil, "Champion \(filterEqualValue == "" ? "" : "with \(filterEqualValue) ")is \(championWithFilter.name), but additional details was not found.")
                            }
                        }
                        else {
                            completion(nil, error)
                        }
                    }
                }
                else {
                    completion(nil, "Champion \(filterEqualValue == "" ? "" : "with \(filterEqualValue) ")not found.")
                }
            }
            else {
                completion(nil, error)
            }
        }
    }
}
