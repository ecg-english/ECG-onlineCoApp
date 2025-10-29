import SwiftUI

struct ShopView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var shopViewModel: ShopViewModel
    @EnvironmentObject var mileViewModel: MileViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Mile残高表示
                    HStack {
                        VStack(alignment: .leading) {
                            Text("所持Mile")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text("\(mileViewModel.balance)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Text("Mile")
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    // Mile購入セクション
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Mile購入")
                            .font(.headline)
                        
                        Text("※今後実装予定")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("1 Mile = 10円でMileを購入できます")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                    
                    // ショップアイテム
                    VStack(alignment: .leading, spacing: 10) {
                        Text("アイテム")
                            .font(.headline)
                        
                        if shopViewModel.items.isEmpty {
                            Text("現在購入可能なアイテムはありません")
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            ForEach(shopViewModel.items) { item in
                                ShopItemRowView(item: item)
                                    .environmentObject(shopViewModel)
                                    .environmentObject(mileViewModel)
                            }
                        }
                    }
                }
                .padding()
                .padding(.top, 60) // ヘッダー分のスペース
            }
            .task {
                await shopViewModel.loadItems()
                await mileViewModel.loadBalance()
            }
            .alert("購入完了", isPresented: .constant(shopViewModel.successMessage != nil)) {
                Button("OK") {
                    shopViewModel.successMessage = nil
                }
            } message: {
                if let message = shopViewModel.successMessage {
                    Text(message)
                }
            }
        }
    }
}

struct ShopItemRowView: View {
    @EnvironmentObject var shopViewModel: ShopViewModel
    @EnvironmentObject var mileViewModel: MileViewModel
    let item: ShopItem
    
    @State private var showConfirmation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                if let imageUrl = item.imageUrl {
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                    }
                    .frame(width: 80, height: 80)
                    .clipped()
                    .cornerRadius(10)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(item.name)
                        .font(.headline)
                    
                    Text(item.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text("\(item.mileCost) Mile")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                }
                
                Spacer()
            }
            
            Button(action: {
                showConfirmation = true
            }) {
                Text("購入する")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(mileViewModel.balance >= item.mileCost ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(mileViewModel.balance < item.mileCost)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
        .confirmationDialog("購入確認", isPresented: $showConfirmation) {
            Button("購入する") {
                Task {
                    let success = await shopViewModel.purchaseItem(itemId: item.id)
                    if success {
                        await mileViewModel.loadBalance()
                    }
                }
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("\(item.name)を\(item.mileCost) Mileで購入しますか?")
        }
    }
}

struct ShopView_Previews: PreviewProvider {
    static var previews: some View {
        ShopView()
            .environmentObject(AuthViewModel())
            .environmentObject(ShopViewModel())
            .environmentObject(MileViewModel())
    }
}

