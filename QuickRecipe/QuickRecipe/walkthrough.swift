import SwiftUI
import WebKit

struct WalkthroughView: View {
    @AppStorage("currentPage") var currentPage = 1
    var body: some View {
     
        if currentPage > totalPages{
            ContentView()
        }
        else{
            WalkthroughScreen()
        }
    }
}

struct GIFView: UIViewRepresentable {
    var gifName: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false // To avoid a white background
        webView.backgroundColor = UIColor.clear
        webView.scrollView.isScrollEnabled = false
        if let gifPath = Bundle.main.path(forResource: gifName, ofType: "gif"),
           let gifData = try? Data(contentsOf: URL(fileURLWithPath: gifPath)) {
            webView.load(gifData, mimeType: "image/gif", characterEncodingName: "UTF-8", baseURL: URL(fileURLWithPath: Bundle.main.bundlePath))
        }
        return webView
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}



struct WalkthroughScreen: View {
    
    @AppStorage("currentPage") var currentPage = 1
    
    var body: some View{
        
        ZStack{
            if currentPage == 1{
                ScreenView(image: "add_item", title: "Snap & Organize", detail: "Photograph and categorize your food items to create a digital pantry")
                    .transition(.scale)
            }
            if currentPage == 2{
            
                ScreenView(image: "shop", title: "Create Shopping Lists", detail: "Create and maintain shopping lists easily based on what food items you need")
                    .transition(.scale)
            }
            
            if currentPage == 3{
                
                ScreenView(image: "generateRecipe", title: "Generate Recipes", detail: "Reduce foodwaste by getting ideas on what to cook with the ingredients that are at home")
                    .transition(.scale)
            }
            
        }
        .overlay(

            Button(action: {
                withAnimation(.easeInOut){
                    if currentPage <= totalPages{
                        currentPage += 1
                    }
                }
            }, label: {
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(width: 60, height: 60)
                    .background(Color.white)
                    .clipShape(Circle())
                    .overlay(
                        ZStack{
                            
                            Circle()
                                .stroke(Color.black.opacity(0.04),lineWidth: 4)
                                
                            
                            Circle()
                                .trim(from: 0, to: CGFloat(currentPage) / CGFloat(totalPages))
                                .stroke(Color.white,lineWidth: 4)
                                .rotationEffect(.init(degrees: -90))
                        }
                        .padding(-15)
                    )
            })
            .padding(.bottom,20)
            
            ,alignment: .bottom
        )
    }
}

struct ScreenView: View {
    
    var image: String
    var title: String
    var detail: String
    
    @AppStorage("currentPage") var currentPage = 1
    
    var body: some View {
        VStack(spacing: 20){
            
            HStack{
                if currentPage == 1{
                    Text("Hello User!")
                        .font(.title)
                        .fontWeight(.semibold)
                        .kerning(1.4)
                }
                else{
                    Button(action: {
                        withAnimation(.easeInOut){
                            currentPage -= 1
                        }
                    }, label: {
                        
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .padding(.vertical,10)
                            .padding(.horizontal)
                            .background(Color.black.opacity(0.4))
                            .cornerRadius(10)
                    })
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut){
                        currentPage = 4
                    }
                }, label: {
                    Text("Skip")
                        .fontWeight(.semibold)
                        .kerning(1.2)
                })
            }
            .padding()
            
            Spacer(minLength: 0)
            GIFView(gifName: image) // Make sure the GIF is in your Xcode project
                        .frame(width: 200, height: 420)
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .padding(.top)
            
            Text(detail)
                .fontWeight(.semibold)
                .kerning(1.3)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .font(.system(size: 10))
            Spacer(minLength: 120)
        }
    }
}

var totalPages = 3
