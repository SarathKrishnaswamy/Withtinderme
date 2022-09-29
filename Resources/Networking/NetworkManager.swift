//
//  NetworkManager.swift
//  NTrust
//
//  Created by Waseem Akram on 03/12/20.
//

import Foundation
import RSLoadingView
import RAMAnimatedTabBarController

/// Set the alert to show the network alert
struct NetworkError: Error, LocalizedError {
    let errorDescription: String?
    
    init(_ description: String) {
        errorDescription = description
    }
    
    static var invalidURL = NetworkError("Invalid URL")
    static var NoResponseError = NetworkError("No Response from server")
}

/// get the http method
enum HTTPMethod: String {
    case GET, POST, PUT, UPDATE, DELETE, OPTION, HEAD
}

/// Check the http status code
struct statusHttpCode{
    static var statusCode = Int()
}


/// This class is used to set the network of session configuration with json decoder and used the logout api call here
final class NetworkManager {
        
    var sessionConfiguration: URLSessionConfiguration
    var jsonDecoder: JSONDecoder
   // var token: String?
    
    let logoutModel = LiveData<DataOkModel, Error>(value: nil)
    let refreshTokenModel = LiveData<RefreshTokenModel, Error>(value: nil)
    
    init(configuration: URLSessionConfiguration = .default, jsonDecoder: JSONDecoder = JSONDecoder(), token: String? = nil){
        self.sessionConfiguration = configuration
        self.jsonDecoder = jsonDecoder
       // self.token = SessionManager.sharedInstance.getAccessToken
    }
    
    
    static let shared = NetworkManager()
    
    var defaultHeaders = [
        "Content-Type": "application/json",
        "Accept": "application/json",
    ]
    
