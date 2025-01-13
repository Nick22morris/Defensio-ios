import FirebaseFirestore
import Firebase

// MARK: - Firestore Service for Fetching Nodes
class FirestoreService: ObservableObject {
    @Published var rootNode: ObjectionNode?
    private var db = Firestore.firestore()
    
    // Fetch all nodes as flat data first
    func fetchAndBuildTree() async {
        do {
            print("Fetching documents from Firestore...")
            let documentsSnapshot = try await db.collection("nodes").getDocuments()
            
            // Decode all documents as ObjectionDocuments and print each one
            let flatNodes: [ObjectionDocument] = try documentsSnapshot.documents.compactMap { doc in
                do {
                    let data = try doc.data(as: ObjectionDocument.self)
                    print("Fetched Node: \(data.title) | ID: \(data.id) | Children: \(data.children)")
                    return data
                } catch {
                    print("Error decoding node: \(doc.documentID) - \(error)")
                    return nil
                }
            }
            
            print("Total nodes fetched: \(flatNodes.count)")
            
            // Build the tree from flat data
            let tree = self.buildTree(from: flatNodes)
            
            // Print the root node for further confirmation
            if let root = tree {
                print("Root Node: \(root.title) | Children Count: \(root.children.count)")
            } else {
                print("Error: No root node identified.")
            }
            
            // Update UI on main thread
            DispatchQueue.main.async {
                self.rootNode = tree
            }
            
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
        }
    }
    
    // Build Tree from ObjectionDocument (Flat) to ObjectionNode (Nested)
    private func buildTree(from flatNodes: [ObjectionDocument]) -> ObjectionNode? {
        var nodeLookup = [String: ObjectionNode]()

        print("Initializing nodes...")
        
        // Step 1: Initialize all nodes without children
        for doc in flatNodes {
            nodeLookup[doc.id] = ObjectionNode(
                id: doc.id,
                body: doc.body,
                children: [],  // Initialize empty children
                children_order: doc.children_order ?? [],
                index: doc.index ?? 0,
                notes: doc.notes,
                parent_id: doc.parent_id,
                title: doc.title,
                visible: doc.visible ?? true
            )
        }

        var rootNode: ObjectionNode? = nil

        // Step 2: Recursively attach children
        func attachChildren(nodeID: String) -> ObjectionNode? {
            guard var node = nodeLookup[nodeID] else {
                print("⚠️ Node not found for ID: \(nodeID)")
                return nil
            }
            
            // Resolve children recursively by their IDs
            node.children = node.children_order.compactMap { childID in
                return attachChildren(nodeID: childID)  // Recursively attach children
            }
            
            nodeLookup[nodeID] = node // Update node after recursion
            return node
        }

        // Step 3: Find the root node and build the entire tree
        for doc in flatNodes {
            if doc.id == "root" {
                rootNode = attachChildren(nodeID: doc.id)  // Start from the root node
            }
        }

        // ✅ Debugging output for full tree structure
        if let root = rootNode {
            print("✅ Final Root Node: \(root.title) with \(root.children.count) children")
            for child in root.children {
                print("Child: \(child.title) with \(child.children.count) children")
                for subChild in child.children {
                    print(" - SubChild: \(subChild.title) with \(subChild.children.count) children")
                    for subSubChild in subChild.children {
                        print("   - SubSubChild: \(subSubChild.title) with \(subSubChild.children.count) children")
                    }
                }
            }
        } else {
            print("❗ No root node identified.")
        }

        return rootNode
    }
}
