import SwiftUI

// MARK: - Hierarchy Navigator with Scrolling and Filtering Support
struct HierarchyNavigator: View {
    @StateObject private var firestoreService = FirestoreService()
    @State private var currentNode: ObjectionNode?
    @State private var history: [ObjectionNode] = []
    @State private var selectedNode: ObjectionNode?
    
    var body: some View {
        ZStack {
            Color("Primary").edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 20) { // Left-aligned content
                Text("Catholic Defense Hub")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Back Button
                HStack {
                    if !history.isEmpty {
                        Button("Back") {
                            if let lastNode = history.popLast() {
                                currentNode = lastNode
                            }
                        }
                        .padding(15)
                        .background(Color("Secondary"))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                    }
                    if let notes = currentNode?.notes, !notes.isEmpty {
                        Button("Show Notes") {
                            selectedNode = currentNode
                        }
                        .padding(15)
                        .background(Color("Secondary"))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                    }
                }
                
                // ✅ ScrollView for children with visibility filtering (Left-Aligned)
                ScrollView {
                    VStack(alignment: .leading) {  // Left-align the buttons
                        if let currentNode = currentNode {
                            ForEach(currentNode.children_order, id: \.self) { childID in
                                if let childNode = currentNode.children.first(where: { $0.id == childID && $0.visible }) {
                                    ObjectionButton(title: childNode.title) {
                                        if childNode.children.isEmpty {
                                            selectedNode = childNode
                                        } else {
                                            history.append(currentNode)
                                            self.currentNode = childNode
                                        }
                                    }
                                    .padding(.bottom, 5)
                                }
                            }
                        }
                    }
                    .padding()
                }
                .background(Color("Secondary"))
                .cornerRadius(20)
            }
            .padding()
        }
        .onAppear {
            Task {
                await firestoreService.fetchAndBuildTree()
                self.currentNode = firestoreService.rootNode
            }
        }
        // ✅ Modal for showing notes
        .sheet(item: $selectedNode) { node in
            NotesModalView(node: node)
        }
    }
}

#Preview {
    HierarchyNavigator()
}
