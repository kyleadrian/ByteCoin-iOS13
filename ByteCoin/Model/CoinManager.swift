//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdateLastPrice(_ CoinManager: CoinManager, price: String);
    func didFailWithError(error: Error);
}

struct CoinManager {
    
    let baseURL = "https://apiv2.bitcoinaverage.com/indices/global/ticker/BTC"
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    var delegate: CoinManagerDelegate?
    
    func getCoinPrice(for currency: String) {
        let url = "\(baseURL)\(currency)"
        
        fetchData(from: url)
    }
    
    func fetchData(from urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    // Always add a return after an error to end the function.
                    return
                }
                
                if let safeData = data {
                    if let price = self.parseJSON(from: safeData) {
                        let priceString = String(format:"%.2f", price)
                        self.delegate?.didUpdateLastPrice(self, price: priceString)
                    }
                }
                
            }
            
            task.resume()
        }
    }
    
    func parseJSON(from data: Data) -> Double? {
        let decoder = JSONDecoder();
        
        do {
           let decodedData =  try decoder.decode(CoinData.self, from: data);
            let lastPrice = decodedData.last
            
            return lastPrice
        } catch  {
            delegate?.didFailWithError(error: error)
            return nil
        }
       }
    
}