    /// Used th generics <T> to pass any if the data types here with returning the void with loader
    /// - Parameters:
    ///   - url: Enter the api call url here
    ///   - query: Set the body of thr params here
    ///   - headers: Set the headers here
    ///   - completion: Get the result in the get method and set in the decode json model
    public func get<T: Decodable>(url: String, query: [String: String]? = nil, headers: [String: String] = [:], completion: @escaping (Result<T, Error>)->Void) {
        
        DispatchQueue.main.async {
                RSLoadingView().showOnKeyWindow()
            }

        guard var url = URL(string: url) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        if let query = query {
            guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                completion(.failure(NetworkError.invalidURL))
                return
            }
            urlComponents.queryItems = query.map { URLQueryItem(name: $0, value: $1) }
            guard let urlWithQuery = urlComponents.url else {
                completion(.failure(NetworkError.invalidURL))
                return
            }
            url = urlWithQuery
        }
        

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = HTTPMethod.GET.rawValue
        defaultHeaders.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }
        headers.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }
        
       // if let token = SessionManager.sharedInstance.getAccessToken {
            urlRequest.addValue("Bearer \(SessionManager.sharedInstance.getAccessToken)", forHTTPHeaderField: "Authorization")
       // }
        
        let session = URLSession(configuration: sessionConfiguration)
        session.dataTask(with: urlRequest as URLRequest, completionHandler: { [weak self] (data, response, error) in
            DispatchQueue.main.async {
                DispatchQueue.main.async {
                RSLoadingView.hideFromKeyWindow()
            }
            }
            guard let self = self else {
                return
            }
            
            let result: Result<T, Error> = self.decodeJsonAndCreateModel(data: data, response: response, error: error)
            DispatchQueue.main.async {
                completion(result)
            }
            
        }).resume()
    }
    
    /// Delete method api will be called here with loader
    public func deleteCall<T: Decodable>(url: String, query: [String: String]? = nil, headers: [String: String] = [:], completion: @escaping (Result<T, Error>)->Void) {
        
        DispatchQueue.main.async {
                RSLoadingView().showOnKeyWindow()
            }

        guard var url = URL(string: url) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        if let query = query {
            guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                completion(.failure(NetworkError.invalidURL))
                return
            }
            urlComponents.queryItems = query.map { URLQueryItem(name: $0, value: $1) }
            guard let urlWithQuery = urlComponents.url else {
                completion(.failure(NetworkError.invalidURL))
                return
            }
            url = urlWithQuery
        }
        

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = HTTPMethod.DELETE.rawValue
        defaultHeaders.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }
        headers.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }
        
       // if let token = SessionManager.sharedInstance.getAccessToken {
            urlRequest.addValue("Bearer \(SessionManager.sharedInstance.getAccessToken)", forHTTPHeaderField: "Authorization")
       // }
        
        let session = URLSession(configuration: sessionConfiguration)
        session.dataTask(with: urlRequest as URLRequest, completionHandler: { [weak self] (data, response, error) in
            DispatchQueue.main.async {
                DispatchQueue.main.async {
                RSLoadingView.hideFromKeyWindow()
            }
            }
            guard let self = self else {
                return
            }
            
            let result: Result<T, Error> = self.decodeJsonAndCreateModel(data: data, response: response, error: error)
            DispatchQueue.main.async {
                completion(result)
            }
            
        }).resume()
    }
    
    
    /// Used th generics <T> to pass any if the data types here with returning the void without loader
    /// - Parameters:
    ///   - url: Enter the api call url here
    ///   - query: Set the body of thr params here
    ///   - headers: Set the headers here
    ///   - completion: Get the result in the get method and set in the decode json model
    public func getNoLoading<T: Decodable>(url: String, query: [String: String]? = nil, headers: [String: String] = [:], completion: @escaping (Result<T, Error>)->Void) {
        
//        DispatchQueue.main.async {
//                RSLoadingView().showOnKeyWindow()
//            }

        print("URL\(url)")
        guard var url = URL(string: url) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        if let query = query {
            guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                completion(.failure(NetworkError.invalidURL))
                return
            }
            urlComponents.queryItems = query.map { URLQueryItem(name: $0, value: $1) }
            guard let urlWithQuery = urlComponents.url else {
                completion(.failure(NetworkError.invalidURL))
                return
            }
            url = urlWithQuery
        }
        

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = HTTPMethod.GET.rawValue
        defaultHeaders.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }
        headers.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }
        
       // if let token = SessionManager.sharedInstance.getAccessToken {
            urlRequest.addValue("Bearer \(SessionManager.sharedInstance.getAccessToken)", forHTTPHeaderField: "Authorization")
       // }
        
        let session = URLSession(configuration: sessionConfiguration)
        session.dataTask(with: urlRequest as URLRequest, completionHandler: { [weak self] (data, response, error) in
            DispatchQueue.main.async {
//                DispatchQueue.main.async {
//                RSLoadingView.hideFromKeyWindow()
//            }
            }
            guard let self = self else {
                return
            }
            
            let result: Result<T, Error> = self.decodeJsonAndCreateModel(data: data, response: response, error: error)
            DispatchQueue.main.async {
                completion(result)
            }
            
        }).resume()
    }
    
    /// Call the post method with serialization request model has been called here
    func post<T: Decodable>(url: String, body: [String: Any], headers: [String: String] = [:], completion: @escaping (Result<T, Error>)->Void) {
        serializedRequest(method: .POST, url: url, body: body, completion: completion)
    }
    
    /// No loader post method has been called from view m,odel
    func NoLoadingpost<T: Decodable>(url: String, body: [String: Any], headers: [String: String] = [:], completion: @escaping (Result<T, Error>)->Void) {
        serializedRequestNoLoading(method: .POST, url: url, body: body, completion: completion)
    }
    
    ///Put methid is called to set the serialised request using put method
    func put<T: Decodable>(url: String, body: [String: Any], headers: [String: String] = [:], completion: @escaping (Result<T, Error>)->Void) {
        serializedRequest(method: .PUT, url: url, body: body, completion: completion)
    }
    
    /// Call the delete method using serialiazed request with headers to set the delete method
    func delete<T: Decodable>(url: String, body: [String: Any], headers: [String: String] = [:], completion: @escaping (Result<T, Error>)->Void) {
        serializedRequest(method: .DELETE, url: url, body: body, completion: completion)
    }
    
    /// Update the values in the decodable with serialization request of string
    func update<T: Decodable>(url: String, body: [String: Any], headers: [String: String] = [:], completion: @escaping (Result<T, Error>)->Void) {
        serializedRequest(method: .UPDATE, url: url, body: body, completion: completion)
    }
    
    /// Get all the values here with http methiod and get the completion of decoding with the crypto helper using the aes encryption
    private func serializedRequest<T: Decodable>(method: HTTPMethod, url:String, body: [String: Any], headers: [String: String] = [:], completion: @escaping (Result<T, Error>)->Void) {

        let originalUrl = url.components(separatedBy: "/")
        let lastUrlString = originalUrl.last
                
        guard let url = URL(string: url) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
     
        var urlRequest = URLRequest(url: url)

        ///AES Converstion
        do {
            let jsonParamsData = try JSONSerialization.data(withJSONObject: body, options: [])
            let paramJsonString = String(decoding: jsonParamsData, as: UTF8.self)
            debugPrint(paramJsonString)
            let encrypedString = CryptoHelper.encrypt(input: paramJsonString)
            debugPrint("Encrypted String =",encrypedString ?? "")
            let encrypedKey = "\(encrypedString ?? "")"
            let param = ["key":encrypedKey]
            let jsonData: NSData = try JSONSerialization.data(withJSONObject: param , options: []) as NSData
            urlRequest.httpBody = jsonData as Data
            //urlRequest.timeoutInterval = 120.0
            
        }catch{
            debugPrint(error.localizedDescription)
        }
        
       // urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        urlRequest.httpMethod = method.rawValue
        defaultHeaders.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }
        headers.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }
        
     //   if let token = SessionManager.sharedInstance.getAccessToken {
            urlRequest.addValue("Bearer \(SessionManager.sharedInstance.getAccessToken)", forHTTPHeaderField: "Authorization")
     //   }
        print("url\(url)")
        print("body\(body)")

        if lastUrlString ?? "" != "conversationCommentList" {
            RSLoadingView().showOnKeyWindow()
        }
        
        let session = URLSession(configuration: sessionConfiguration)
        session.dataTask(with: urlRequest as URLRequest, completionHandler: { [weak self] (data, response, error) in
            DispatchQueue.main.async {
                RSLoadingView.hideFromKeyWindow()
                print()
            }
            guard let self = self else { return }
            let model: Result<T, Error> = self.decodeJsonAndCreateModel(data: data, response: response, error: error)
            DispatchQueue.main.async {
                completion(model)
            }
        }).resume()
    }
    
    /// No loading with the serialized request of each method in the string of encryption and decryption store to json decoder
    private func serializedRequestNoLoading<T: Decodable>(method: HTTPMethod, url:String, body: [String: Any], headers: [String: String] = [:], completion: @escaping (Result<T, Error>)->Void) {

        let originalUrl = url.components(separatedBy: "/")
        let lastUrlString = originalUrl.last
                
        guard let url = URL(string: url) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
     
        var urlRequest = URLRequest(url: url)

        ///AES Converstion
        do {
            let jsonParamsData = try JSONSerialization.data(withJSONObject: body, options: [])
            let paramJsonString = String(decoding: jsonParamsData, as: UTF8.self)
            debugPrint(paramJsonString)
            let encrypedString = CryptoHelper.encrypt(input: paramJsonString)
            debugPrint("Encrypted String =",encrypedString ?? "")
            let encrypedKey = "\(encrypedString ?? "")"
            let param = ["key":encrypedKey]
            let jsonData: NSData = try JSONSerialization.data(withJSONObject: param , options: []) as NSData
            urlRequest.httpBody = jsonData as Data
            //urlRequest.timeoutInterval = 120.0
            
        }catch{
            debugPrint(error.localizedDescription)
        }
        
       // urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        urlRequest.httpMethod = method.rawValue
        defaultHeaders.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }
        headers.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }
        
     //   if let token = SessionManager.sharedInstance.getAccessToken {
            urlRequest.addValue("Bearer \(SessionManager.sharedInstance.getAccessToken)", forHTTPHeaderField: "Authorization")
     //   }
        print("url\(url)")
        print("body\(body)")

        if lastUrlString ?? "" != "conversationCommentList" {
            //RSLoadingView().showOnKeyWindow()
        }
        
        let session = URLSession(configuration: sessionConfiguration)
        session.dataTask(with: urlRequest as URLRequest, completionHandler: { [weak self] (data, response, error) in
            DispatchQueue.main.async {
                RSLoadingView.hideFromKeyWindow()
            }
            guard let self = self else { return }
            let model: Result<T, Error> = self.decodeJsonAndCreateModel(data: data, response: response, error: error)
            DispatchQueue.main.async {
                completion(model)
            }
        }).resume()
    }
    
    /// Decode the json model and create a model  with the response and check the sttaus code
    private func decodeJsonAndCreateModel<T: Decodable>(data: Data?, response: URLResponse?, error: Error?) -> Result<T, Error> {
        if let error = error {
            return .failure(error)
        }
        else {
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(NetworkError.NoResponseError)
            }
            
            guard let data = data else {
                return .failure(NetworkError("No Data returned"))
            }
             
            do {
                guard (200..<300) ~= httpResponse.statusCode else {
                    print(httpResponse.statusCode)
                    if httpResponse.statusCode == 401 { //Logout - User does not exsits
                       
                        getLogoutApiCall()
                                                
                        return .failure(NetworkError("User does not exist"))
                    }else if httpResponse.statusCode == 403 { //refresh token - token expires
                        
                        self.refreshTokenObserver()

                        DispatchQueue.main.async {
                            self.refreshTokenAPICall()
                        }
                      
                        return .failure("")
                    }
                    else if httpResponse.statusCode == 500{
                        let jsonArray = try JSONSerialization.jsonObject(with: data, options : []) as? NSDictionary
                        //let message = jsonArray?.value(forKey: "message") as? String ?? ""
                        return .failure(NetworkError(jsonArray?.value(forKey: "message") as? String ?? ""))
                    }
                    
                    else if httpResponse.statusCode == 404{
                        statusHttpCode.statusCode = httpResponse.statusCode
                        let jsonArray = try JSONSerialization.jsonObject(with: data, options : []) as? NSDictionary
                       // let message = jsonArray?.value(forKey: "message") as? String ?? ""
                        //HomeCall()
                        return .failure(NetworkError(jsonArray?.value(forKey: "message") as? String ?? ""))
                    }
                    
                    else{
                        statusHttpCode.statusCode = httpResponse.statusCode
                        let jsonArray = try JSONSerialization.jsonObject(with: data, options : []) as? NSDictionary
                        let message = jsonArray?.value(forKey: "message") as? String ?? ""
                        if message == ""{
                            return .failure("")
                        }
                        else{
                            return .failure(NetworkError(jsonArray?.value(forKey: "message") as? String ?? ""))
                        }

                        
                    }
                    
                   
                }
                
                let decryptedResponse = CryptoHelper.decrypt(input: "\(String(data: data, encoding: .utf8) ?? "")")
                let decryptedData = decryptedResponse?.data(using: .utf8)!
                
                if let jsonArray = try JSONSerialization.jsonObject(with: decryptedData ?? Data.init(), options : []) as? NSDictionary
                {
                    debugPrint(jsonArray)
                }
                if let JSONString = String(data: decryptedData ?? Data(), encoding: String.Encoding.utf8) {
                       print(JSONString)
                    }
                
                let model = try self.jsonDecoder.decode(T.self, from: decryptedData ?? Data.init())
                
                return .success(model)
            }catch let error {
                //decoding error
                print(error)
                return .failure(NetworkError("Oops! Something went wrong"))
            }
        }
    }
    
    func showErrorAlert(error: String){
        DispatchQueue.main.async {
            
            
            CustomAlertView.shared.showCustomAlert(title: "Spark me",
                                                   message: error,
                                                   alertType: .oneButton(),
                                                   alertRadius: 30,
                                                   btnRadius: 20)
        }
    }
    
    /// Set the logout api call if there is user does not exist
    func getLogoutApiCall() {
        
        get(port: 1, endpoint: .logOut) { [weak self] (result: Result<DataOkModel, Error>) in
            guard let self = self else { return }
            
            switch result {
                
            case .success(let editProfileData):
                
                self.logoutModel.value = editProfileData
                
                if !SessionManager.sharedInstance.getUserId.isEmpty {
                    SocketIOManager.sharedSocketInstance.disconnectSocket()
                }

                SessionManager.sharedInstance.getUserId = ""
                SessionManager.sharedInstance.isUserLoggedIn = false
                SessionManager.sharedInstance.isMobileNumberVerified = false
                
                let storyBoard : UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
                let noInternetVC = storyBoard.instantiateViewController(withIdentifier: "LoginTableViewController") as! LoginTableViewController
                let navController = UIApplication.shared.keyWindow?.rootViewController as! UINavigationController
                navController.pushViewController(noInternetVC, animated: true)
                
            case .failure(let error):
                self.logoutModel.error = error
                debugPrint("error")
            }
        }
                
    }
    
    ///Call the home page with tab bar
    func HomeCall() {
        
        DispatchQueue.main.async {
            let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
            let homeVC = storyBoard.instantiateViewController(identifier: TABBAR_STORYBOARD) as! RAMAnimatedTabBarController
            let navigationController = UINavigationController(rootViewController: homeVC)
            UIApplication.shared.windows.first?.rootViewController = navigationController
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
       
        
        
    }
    
    /// Refresh the token using refresh token api call
    func refreshTokenAPICall() {
            
            let params = ["refreshToken": SessionManager.sharedInstance.getRefreshToken,"userId": SessionManager.sharedInstance.getUserId]
            
            post(port: 1, endpoint: .refreshToken, body: params) { [weak self] (result: Result<RefreshTokenModel, Error>) in
                guard let self = self else { return }
                
                switch result {
                
                case .success(let timelineData):
                    self.refreshTokenModel.value = timelineData
                    debugPrint("success")
                    
                    var parentVC: UIViewController?
                    parentVC?.navigationController?.pushViewController(HomeViewController(), animated: false)

                case .failure(let error):
                    self.refreshTokenModel.error = error
                    debugPrint("failed")
                    
                }
            }
        }
        /// Check the refresh token observer
        func refreshTokenObserver() {
            
            refreshTokenModel.observeError = { [weak self] error in
                guard let self = self else { return }
                //Show alert here
                self.showErrorAlert(error: error.localizedDescription)
            }
            refreshTokenModel.observeValue = { [weak self] value in
                guard let self = self else { return }
                
                if value.isOk ?? false {
                    self.HomeCall()
                    SessionManager.sharedInstance.getAccessToken = value.data?.accessToken ?? ""
                    SessionManager.sharedInstance.getRefreshToken = value.data?.refreshModel ?? ""
                    
                }
            }
            
        }
    
    
}




