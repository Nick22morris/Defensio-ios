import SwiftUI

// MARK: - Hierarchy Navigator with Launch Screen Support
struct HierarchyNavigator: View {
    @StateObject private var firestoreService = FirestoreService()
    @State private var currentNode: ObjectionNode?
    @State private var history: [ObjectionNode] = []
    @State private var selectedNode: ObjectionNode?
    @State private var isLoading = true  // Added loading state
    
    var body: some View {
        ZStack {
            if isLoading {
                // Launch screen with a spinner
                VStack {
                    Image("logo")
                        .resizable()
                        .frame(width: 150, height: 150)
                    Text("Catholic Defense Hub")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("Primary").edgesIgnoringSafeArea(.all))
            } else {
                // Main Content
                Color("Primary").edgesIgnoringSafeArea(.all)
                VStack(alignment: .leading, spacing: 20) {
                    Text("Catholic Defense Hub")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
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
                    
                    ScrollView {
                        VStack(alignment: .leading) {
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
                    .refreshable {
                        while let lastNode = history.popLast() {
                            currentNode = lastNode
                        }
                        await firestoreService.fetchAndBuildTree()
                        self.currentNode = firestoreService.rootNode
                    }
                }
                .padding()
            }
        }
        .onAppear {
            Task {
                isLoading = true
                await firestoreService.fetchAndBuildTree()
                self.currentNode = firestoreService.rootNode
                isLoading = false
            }
        }
        .sheet(item: $selectedNode) { node in
            NotesModalView(node: node)
        }
    }
}

#Preview {
    HierarchyNavigator()
}
