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
        //return NSURL(string: "http://localhost:9000/api/v1")!
        return NSURL(string: "http://floating-falls-7245.herokuapp.com/api/v1")!
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
            return "/todo"
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
    var todos: Array<Todo>
    
    init?(todos: Array<T>) {
        var todolist: Array<Todo> = []
        for todoDictionary in todos {
            guard let dictionary = todoDictionary as? [String: AnyObject] else {
                continue
            }
            let todo = Todo(dictionary: dictionary)
            todolist.append(todo!)
        }
        self.todos = todolist
    }
}