//MARK:- Network mananger endpoints extension
///Network manager to set all the updates like post , get, delete and update values are here
extension NetworkManager {
    
    func get<T: Decodable>(port: Int, endpoint: Endpoints, query: [String: String]? = nil, headers: [String: String] = [:], completion: @escaping (Result<T, Error>)->Void) {
        self.get(url: endpoint.fullUrl(port: port), query: query, headers: headers, completion: completion)
    }
    
    func getnoLoading<T: Decodable>(port: Int, endpoint: Endpoints, query: [String: String]? = nil, headers: [String: String] = [:], completion: @escaping (Result<T, Error>)->Void) {
        self.getNoLoading(url: endpoint.fullUrl(port: port), query: query, headers: headers, completion: completion)
    }
    
    func post<T: Decodable>(port: Int, endpoint: Endpoints, body: [String: Any], headers: [String: String] = [:], completion: @escaping (Result<T, Error>)->Void) {
        self.post(url: endpoint.fullUrl(port: port), body: body, headers: headers, completion: completion)
    }
    
    func postNoLoading<T: Decodable>(port: Int, endpoint: Endpoints, body: [String: Any], headers: [String: String] = [:], completion: @escaping (Result<T, Error>)->Void) {
        self.NoLoadingpost(url: endpoint.fullUrl(port: port), body: body, headers: headers, completion: completion)
    }
    
    func put<T: Decodable>(port: Int, endpoint: Endpoints, body: [String: Any], headers: [String: String] = [:], completion: @escaping (Result<T, Error>)->Void) {
        self.put(url: endpoint.fullUrl(port: port), body: body, headers: headers, completion: completion)
    }
    
    func delete<T: Decodable>(port: Int, endpoint: Endpoints, body: [String: Any], headers: [String: String] = [:], completion: @escaping (Result<T, Error>)->Void) {
        self.delete(url: endpoint.fullUrl(port: port), body: body, headers: headers, completion: completion)
    }
    
    func deleteData<T: Decodable>(port: Int, endpoint: Endpoints, query: [String: String]? = nil, headers: [String: String] = [:], completion: @escaping (Result<T, Error>)->Void) {
        self.deleteCall(url: endpoint.fullUrl(port: port), query: query, headers: headers, completion: completion)
    }
    
    
    func update<T: Decodable>(port: Int, endpoint: Endpoints, body: [String: Any], headers: [String: String] = [:], completion: @escaping (Result<T, Error>)->Void) {
        self.update(url: endpoint.fullUrl(port: port), body: body, headers: headers, completion: completion)
    }
    
    
    
    
    
}



