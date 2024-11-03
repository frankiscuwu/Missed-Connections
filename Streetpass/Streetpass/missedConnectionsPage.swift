//
//  missedConnectionsPage.swift
//  Streetpass
//
//  Created by Frank Yang on 11/2/24.
//
import SwiftUI
import MapKit
import Foundation

struct MissedConnectionsPage: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Example coordinates
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var messages: [String] = [
        "You missed a connection with Alice, a(n) Computer Science major from Stanford, earlier at -122.4184, 37.7749.\n\nBecause you were both at the same event.",
        "You missed a connection with Bob, a(n) Mechanical Engineering from MIT, earlier at -122.4194, 37.7750.\n\nHe is looking for someone to collaborate on a project."
    ]
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            Map(coordinateRegion: $region)
                .frame(width: 350, height: 300)
                .cornerRadius(10)
                .padding()
            
            GeometryReader { geometry in
                TabView {
                    if messages.isEmpty {
                        Text("Loading missed connections...")
                            .font(.title)
                            .frame(width: geometry.size.width - 40, height: 200)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                    } else {
                        ForEach(messages.prefix(3), id: \.self) { message in
                            Text(message)
                                .frame(width: geometry.size.width - 40, height: 200) // Full width minus padding
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                                .padding(.horizontal, 20) // Adds padding on left and right
                                .font(.system(size: 20))
                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .frame(height: 220) // Adjust height if needed
            }
            .padding(.horizontal, 20) // Margin for TabView itself
            
            HStack(spacing: 20) {
                Button(action: {
                    print("Delete button tapped")
                }) {
                    Text("Delete")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    print("Friend Request button tapped")
                }) {
                    Text("Friend Request")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            
            Spacer()
        }
        .navigationTitle("Missed Connections")
        .onAppear { fetchMessages() } // Call fetchMessages when the view appears
    }
    
    func unpackAIcall(completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let url = URL(string: "http://10.239.101.11:5000/get_users/") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "NoDataError", code: -1, userInfo: nil)))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    completion(.success(json))
                } else {
                    completion(.failure(NSError(domain: "InvalidJSONError", code: -1, userInfo: nil)))
                }
            } catch let parseError {
                completion(.failure(parseError))
            }
        }
        
        task.resume()
    }
    
    func fetchMissedConnectionMessages(completion: @escaping (Result<[String], Error>) -> Void) {
        unpackAIcall { result in
            switch result {
            case .success(let json):
                guard let recommendations = json["recommendations"] as? [[String: Any]] else {
                    completion(.failure(NSError(domain: "InvalidJSONError", code: -1, userInfo: nil)))
                    return
                }
                
                var messages: [String] = []
                
                for recommendation in recommendations {
                    guard
                        let person = recommendation["person"] as? String,
                        let major = recommendation["major"] as? String,
                        let school = recommendation["school"] as? String,
                        let latitude = recommendation["latitude"] as? Double,
                        let longitude = recommendation["longitude"] as? Double,
                        let reason = recommendation["reason"] as? String
                    else {
                        continue
                    }
                    
                    let message = "You missed a connection with \(person), a(n) \(major) from \(school), earlier at \(longitude), \(latitude).\n\(reason)"
                    messages.append(message)
                }
                
                completion(.success(messages))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchMessages() {
        fetchMissedConnectionMessages { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let newMessages):
                    self.messages.append(contentsOf: newMessages)
                case .failure(let error):
                    self.errorMessage = "Failed to load message: \(error.localizedDescription)"
                }
            }
        }
    }
}
#Preview {
    MissedConnectionsPage()
}
