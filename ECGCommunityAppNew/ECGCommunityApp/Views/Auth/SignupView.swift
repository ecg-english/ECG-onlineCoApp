import SwiftUI

struct SignupView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var username = ""
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("アカウント作成")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                
                VStack(spacing: 15) {
                    TextField("ユーザー名", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.username)
                    
                    TextField("メールアドレス", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    SecureField("パスワード", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.newPassword)
                    
                    SecureField("パスワード（確認）", text: $confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.newPassword)
                    
                    if let errorMessage = errorMessage ?? authViewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    Button(action: {
                        if validateForm() {
                            Task {
                                await authViewModel.signup(email: email, password: password, username: username)
                                if authViewModel.isAuthenticated {
                                    dismiss()
                                }
                            }
                        }
                    }) {
                        if authViewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("登録する")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(authViewModel.isLoading)
                }
                .padding(.horizontal, 30)
                
                Spacer()
            }
            .navigationBarItems(leading: Button("キャンセル") {
                dismiss()
            })
        }
    }
    
    private func validateForm() -> Bool {
        errorMessage = nil
        
        if username.isEmpty || email.isEmpty || password.isEmpty {
            errorMessage = "全ての項目を入力してください"
            return false
        }
        
        if password != confirmPassword {
            errorMessage = "パスワードが一致しません"
            return false
        }
        
        if password.count < 6 {
            errorMessage = "パスワードは6文字以上で入力してください"
            return false
        }
        
        return true
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView()
            .environmentObject(AuthViewModel())
    }
}

