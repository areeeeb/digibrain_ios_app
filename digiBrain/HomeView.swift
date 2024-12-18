import SwiftUI
import FirebaseAuth
import SwiftData

struct MemoryTile: View {
    let title: String
    let date: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline)
                .lineLimit(2)
            Text(date)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
}

struct AskButton: View {
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(width: 20, height: 20)
                } else {
                    Text("Ask")
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(Color.blue)
            .cornerRadius(8)
        }
        .disabled(isDisabled)
    }
}

struct CreateMemoryButton: View {
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Create Memory")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
        }
        .disabled(isDisabled)
    }
}

struct HomeView: View {
    @StateObject private var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isDrawerOpen = false
    @State private var question = ""
    @State private var isShowingNewMemoryDialog = false
    @State private var newMemoryText = ""
    @State private var showingQueryResult = false
    @State private var memories: [Memory] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var currentQuery: String = ""
    @State private var currentQueryResponse: QueryResponse?
    @State private var isQueryLoading = false
    @State private var isMemoryCreating = false
    @State private var showingError = false
    @FocusState private var isQuestionFieldFocused: Bool
    
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: AuthViewModel(modelContext: modelContext))
    }
    
    private func loadMemories() {
        isLoading = true
        Task {
            do {
                memories = try await APIService.shared.listMemories(userId: viewModel.user?.uid ?? "")
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    private func createMemory() {
        guard !newMemoryText.isEmpty else { return }
        isMemoryCreating = true
        
        Task {
            do {
                let newMemory = try await APIService.shared.addMemory(
                    title: newMemoryText,
                    content: newMemoryText,
                    userId: viewModel.user?.uid ?? ""
                )
                memories.insert(newMemory, at: 0)
                isShowingNewMemoryDialog = false
                newMemoryText = ""
            } catch {
                errorMessage = error.localizedDescription
                showingError = true
            }
            isMemoryCreating = false
        }
    }
    
    private func handleQuery() {
        guard !question.isEmpty else { return }
        isQueryLoading = true
        
        Task {
            do {
                currentQuery = question
                let response = try await APIService.shared.askQuestion(
                    Question(
                        query: question,
                        userId: viewModel.user?.uid ?? ""
                    )
                )
                currentQueryResponse = response
                showingQueryResult = true
                question = ""
            } catch {
                errorMessage = error.localizedDescription
                showingError = true
            }
            isQueryLoading = false
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isQuestionFieldFocused = false
                    }
                
                VStack {
                    // Title bar
                    HStack {
                        Button(action: {
                            isQuestionFieldFocused = false
                            isDrawerOpen.toggle()
                        }) {
                            Image(systemName: "line.horizontal.3")
                                .font(.title2)
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        Button(action: { isShowingNewMemoryDialog = true }) {
                            Text("New Memory")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    
                    // Center text
                    Spacer()
                    Text("Ask Your Digital Brain!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 10)
                    Spacer()
                    
                    // Bottom text field
                    HStack {
                        TextField("Ask anything related to your memories...", text: $question)
                            .focused($isQuestionFieldFocused)
                            .padding(.horizontal)
                        
                        AskButton(
                            isLoading: isQueryLoading,
                            isDisabled: isQueryLoading || question.isEmpty,
                            action: handleQuery
                        )
                        .padding(.trailing, 8)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding()
                }
                
                // Updated side drawer
                if isDrawerOpen {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            isDrawerOpen = false
                        }
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Memories")
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.top, 60)
                            
                            ScrollView {
                                VStack(alignment: .leading, spacing: 10) {
                                    if isLoading {
                                        HStack {
                                            Spacer()
                                            ProgressView()
                                                .padding()
                                            Spacer()
                                        }
                                        .frame(maxHeight: .infinity)
                                    } else if memories.isEmpty {
                                        HStack {
                                            Spacer()
                                            Text("No memories created...")
                                                .foregroundColor(.gray)
                                                .padding()
                                            Spacer()
                                        }
                                        .frame(minHeight: 300)
                                    } else {
                                        ForEach(memories.map { ($0.title, $0.date.formatted()) }, id: \.0) { memory in
                                            VStack(alignment: .leading) {
                                                MemoryTile(title: memory.0, date: memory.1)
                                                Divider()
                                            }
                                        }
                                    }
                                }
                                .padding(.trailing)
                            }
                            .padding(.bottom)
                            
                            // Spacer()
                            
                            Button(action: { viewModel.signOut() }) {
                                Text("Sign Out")
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.red)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 40)
                        }
                        .padding(.horizontal)
                        .frame(width: UIScreen.main.bounds.width * 0.8)
                        .background(Color(.systemBackground))
                        .edgesIgnoringSafeArea(.vertical)
                        
                        Spacer()
                    }
                    .transition(.move(edge: .leading))
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $isShowingNewMemoryDialog) {
                NavigationStack {
                    VStack(spacing: 20) {
                        TextField("Enter your memory details here...", text: $newMemoryText, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(5...10)
                            .padding()
                        
                        CreateMemoryButton(
                            isLoading: isMemoryCreating,
                            isDisabled: isMemoryCreating || newMemoryText.isEmpty,
                            action: createMemory
                        )
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                    .navigationTitle("Add New Memory")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isShowingNewMemoryDialog = false
                                newMemoryText = ""
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showingQueryResult) {
                if let response = currentQueryResponse {
                    QueryResultView(query: currentQuery, response: response)
                }
            }
        }
        .onReceive(viewModel.$user) { user in
            if user == nil {
                dismiss()
            }
        }
        .animation(.easeInOut, value: isDrawerOpen)
        .alert("Error", isPresented: $showingError, presenting: errorMessage) { _ in
            Button("OK") {
                errorMessage = nil
            }
        } message: { error in
            Text(error)
        }
        .onAppear {
            loadMemories()
        }
    }
} 