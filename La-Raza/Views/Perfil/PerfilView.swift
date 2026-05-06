//
//  PerfilView.swift
//  La-Raza
//
//  Created by Alumno on 15/04/26.
//

import SwiftUI

struct PerfilView: View {
    @Binding var estaAutenticado: Bool

    var body: some View {
        VStack(spacing: 0) {

            // ── HEADER ──────────────────────────────────────────
            HStack {
                Text("Mi Perfil")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(hex: "3CB504"))

            ScrollView {
                VStack(spacing: 16) {

                    // ── CARD AVATAR ──────────────────────────────
                    VStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "3CB504"))
                                .frame(width: 80, height: 80)
                            Image(systemName: "person.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.white)
                        }

                        Text("Asesor Técnico")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: "1A1A1A"))

                        Text("Asesor de Campo")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: "3CB504"))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 4)
                            .background(Color(hex: "D6F5D6"))
                            .cornerRadius(20)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .background(Color.white)
                    .cornerRadius(14)
                    .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)

                    // ── CARD INFO PERSONAL ───────────────────────
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 8) {
                            Image(systemName: "person.2")
                                .foregroundColor(Color(hex: "3CB504"))
                            Text("Información Personal")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(Color(hex: "1A1A1A"))
                        }
                        .padding(.bottom, 14)

                        FilaInfo(icono: "rectangle.and.pencil.and.ellipsis",
                                 etiqueta: "Nombre",
                                 valor: "Asesor Técnico")
                        Divider()
                        FilaInfo(icono: "phone",
                                 etiqueta: "Teléfono",
                                 valor: "+52 961 000 0000")
                        Divider()
                        FilaInfo(icono: "building.2",
                                 etiqueta: "Sucursal",
                                 valor: "Tuxtla Gutiérrez")
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(14)
                    .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)

                    // ── CARD ACERCA DE LA APP ────────────────────
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle")
                                .foregroundColor(Color(hex: "3CB504"))
                            Text("Acerca de la App")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(Color(hex: "1A1A1A"))
                        }
                        .padding(.bottom, 14)

                        FilaInfo(icono: "iphone",
                                 etiqueta: "Aplicación",
                                 valor: "La Raza — Asesor Técnico")
                        Divider()
                        FilaInfo(icono: "number",
                                 etiqueta: "Versión",
                                 valor: "v1.0.0")
                        Divider()
                        FilaInfo(icono: "building",
                                 etiqueta: "Cliente",
                                 valor: "La Raza Semillas y Agroinsumos")
                        Divider()
                        FilaInfo(icono: "building.2.crop.circle",
                                 etiqueta: "Sucursales",
                                 valor: "Tuxtla Gutiérrez · Chiapa de Corzo")
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(14)
                    .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)

                    // ── BOTÓN CERRAR SESIÓN ──────────────────────
                    Button(action: {
                        estaAutenticado = false
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Cerrar sesión")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(Color(hex: "E53935"))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color(hex: "E53935"), lineWidth: 1.5)
                        )
                        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                    }
                }
                .padding(16)
            }
            .background(Color(hex: "F5F5F5"))
        }
        .ignoresSafeArea(edges: .top)
    }
}

// ── FILA DE INFORMACIÓN ──────────────────────────────────────────
struct FilaInfo: View {
    let icono: String
    let etiqueta: String
    let valor: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icono)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "888888"))
                .frame(width: 20)

            Text(etiqueta)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "888888"))

            Spacer()

            Text(valor)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "1A1A1A"))
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 10)
    }
}

#Preview {
    PerfilView(estaAutenticado: .constant(true))
}
