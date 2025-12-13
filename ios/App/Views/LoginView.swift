#if canImport(SwiftUI)
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isSignUp = false

    var body: some View {
        VStack(spacing: 16) {
            Text("TeaWarehouse")
                .font(.largeTitle)
                .fontWeight(.bold)

            TextField("Email", text: $authViewModel.email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

            SecureField("Password", text: $authViewModel.password)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

            if let error = authViewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.footnote)
            }
            if let status = authViewModel.statusMessage {
                Text(status)
                    .foregroundColor(.green)
                    .font(.footnote)
            }

            Button {
                isSignUp ? authViewModel.signUp() : authViewModel.signIn()
            } label: {
                if authViewModel.isLoading {
                    ProgressView()
                } else {
                    Text(isSignUp ? "Sign Up" : "Sign In")
                        .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(8)

            Button(isSignUp ? "Have an account? Sign In" : "New user? Sign Up") {
                isSignUp.toggle()
            }
            .font(.footnote)
        }
        .padding()
    }
}
#endif
