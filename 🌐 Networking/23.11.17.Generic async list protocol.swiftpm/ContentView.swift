import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                Feed()
            }
        }
    }
}

struct Feed: ListView {
    @State var state = ListState<Item>.idle
    var path = "/feeds"
    
    func row(_ item: Item) -> some View {
        NavigationLink {
            FeedDetail(
                id: item.id,
                title: item.title,
                subtitle: item.subtitle,
                commentCount: item.commentCount
            )
        } label: {
            Text(item.title)
            Text(item.subtitle)
        }
    }
    
    func loadItems() async {
        state = .loading
        let loadedState = await makeState()
        state = loadedState
    }
}

struct FeedDetail: ListView {
    @State var state = ListState<Comment>.idle
    let id: String
    let title: String
    let subtitle: String
    let commentCount: String
    
    var path: String { "/comments" }
    var queryItems: [URLQueryItem] {
        [.init(name: "feedId", value: id)]
    }
    
    var body: some View {
        VStack {
            Text(title)
            Text(subtitle)
            Text(commentCount)
            list
        }
    }
        
    func row(_ item: Comment) -> some View {
        VStack {
            Text(item.author)
            Text(item.comment)
        }
    }
    
    func loadItems() async {
        state = .loading
        let newState = await makeState()
        state = newState
    }
}


