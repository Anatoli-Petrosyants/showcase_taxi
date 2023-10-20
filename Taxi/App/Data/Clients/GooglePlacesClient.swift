//
//  GooglePlacesClient.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 20.10.23.
//

import Foundation
import Dependencies
import GoogleMaps
import GooglePlaces

struct GoogleAutocompletePrediction: Equatable {
    var placeID: String
    var attributedFullText: NSAttributedString
}

struct GooglePlacesResponse: Equatable {
    var googleAutocompletePredictions: [GoogleAutocompletePrediction]
}

struct GooglePlacesRequest {
    let query: String

    init(query: String) {
        self.query = query
    }
}

struct GooglePlacesClient {
    var autocompletePredictions: @Sendable (GooglePlacesRequest) async throws -> GooglePlacesResponse
}

extension DependencyValues {
    var googlePlacesClient: GooglePlacesClient {
        get { self[GooglePlacesClient.self] }
        set { self[GooglePlacesClient.self] = newValue }
    }
}

extension GooglePlacesClient: DependencyKey {
    static let liveValue: Self = {
        let token = GMSAutocompleteSessionToken.init()
        let placesClient = GMSPlacesClient()
        
        return Self(
            autocompletePredictions: { data in
                return try await withCheckedThrowingContinuation { continuation in
                    placesClient.findAutocompletePredictions(fromQuery: data.query,
                                                             filter: nil,
                                                             sessionToken: token) { (results, error) in
                        if let err = error {
                            continuation.resume(with: .failure(err))
                            return
                        }
                        
                        if let results = results {
                            let response = results.compactMap {
                                GoogleAutocompletePrediction(placeID: $0.placeID,
                                                             attributedFullText: $0.attributedFullText)
                            }
                            
                            continuation.resume(
                                returning: GooglePlacesResponse(googleAutocompletePredictions: response)
                            )
                        }
                    }
                }
            }
        )
    }()
}
