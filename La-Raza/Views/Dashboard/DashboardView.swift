//
//  DashboardView.swift
//  La-Raza
//
//  Created by Alumno on 15/04/26.
//

import SwiftUI

struct DashboardView: View {
    @Binding var estaAutenticado: Bool

    let modulos: [(icono: String, titulo: String, subtitulo: String, color: String)] = [
        ("shippingbox",                     "Productos",    "Consultar catálogo",  "D6F5D6"),
        ("mappin.circle",                   "Nueva Visita", "Registrar visita",    "D6E8F5"),
        ("clock.arrow.circlepath",          "Historial",    "Visitas anteriores",  "E8D6F5"),
        ("arrow.triangle.2.circlepath",     "Sincronizar",  "Subir datos",         "F5E8D6"),
        ("person",                          "Perfil",       "Mi información",      "D6EEF5"),
    ]

    let columnas = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ZStack(alignment: .top) {

            // Fondo gris para toda la pantalla
            Color(hex: "F5F5F5")
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // ── HEADER CON DEGRADADO ─────────────────────────
                ZStack {
                    // Degradado de fondo
                    LinearGradient(
                        colors: [Color(hex: "3CB504"), Color(hex: "1E7A00")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea(edges: .top)

                    HStack(spacing: 12) {
                        Image("LogoRaza")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 38, height: 38)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                            )

                        VStack(alignment: .leading, spacing: 1) {
                            Text("La Raza")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                            Text("Asesor Técnico")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.85))
                        }

                        Spacer()

                        Button(action: {}) {
                            Image(systemName: "bell")
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                        }

                        Button(action: {
                            estaAutenticado = false
                        }) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .padding(.top, 8)
                }
                .fixedSize(horizontal: false, vertical: true)

                // ── CONTENIDO ────────────────────────────────────
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {

                        // Card bienvenida con degradado
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Buenos días, Asesor 👋")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Modo sin conexión activo")
                                    .font(.system(size: 13))
                                    .foregroundColor(.white.opacity(0.85))
                            }
                            Spacer()
                        }
                        .padding(16)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "3CB504"), Color(hex: "1E7A00")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)

                        // Título módulos
                        Text("Módulos")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(hex: "1A1A1A"))

                        // Grid de módulos
                        LazyVGrid(columns: columnas, spacing: 16) {
                            ForEach(Array(modulos.enumerated()), id: \.offset) { index, modulo in
                                Group {
                                    if modulo.titulo == "Perfil" {
                                        NavigationLink(destination: PerfilView(estaAutenticado: $estaAutenticado)) {
                                            ModuloCard(modulo: modulo)
                                        }
                                        .buttonStyle(.plain)
                                    } else if modulo.titulo == "Productos" {
                                        NavigationLink(destination: ProductosView()) {
                                            ModuloCard(modulo: modulo)
                                        }
                                        .buttonStyle(.plain)
                                    } else if modulo.titulo == "Nueva Visita" {
                                        NavigationLink(destination: NuevaVisitaView()) {
                                            ModuloCard(modulo: modulo)
                                        }
                                        .buttonStyle(.plain)
                                    } else if modulo.titulo == "Historial" {
                                        NavigationLink(destination: HistorialView()) {
                                            ModuloCard(modulo: modulo)
                                        }
                                        .buttonStyle(.plain)
                                    } else {
                                        ModuloCard(modulo: modulo)
                                    }
                                }
                            }
                        }
                    }
                    .padding(16)
                }
                .background(Color(hex: "F5F5F5"))
            }
        }
        .navigationBarHidden(true)
    }
}

// ── TARJETA DE MÓDULO ────────────────────────────────────────────
struct ModuloCard: View {
    let modulo: (icono: String, titulo: String, subtitulo: String, color: String)

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: modulo.color))
                    .frame(width: 52, height: 52)
                Image(systemName: modulo.icono)
                    .font(.system(size: 22))
                    .foregroundColor(Color(hex: "3CB504"))
            }
            Text(modulo.titulo)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "1A1A1A"))
            Text(modulo.subtitulo)
                .font(.system(size: 11))
                .foregroundColor(Color(hex: "888888"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    NavigationStack {
        DashboardView(estaAutenticado: .constant(true))
    }
}
