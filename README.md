# 💧PlumbKit💧 

## Overview
PlumbKit is a pure-Swift networking package that leverages `Combine`, `Codable`, and `URLSession` to interact with APIs. Inspired and modified from [WireKit](https://github.com/afterxleep/WireKit)

## Installation
This package only supports SPM at the moment. The easiest way to import it is via Xcode with `File > Add Packages...` and copy and paste the GitHub URL into the top-right text box

## Usage
PlumbKit was designed to be very easy to use, and allows the developer to perform `HTTP` network requests through creating a struct and using `PlumbAPIClient`.

### Example `.GET`

1. Create a request that conforms to the `PlumbRequest` protocol

```swift
struct GetTodo: PlumbRequest {
   typealias ReturnType = Todo
   var path: String = "/Todo"
   var body: [String : Any?]?
}
```
2. Create a data manager class

```swift
import Combine

class TodoManager {
   static let shared = TodoManager()
   
   let apiClient = PlumbAPIClient(baseURL: "https://example.com")
   
   private var subscriptions = Set<AnyCancellable>()
   
   func getTodos(completion: @escaping (Todo) -> ()) {
      apiClient.dispatch(GetTodo())
         .sink(
            receiveCompletion: { completion in
               switch completion {
                  case .failure(let error):
                     print(error)
                  default:
                     break
               }
            },
            receiveValue: { todos in
               completion(todos)
            }
         )
         .store(in: &subscriptions)
   }
}
```
3. Use this method however you like 🥳

### Example using `.GET` with query parameters
In the following example, we are going to create a struct for the same `.GET` request as above but with pagination parameters:

```swift
struct GetTodos: PlumbRequest {
   typealias ReturnType = Todos
   var path: String = "/Todos"
   var queryItems: [String: String]? {
      [
         "pageSize": "15",
         "pageNumber": "\(pageNumber)"
      ]
   }
   var body: [String : Any?]?
   var pageNumber: Int
   init(forPage pageNumber: Int) {
      self.pageNumber = pageNumber
   }
}
```
### Example `.POST` request
```swift
struct CreateTodo: PlumbRequest {
   typealias ReturnType = CreateTodoResponse
   var path: String = "/Todo/Create"
   var methor: HTTPMethod = .POST
   var body: [String : Any]?
   init(_ body: [String : String]) {
      self.body = body.asDictionary
   }
}
```
### Current `PlumbRequest` Defaults
The following are the defaults for `PlumbRequest`
```swift
extension PlumbRequest {
    // Defaults
    var method: HTTPMethod { return .GET }
    var contentType: String { return "application/json" }
    var queryParams: [String: String]? { return nil }
    var body: [String: Any]? { return nil }
    var headers: [String: String]? { return nil }
    var queryItems: [String: String]? { return nil }
}
```
## Notes
I hope you find this library useful and README useful. For a more complete packet using the same techniques, refer to `WireKit` above.
