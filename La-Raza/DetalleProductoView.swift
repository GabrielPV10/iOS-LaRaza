//
//  DetalleProductoView.swift
//  La-Raza
//
//  Created by Alumno on 21/04/26.
//

import SwiftUI

struct DetalleProductoView: View {
    let producto: Producto
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {

            // ── HEADER ───────────────────────────────────────────
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "3CB504"), Color(hex: "1E7A00")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea(edges: .top)

                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .semibold))
                    }
                    Spacer()
                    Text("Detalle del Producto")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "chevron.left").opacity(0)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .padding(.top, 8)
            }
            .fixedSize(horizontal: false, vertical: true)

            ScrollView {
                VStack(spacing: 16) {

                    // ── CARD PRINCIPAL ───────────────────────────
                    VStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: producto.colorCategoria))
                                .frame(width: 72, height: 72)
                            Image(systemName: "shippingbox")
                                .font(.system(size: 32))
                                .foregroundColor(Color(hex: "3CB504"))
                        }

                        Text(producto.nombre)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(hex: "1A1A1A"))

                        Text(producto.categoria)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(hex: "3CB504"))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 5)
                            .background(Color(hex: producto.colorCategoria))
                            .cornerRadius(20)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .background(Color.white)
                    .cornerRadius(14)
                    .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)

                    // ── PRECIO Y STOCK ───────────────────────────
                    HStack(spacing: 12) {
                        // Precio
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: "dollarsign")
                                    .foregroundColor(Color(hex: "3CB504"))
                                    .font(.system(size: 18))
                                Text("Precio")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(hex: "888888"))
                            }
                            Text("$\(String(format: "%.2f", producto.precio))")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(hex: "3CB504"))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(14)
                        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)

                        // Stock
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: "house")
                                    .foregroundColor(Color(hex: "3CB504"))
                                    .font(.system(size: 18))
                                Text("Stock")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(hex: "888888"))
                            }
                            if producto.stock == 0 {
                                Text("Sin stock")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Color(hex: "E53935"))
                            } else {
                                Text("\(Int(producto.stock)) \(producto.unidad)")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Color(hex: "3CB504"))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(14)
                        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                    }

                    // ── DESCRIPCIÓN ──────────────────────────────
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Descripción")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color(hex: "1A1A1A"))

                        Text(producto.descripcion)
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "555555"))
                            .lineSpacing(4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(14)
                    .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                }
                .padding(16)
            }
            .background(Color(hex: "F5F5F5"))
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    NavigationStack {
        DetalleProductoView(producto: Producto.ejemplos[0])
    }
}
