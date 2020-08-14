//
//  DataFetcher.swift
//  iOS14WidgetKitStaticConfiguration
//
//  Created by Anupam Chugh on 01/07/20.
//

import Foundation
import Combine


public class DataFetcher : ObservableObject{
    
    var cancellable : Set<AnyCancellable> = Set()
    
    static let shared = DataFetcher()
    
    func getJokes(completion: @escaping ([ChuckValue]?) -> Void){
        
        let urlComponents = URLComponents(string: "http://api.icndb.com/jokes/random/10/")!
        
        URLSession.shared.dataTaskPublisher(for: urlComponents.url!)
            .map{$0.data}
            .decode(type: ChuckJokes.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
 
        }) { response in
            completion(response.value)
        }
        .store(in: &cancellable)
    }
}


struct ChuckJokes : Decodable {

        let type : String?
        let value : [ChuckValue]?

        enum CodingKeys: String, CodingKey {
                case type = "type"
                case value = "value"
        }
    
        init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                type = try values.decodeIfPresent(String.self, forKey: .type)
                value = try values.decodeIfPresent([ChuckValue].self, forKey: .value)
        }

}

struct ChuckValue : Decodable {

        let id : Int?
        let joke : String?

        enum CodingKeys: String, CodingKey {
                case id = "id"
                case joke = "joke"
        }
    
        init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                id = try values.decodeIfPresent(Int.self, forKey: .id)
                joke = try values.decodeIfPresent(String.self, forKey: .joke)
        }
}

