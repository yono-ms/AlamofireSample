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
                        let path = urlBase + "/get"
                        let parameters = SampleRequest(paramA: "valueA", paramB: "valueB")
                        let response: SampleResponse = try await sampleGeneric(path: path, method: .get, param: parameters)
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
                        let path = urlBase + "/post"
                        let parameters = SampleRequest(paramA: "valueA", paramB: "valueB")
                        let response: SampleResponse = try await sampleGeneric(path: path, method: .post, param: parameters)
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

func sampleGeneric<T: Codable>(
    path: String,
    method: HTTPMethod,
    param: Codable
) async throws -> T {
    let request = if method == .get {
        session.request(path, method: .get, parameters: param, encoder: URLEncodedFormParameterEncoder.default)
    } else {
        session.request(path, method: .post, parameters: param, encoder: JSONParameterEncoder.default)
    }
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    let response = await request
        .serializingDecodable(T.self, decoder: decoder)
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

struct SampleResponse: Codable {
    let args: SampleResponseArgs
    let json: SampleResponseJson?
}

struct SampleResponseArgs: Codable {
    let paramA: String?
    let paramB: String?
}

struct SampleResponseJson: Codable {
    let paramA: String
    let paramB: String
}

final class Logger: EventMonitor {
    let queue = DispatchQueue(label: "XXXX")

    // Event called when any type of Request is resumed.
    func requestDidResume(_ request: Request) {
//        print("Resuming: \(request)")
        let allHeaders = request.request.flatMap { $0.allHTTPHeaderFields.map { $0.description } } ?? "None"
        let headers = """
                ⚡️⚡️⚡️⚡️ Request Started: \(request)
                ⚡️⚡️⚡️⚡️ Headers: \(allHeaders)
                """
        NSLog(headers)
        
        
        let body = request.request.flatMap { $0.httpBody.map { String(decoding: $0, as: UTF8.self) } } ?? "None"
        let message = """
                ⚡️⚡️⚡️⚡️ Request Started: \(request)
                ⚡️⚡️⚡️⚡️ Body Data: \(body)
                """
        NSLog(message)
    }

    // Event called whenever a DataRequest has parsed a response.
    func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
//        debugPrint("Finished: \(response)")
        NSLog("⚡️⚡️⚡️⚡️ Response Received: \(response.debugDescription)")
        NSLog("⚡️⚡️⚡️⚡️ Response All Headers: \(String(describing: response.response?.allHeaderFields))")

    }
}

let logger = Logger()
let session = Session(eventMonitors: [logger])
