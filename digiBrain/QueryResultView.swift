import SwiftUI

struct QueryResultView: View {
    @Environment(\.dismiss) private var dismiss
    let query: String
    let response: QueryResponse
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Query section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Question:")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text(query)
                            .font(.title3)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    // Answer section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Answer:")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text(response.answer)
                            .font(.body)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    // Relevant memories section
                    if !response.relevantMemories.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Related Memories:")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            ForEach(response.relevantMemories) { memory in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(memory.title)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Text(memory.content)
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Query Result")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    QueryResultView(query: "Sample query about your memories...", response: QueryResponse(answer: "This is a placeholder answer that would come from processing your memories. It could be multiple lines long and contain various details retrieved from your digital brain's memory storage.", relevantMemories: []))
} 