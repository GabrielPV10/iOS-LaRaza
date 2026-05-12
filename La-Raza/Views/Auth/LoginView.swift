//
//  LoginView.swift
//  La-Raza
//
//  Created by Alumno on 25/03/26.
//
import SwiftUI

// MARK: - Extensión para colores hexadecimales
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct LoginView: View {
    @Binding var estaAutenticado: Bool
    @StateObject private var vm = LoginViewModel()

    @State private var usuario: String = ""
    @State private var contrasena: String = ""
    @State private var mostrarContrasena: Bool = false

    var body: some View {
        ZStack {

            // ── FONDO DEGRADADO ──────────────────────────────────
            ZStack {
                Color(hex: "1E4D1E").ignoresSafeArea()

                RadialGradient(
                    colors: [
                        Color(hex: "4CAF50").opacity(0.9),
                        Color(hex: "2E7D32").opacity(0.6),
                        Color(hex: "1A3D1A").opacity(0.0)
                    ],
                    center: .init(x: 0.5, y: 0.25),
                    startRadius: 0,
                    endRadius: 420
                )
                .ignoresSafeArea()

                LinearGradient(
                    colors: [Color(hex: "56C45A").opacity(0.3), Color.clear],
                    startPoint: .top,
                    endPoint: .center
                )
                .ignoresSafeArea()
            }

            VStack(spacing: 0) {
                Spacer()

                // ── LOGO + NOMBRE ────────────────────────────────
                VStack(spacing: 8) {
                    Image("LogoRaza")
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .frame(width: 130, height: 130)
                        .shadow(
                            color: .black.opacity(0.3),
                            radius: 12, x: 0, y: 6
                        )

                    Text("LA RAZA")
                        .font(.system(size: 28, weight: .black))
                        .foregroundColor(.white)
                        .tracking(4)

                    Text("Semillas y Agroinsumos")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.7))
                        .tracking(1)
                }
                .padding(.bottom, 32)

                // ── CARD LOGIN ───────────────────────────────────
                VStack(alignment: .leading, spacing: 16) {

                    Text("Iniciar sesión")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(hex: "1E7A00"))

                    Text("Ingresa tus credenciales")
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "888888"))
                        .padding(.top, -8)

                    // Campo Usuario
                    HStack {
                        Image(systemName: "person")
                            .foregroundColor(Color(hex: "3CB504"))
                            .frame(width: 20)
                        TextField("Usuario", text: $usuario)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .foregroundColor(Color(hex: "1A1A1A"))
                    }
                    .padding()
                    .background(Color(hex: "F0FAF0"))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "3CB504").opacity(0.4), lineWidth: 1)
                    )

                    // Campo Contraseña
                    HStack {
                        Image(systemName: "lock")
                            .foregroundColor(Color(hex: "3CB504"))
                            .frame(width: 20)
                        if mostrarContrasena {
                            TextField("Contraseña", text: $contrasena)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .foregroundColor(Color(hex: "1A1A1A"))
                        } else {
                            SecureField("Contraseña", text: $contrasena)
                                .foregroundColor(Color(hex: "1A1A1A"))
                        }
                        Button(action: { mostrarContrasena.toggle() }) {
                            Image(systemName: mostrarContrasena ? "eye" : "eye.slash")
                                .foregroundColor(Color(hex: "888888"))
                        }
                    }
                    .padding()
                    .background(Color(hex: "F0FAF0"))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "3CB504").opacity(0.4), lineWidth: 1)
                    )

                    // Mensaje de error
                    if let error = vm.error {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(Color(hex: "E53935"))
                                .font(.system(size: 14))
                            Text(error)
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "E53935"))
                        }
                        .padding(.horizontal, 4)
                        .transition(.opacity)
                    }

                    // Botón Entrar
                    Button(action: {
                        vm.iniciarSesion(
                            username: usuario,
                            password: contrasena,
                            estaAutenticado: $estaAutenticado
                        )
                    }) {
                        ZStack {
                            LinearGradient(
                                colors: [
                                    Color(hex: "4CAF50"),
                                    Color(hex: "2E7D32")
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .cornerRadius(14)

                            if vm.cargando {
                                ProgressView()
                                    .progressViewStyle(
                                        CircularProgressViewStyle(tint: .white)
                                    )
                            } else {
                                Text("Entrar")
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(.white)
                                    .tracking(1)
                            }
                        }
                        .frame(height: 52)
                    }
                    .disabled(vm.cargando)
                    .padding(.top, 4)
                }
                .padding(28)
                .background(Color.white)
                .cornerRadius(24)
                .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 8)
                .padding(.horizontal, 28)

                Spacer()

                Text("Sistema de Gestión Agropecuaria v1.0")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.bottom, 24)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: vm.error)
    }
}

#Preview {
    LoginView(estaAutenticado: .constant(false))
}
