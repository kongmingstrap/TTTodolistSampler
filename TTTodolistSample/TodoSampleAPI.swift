//
//  TodoSampleAPI.swift
//  TTTodolistSample
//

import Foundation
import APIKit

protocol TodoSampleRequest: Request {
    
}

extension TodoSampleRequest {
    var baseURL: NSURL {
        return NSURL(string: "http://localhost:9000")!
        //return NSURL(string: "http://enigmatic-dusk-9369.herokuapp.com")!
    }
}

class TodoSampleAPI: API {
    
    struct GetTodos: TodoSampleRequest {
        typealias Response = Todos<[String: AnyObject]>
        
        var method: HTTPMethod {
            return .GET
        }
        
        var path: String {
            return "/todos"
        }
        
        func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) -> Response? {
            guard let dictionaries = object as? [[String: AnyObject]] else {
                return nil
            }
            return Todos(todos: dictionaries)
        }
    }
    
    struct PostTodo: TodoSampleRequest {
        typealias Response = Todo
        
        var content: String
        
        init(content: String) {
            self.content = content
        }
        
        var method: HTTPMethod {
            return .POST
        }
        
        var path: String {
            return "/todos"
        }
        
        var parameters: [String: AnyObject] {
            return ["content": self.content]
        }
        
        func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) -> Response? {
            guard let dictionary = object as? [String: AnyObject] else {
                return nil
            }
            
            guard let todo = Todo(dictionary: dictionary) else {
                return nil
            }
            
            return todo
        }
    }

    struct UpdateTodo: TodoSampleRequest {
        typealias Response = Todo
        
        var id = 8
        
        var method: HTTPMethod {
            return .PUT
        }
        
        var path: String {
            return "/todos/5"
        }
        
        var parameters: [String: AnyObject] {
            return ["id": 5, "content": "TEST 0002"]
        }
        
        func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) -> Response? {
            guard let dictionary = object as? [String: AnyObject] else {
                return nil
            }
            
            guard let todo = Todo(dictionary: dictionary) else {
                return nil
            }
            return todo
        }
    }
    
    struct DeleteTodo: TodoSampleRequest {
        typealias Response = Todo
        
        var id = 8
        
        var method: HTTPMethod {
            return .DELETE
        }
        
        var path: String {
            return "/todos/8"
        }
        
        var parameters: [String: AnyObject] {
            return ["id": 8, "content": "TEST 005"]
        }
        
        func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) -> Response? {
            guard let dictionary = object as? [String: AnyObject] else {
                return nil
            }
            
            guard let todo = Todo(dictionary: dictionary) else {
                return nil
            }
            return todo
        }
    }
}

struct Todo {
    let id: Int
    let content: String
    
    init?(dictionary: [String: AnyObject]) {
        guard let id = dictionary["id"] as? Int else {
            return nil
        }
        
        guard let content = dictionary["content"] as? String else {
            return nil
        }
        
        self.id = id
        self.content = content
    }
}


struct Todos<T> {
    var todos: Array<T>
    
    init(todos: Array<T>) {
        self.todos = todos
    }
}