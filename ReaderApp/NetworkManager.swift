//
//  NetworkManager.swift
//  ReaderApp
//
//  Created by Rahul on 13/09/25.
//

import Foundation
import Network

enum ResponseError: Error {
    case notReachable
    case decodingError
    case noDataFound
    case errorWithStatusCode(Int)
}

class NetworkManager {
    
    static let shared = NetworkManager()
    private init() {}
    
    /// Check network availability (async version, no blocking)
    func isNetworkAvailable() async -> Bool {
        await withCheckedContinuation { continuation in
            let monitor = NWPathMonitor()
            let queue = DispatchQueue(label: "NetworkMonitor")
            
            monitor.pathUpdateHandler = { path in
                continuation.resume(returning: path.status == .satisfied)
                monitor.cancel()
            }
            
            monitor.start(queue: queue)
        }
    }
    
    /// Generic request function
    func request<T: Decodable>(_ type: T.Type, from url: URL) async -> Result<T, ResponseError> {
        // Network check
        let available = await isNetworkAvailable()
        guard available else {
            return .failure(.notReachable)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.notReachable)
            }
            
            guard (200..<300).contains(httpResponse.statusCode) else {
                return .failure(.errorWithStatusCode(httpResponse.statusCode))
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            guard let model = try? decoder.decode(T.self, from: data) else {
                return .failure(.decodingError)
            }
            
            return .success(model)
            
        } catch {
            return .failure(.notReachable)
        }
    }
}

