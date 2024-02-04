//
//  ContentView.swift
//  WordScramble
//
//  Created by Chad Eymard on 2/3/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var score = 0
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                    Text("Score: \(score)")
                }
                Section {
                    ForEach(usedWords, id: \.self) {word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit() {
                addNewWord()
            }
            .onAppear(perform: {
                startGame()
            })
            .alert(errorTitle, isPresented: $showingError) {
                Button("Ok") {}
            } message: {
                Text(errorMessage)
            }
            .toolbar {
                Button("Restart") {
                        startGame()
                    }
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else { return }
        
        guard isLegalLength(word: answer) else {
            wordError(title: "Illegal word", message: "Three character minimum")
            return
        }
        
        guard isNotSame(word: answer) else {
            wordError(title: "Illegal word", message: "You cannot use the root word for an answer")
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell \(answer) from \(rootWord)")
            return
        }
        guard isReal(word: answer) else { 
            wordError(title: "Word not recognized", message: "This is not a valid word")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        
        score += answer.count
        
        newWord = ""
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "widgets"
                usedWords.removeAll()
                return
            }
        }
        
        fatalError("Could not load start.txt from the bundle.")
    }
    
    func isNotSame(word: String) -> Bool {
        word.caseInsensitiveCompare(rootWord) != .orderedSame
    }
    
    func isLegalLength(word: String) -> Bool {
        word.count >= 3
    }

    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

#Preview {
    ContentView()
}
