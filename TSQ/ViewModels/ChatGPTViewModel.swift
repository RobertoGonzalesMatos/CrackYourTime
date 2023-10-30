//
//  ChatGPTViewModel.swift
//  TSQ
//
//  Created by Roberto Gonzales on 8/7/23.
//

import Foundation
import OpenAISwift

final class ChatGPTViewModel: ObservableObject{
    private let parameters = "Hi, please write 5 challenges/real-life sidequests that I could do to go out of my confort zone, have fun, discover places, do a new activity or anything that you may think could be interesting to do. Before each challenge always write '1. '. Try to make each challenge as specific, creative and interesting as possible. if you can make the side quest be able to be completed in 1 day. Please make the challenges similar to the following: pet 5 dogs, talk to a stranger, ask a barista their favorite drink and order it, go to the mall with someone and dress eachother, Cook something without a recipie, Play trivia of each other, have a goofy/thematic Photoshoot, Mock olimpics with fun competitions. Please make your response at max 500 characters and only include the challenges."
    private var lastSentence = "At last, it is extremly important that all of the challenges must have a direct connection or be related to "
    var done: String = ""
    private let searchGuide = " and follow the next model response. Reply with the most known kinds of the topic. You could provide a link to them and also give an exremly breif overview of them. If the topic is related to an action, give websites or sources that could help with information for the project. Please make your answer at most 80 words and finish the sentence by the end of those 60 words"
    init(){}
    
    private var client: OpenAISwift?
    
    func setUp(done: [SQItem]){
        client = OpenAISwift(config: OpenAISwift.Config.makeDefaultOpenAI(apiKey: "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"))
        self.done = self.toString(done: done)
    }
    
    func setUpdirect(){
        client = OpenAISwift(config: OpenAISwift.Config.makeDefaultOpenAI(apiKey: "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"))
    }
    
    func send(text: String, completion: @escaping (String) -> Void){
        client?.sendCompletion(with: parameters + done + lastSentence + text, model:OpenAIModelType.gpt3(.davinci),
            maxTokens: 500,
            completionHandler: { result in
            switch result {
            case .success(let model):
                
                let output = model.choices?.first?.text ?? ""
                completion(output)
            case .failure(let error):
                print("failed with error: \(error)")
                return
            }
        })
    }
    func toString(done: [SQItem])->String{
        if done.count == 0 {
            return ""
        }
        var finalString = ""
        for item in done{
            finalString += item.title + ", "
        }
        return (" These are side-quests this user has completed: "+finalString+"etc. ")
    }
    func search(text: String, completion: @escaping (String) -> Void){
        Task {
             while text == "" {
                 try await Task.sleep(nanoseconds: 100_000_000) // Sleep for 0.1 seconds
             }
         }
        client?.sendCompletion(with: "Hi, please use this topic "+text+searchGuide, model:OpenAIModelType.gpt3(.davinci),
            maxTokens: 80,
            completionHandler: { result in
            switch result {
            case .success(let model):
                
                let output = model.choices?.first?.text ?? ""
                completion(output)
            case .failure(let error):
                print("failed with error: \(error)")
                return
            }
        })
    }
}
