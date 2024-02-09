//
//  ContentView.swift
//  AlamofireSample
//
//  Created by no name on 2024/02/09.
//  
//

import SwiftUI
import Alamofire

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Button("GET") {
                Task {
                    do {
                        let response = try await sampleGet()
                        print("--------")
                        print(response)
                    } catch {
                        print(error)
                    }
                }
            }
            Button("POST") {
                Task {
                    do {
                        let response = try await samplePost()
                        print("--------")
                        print(response)
                    } catch {
                        print(error)
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

let urlBase = "https://httpbin.org"

func sampleGet() async throws -> SampleResponseGet {
    print("GET")
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    let param = SampleRequest(paramA: "valueA", paramB: "valueB")
    let request = session.request(urlBase + "/get", method: .get, parameters: param, encoder: URLEncodedFormParameterEncoder.default)
    let response = await request
        .serializingDecodable(SampleResponseGet.self, decoder: decoder)
        .response
    switch response.result {
    case .success(let data):
        print("---- success ----")
        print(data)
        return data
    case .failure(let error):
        throw error
    }
}

func samplePost() async throws -> SampleResponsePost {
    print("POST")
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    let param = SampleRequest(paramA: "valueA", paramB: "valueB")
    let request = session.request(urlBase + "/post", method: .post, parameters: param, encoder: JSONParameterEncoder.default)
    let response = await request
        .serializingDecodable(SampleResponsePost.self, decoder: decoder)
        .response
    switch response.result {
    case .success(let data):
        print("---- success ----")
        print(data)
        return data
    case .failure(let error):
        throw error
    }
}

struct SampleRequest: Codable {
    let paramA: String
    let paramB: String
}

struct SampleResponseGet: Codable {
    let args: SampleResponseArgs
    struct SampleResponseArgs: Codable {
        let paramA: String
        let paramB: String
    }
}

struct SampleResponsePost: Codable {
    let json: SampleResponseJson
    struct SampleResponseJson: Codable {
        let paramA: String
        let paramB: String
    }
}

final class Logger: EventMonitor {
    let queue = DispatchQueue(label: "XXXX")

    // Event called when any type of Request is resumed.
    func requestDidResume(_ request: Request) {
        print("Resuming: \(request)")
    }

    // Event called whenever a DataRequest has parsed a response.
    func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        debugPrint("Finished: \(response)")
//        debugPrint("Finished: \(response.debugDescription)")
    }
}

let logger = Logger()
let session = Session(eventMonitors: [logger])
