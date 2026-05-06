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

// MARK: - Login View
struct LoginView: View {
    @State private var usuario: String = ""
    @State private var contrasena: String = ""
    @State private var mostrarContrasena: Bool = false

    @Binding var estaAutenticado: Bool

    var body: some View {
        ZStack {

            // ── FONDO CON DEGRADADO RADIAL ───────────────────────
            // Verde brillante arriba al centro, oscuro hacia las esquinas
            ZStack {
                // Base oscura
                Color(hex: "1E4D1E")
                    .ignoresSafeArea()

                // Degradado radial — brillo en el centro superior
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

                // Toque de brillo extra arriba
                LinearGradient(
                    colors: [
                        Color(hex: "56C45A").opacity(0.3),
                        Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .center
                )
                .ignoresSafeArea()
            }

            VStack(spacing: 0) {

                Spacer()

                // ── LOGO ─────────────────────────────────────────
                Image("LogoRaza")
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(width: 130, height: 130)
                    .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 6)
                    .padding(.bottom, 24)

                // ── CARD GLASSMORPHISM ───────────────────────────
                VStack(alignment: .leading, spacing: 16) {

                    Text("Iniciar Sesion")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color(hex: "1A1A1A"))

                    Text("Ingresa tus credenciales")
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "555555"))
                        .padding(.top, -8)

                    // Campo Usuario
                    HStack {
                        Image(systemName: "person")
                            .foregroundColor(Color(hex: "555555"))
                            .frame(width: 20)
                        TextField("Usuario", text: $usuario)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .foregroundColor(Color(hex: "1A1A1A"))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                    )

                    // Campo Contraseña
                    HStack {
                        Image(systemName: "lock")
                            .foregroundColor(Color(hex: "555555"))
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
                        Button(action: {
                            mostrarContrasena.toggle()
                        }) {
                            Image(systemName: mostrarContrasena ? "eye" : "eye.slash")
                                .foregroundColor(Color(hex: "555555"))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                    )

                    // Botón Entrar
                    Button(action: {
                        if usuario == "admin" && contrasena == "1234" {
                            estaAutenticado = true
                        }
                    }) {
                        Text("Entrar")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "4CAF50"), Color(hex: "2E7D32")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(25)
                    }
                    .padding(.top, 4)
                }
                .padding(28)
                // Fondo glassmorphism de la card
                .background(
                    ZStack {
                        Color.white.opacity(0.15)
                        // Blur simulado con capas
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(hex: "C8D8C8").opacity(0.35))
                    }
                )
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                .padding(.horizontal, 28)

                Spacer()

                Text("Sistema de Gestión Agropecuaria v1.0")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.bottom, 30)
            }
        }
    }
}

#Preview {
    LoginView(estaAutenticado: .constant(false))
}
