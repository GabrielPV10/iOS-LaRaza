//
//  DetalleProductoView.swift
//  La-Raza
//
//  Created by Alumno on 15/04/26.
//

import SwiftUI

struct DetalleProductoView: View {
    let producto: ProductoLocal
    @Environment(\.dismiss) var dismiss

    var stockColor: Color {
        if producto.stock <= 0 { return Color(hex: "E53935") }
        if producto.stock < 10 { return Color(hex: "E6A817") }
        return Color(hex: "3CB504")
    }

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
                    VStack(spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: "3CB504").opacity(0.12))
                                .frame(width: 72, height: 72)
                            Image(systemName: "shippingbox")
                                .font(.system(size: 32))
                                .foregroundColor(Color(hex: "3CB504"))
                        }

                        Text(producto.nombre)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: "1A1A1A"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)

                        Text(producto.clave)
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "888888"))
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
                            HStack(spacing: 6) {
                                Image(systemName: "dollarsign.circle")
                                    .foregroundColor(Color(hex: "3CB504"))
                                Text("Precio")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(hex: "888888"))
                            }
                            Text("$\(String(format: "%.2f", producto.precio))")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(Color(hex: "3CB504"))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(14)
                        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)

                        // Stock
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 6) {
                                Image(systemName: "cube.box")
                                    .foregroundColor(stockColor)
                                Text("Stock")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(hex: "888888"))
                            }
                            Text(
                                producto.stock <= 0
                                ? "Sin stock"
                                : "\(producto.stock) uds"
                            )
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(stockColor)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(14)
                        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                    }

                    // ── INFORMACIÓN DEL PRODUCTO ─────────────────
                    VStack(alignment: .leading, spacing: 0) {

                        // Título sección
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle")
                                .foregroundColor(Color(hex: "3CB504"))
                            Text("Información")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(Color(hex: "1A1A1A"))
                        }
                        .padding(.bottom, 12)

                        // Clave — siempre visible
                        FilaDetalle(
                            icono: "barcode",
                            etiqueta: "Clave",
                            valor: producto.clave
                        )

                        // Marca — solo si tiene valor
                        Group {
                            if !producto.marca.isEmpty {
                                Divider()
                                FilaDetalle(
                                    icono: "tag",
                                    etiqueta: "Marca",
                                    valor: producto.marca
                                )
                            }
                        }

                        // Precio mayoreo — solo si es mayor a 0
                        Group {
                            if producto.precioMayoreo > 0 {
                                Divider()
                                FilaDetalle(
                                    icono: "cart",
                                    etiqueta: "Precio mayoreo",
                                    valor: "$\(String(format: "%.2f", producto.precioMayoreo))"
                                )
                            }
                        }

                        // Última actualización
                        Divider()
                        FilaDetalle(
                            icono: "clock",
                            etiqueta: "Actualizado",
                            valor: producto.ultimaActualizacion.formatted(
                                date: .abbreviated,
                                time: .shortened
                            )
                        )
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(14)
                    .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)

                    // ── DESCRIPCIÓN ──────────────────────────────
                    if !producto.descripcion.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 8) {
                                Image(systemName: "text.alignleft")
                                    .foregroundColor(Color(hex: "3CB504"))
                                Text("Descripción")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(Color(hex: "1A1A1A"))
                            }
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
                }
                .padding(16)
            }
            .background(Color(hex: "F5F5F5"))
        }
        .navigationBarHidden(true)
    }
}
