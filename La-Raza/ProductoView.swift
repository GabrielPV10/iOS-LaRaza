//
//  ProductosView.swift
//  La-Raza
//
//  Created by Alumno on 21/04/26.
//

import SwiftUI

struct ProductosView: View {
    @State private var busqueda: String = ""
    @State private var categoriaSeleccionada: String = "Todas"

    let categorias = ["Todas", "Fertilizantes", "Herbicidas", "Insecticidas", "Semillas", "Fungicidas"]

    var productosFiltrados: [Producto] {
        Producto.ejemplos.filter { producto in
            let coincideCategoria = categoriaSeleccionada == "Todas" || producto.categoria == categoriaSeleccionada
            let coincideBusqueda  = busqueda.isEmpty || producto.nombre.localizedCaseInsensitiveContains(busqueda)
            return coincideCategoria && coincideBusqueda
        }
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

                VStack(spacing: 10) {
                    HStack {
                        Button(action: {}) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                        }
                        Spacer()
                        Text("Catálogo de Productos")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        // Espacio para centrar el título
                        Image(systemName: "chevron.left")
                            .opacity(0)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    // Barra de búsqueda
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white.opacity(0.7))
                        TextField("", text: $busqueda,
                            prompt: Text("Buscar producto...")
                                .foregroundColor(.white.opacity(0.6))
                        )
                        .foregroundColor(.white)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                }
            }
            .fixedSize(horizontal: false, vertical: true)

            // ── FILTROS DE CATEGORÍA ─────────────────────────────
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(categorias, id: \.self) { categoria in
                        Button(action: {
                            categoriaSeleccionada = categoria
                        }) {
                            Text(categoria)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(categoriaSeleccionada == categoria ? .white : Color(hex: "444444"))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                                .background(
                                    categoriaSeleccionada == categoria
                                    ? Color(hex: "3CB504")
                                    : Color.white
                                )
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(
                                            categoriaSeleccionada == categoria
                                            ? Color.clear
                                            : Color(hex: "CCCCCC"),
                                            lineWidth: 1
                                        )
                                )
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(Color.white)

            // Contador
            HStack {
                Text("\(productosFiltrados.count) productos")
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "888888"))
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(hex: "F5F5F5"))

            // ── LISTA DE PRODUCTOS ───────────────────────────────
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(productosFiltrados) { producto in
                        NavigationLink(destination: DetalleProductoView(producto: producto)) {
                            ProductoRow(producto: producto)
                        }
                        .buttonStyle(.plain)

                        Divider()
                            .padding(.leading, 72)
                    }
                }
                .background(Color.white)
                .cornerRadius(12)
                .padding(16)
            }
            .background(Color(hex: "F5F5F5"))
        }
        .navigationBarHidden(true)
    }
}

// ── FILA DE PRODUCTO ─────────────────────────────────────────────
struct ProductoRow: View {
    let producto: Producto

    var body: some View {
        HStack(spacing: 12) {

            // Ícono con color por categoría
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: producto.colorCategoria))
                    .frame(width: 44, height: 44)
                Image(systemName: "shippingbox")
                    .font(.system(size: 18))
                    .foregroundColor(colorIcono(categoria: producto.categoria))
            }

            // Info
            VStack(alignment: .leading, spacing: 3) {
                Text(producto.nombre)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "1A1A1A"))

                HStack(spacing: 6) {
                    // Badge categoría
                    Text(producto.categoria)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(colorIcono(categoria: producto.categoria))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color(hex: producto.colorCategoria))
                        .cornerRadius(10)

                    // Stock
                    if producto.stock == 0 {
                        Text("Sin stock")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color(hex: "E53935"))
                    } else {
                        Text("\(Int(producto.stock)) \(producto.unidad)")
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: "888888"))
                    }
                }
            }

            Spacer()

            // Precio + flecha
            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(String(format: "%.2f", producto.precio))")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: "3CB504"))

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "CCCCCC"))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
    }

    func colorIcono(categoria: String) -> Color {
        switch categoria {
        case "Fertilizantes": return Color(hex: "3CB504")
        case "Herbicidas":    return Color(hex: "E6A817")
        case "Insecticidas":  return Color(hex: "E53935")
        case "Semillas":      return Color(hex: "2196F3")
        case "Fungicidas":    return Color(hex: "9C27B0")
        default:              return Color(hex: "3CB504")
        }
    }
}

#Preview {
    NavigationStack {
        ProductosView()
    }
}
