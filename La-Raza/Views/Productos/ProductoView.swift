//
//  ProductosView.swift
//  La-Raza
//

import SwiftUI
import SwiftData

struct ProductosView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var vm = ProductosViewModel()

    @State private var busqueda: String = ""
    @State private var productoSeleccionado: ProductoLocal? = nil   // ← sheet

    var productosFiltrados: [ProductoLocal] {
        if busqueda.isEmpty { return vm.productos }
        let q = busqueda.lowercased()
        return vm.productos.filter {
            $0.nombre.lowercased().contains(q) ||
            $0.clave.lowercased().contains(q)  ||
            $0.marca.lowercased().contains(q)
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
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                        }
                        Spacer()
                        Text("Inventario")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        Button(action: {
                            busqueda = ""
                            vm.cargarProductos(modelContext: modelContext)
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .medium))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    // Barra de búsqueda
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white.opacity(0.7))

                        TextField("", text: $busqueda,
                            prompt: Text("Buscar producto...")
                                .foregroundColor(.white.opacity(0.6))
                        )
                        .foregroundColor(.white)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .onChange(of: busqueda) { _, nuevo in
                            if nuevo.isEmpty {
                                vm.cargarProductos(modelContext: modelContext)
                            } else if nuevo.count >= 2 {
                                vm.buscar(nuevo, modelContext: modelContext)
                            }
                        }

                        if !busqueda.isEmpty {
                            Button(action: {
                                busqueda = ""
                                vm.cargarProductos(modelContext: modelContext)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
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

            // Banner offline
            if vm.modoOffline {
                HStack(spacing: 8) {
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 13))
                    Text("Sin conexión · mostrando datos locales")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(Color(hex: "E6A817"))
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(Color(hex: "FFF3D6"))
            }

            // Contador
            if !vm.cargando && vm.error == nil {
                HStack {
                    Text("\(productosFiltrados.count) productos")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "3CB504"))
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(hex: "F5F5F5"))
            }

            // ── CONTENIDO ────────────────────────────────────────
            ZStack {
                Color(hex: "F5F5F5").ignoresSafeArea()

                if vm.cargando && vm.productos.isEmpty {
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(
                                CircularProgressViewStyle(tint: Color(hex: "3CB504"))
                            )
                            .scaleEffect(1.3)
                        Text("Cargando inventario...")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "888888"))
                    }

                } else if let error = vm.error, vm.productos.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "wifi.slash")
                            .font(.system(size: 56))
                            .foregroundColor(Color(hex: "E53935").opacity(0.7))
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "888888"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        Button(action: { vm.cargarProductos(modelContext: modelContext) }) {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.clockwise")
                                Text("Reintentar")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color(hex: "3CB504"))
                            .cornerRadius(12)
                        }
                    }

                } else if productosFiltrados.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "shippingbox")
                            .font(.system(size: 48))
                            .foregroundColor(Color(hex: "CCCCCC"))
                        Text("No se encontraron productos")
                            .font(.system(size: 15))
                            .foregroundColor(Color(hex: "888888"))
                    }

                } else {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(productosFiltrados) { producto in
                                // ← Button en lugar de NavigationLink
                                Button(action: { productoSeleccionado = producto }) {
                                    ProductoCard(producto: producto)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(12)

                        if vm.cargando {
                            ProgressView().padding()
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if vm.productos.isEmpty {
                vm.cargarProductos(modelContext: modelContext)
            }
        }
        // ── SHEET DE DETALLE ─────────────────────────────────────
        .sheet(item: $productoSeleccionado) { producto in
            DetalleProductoSheet(producto: producto)
        }
    }
}

// MARK: - Sheet de detalle (reemplaza DetalleProductoView)

private struct DetalleProductoSheet: View {
    let producto: ProductoLocal
    @Environment(\.dismiss) var dismiss

    var stockColor: Color {
        if producto.stock <= 0 { return Color(hex: "E53935") }
        if producto.stock < 10 { return Color(hex: "E6A817") }
        return Color(hex: "3CB504")
    }

    var body: some View {
        VStack(spacing: 0) {

            // ── HANDLE + HEADER ──────────────────────────────────
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "3CB504"), Color(hex: "1E7A00")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                HStack {
                    Spacer()
                    Text("Detalle del Producto")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.system(size: 22))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
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
                        InfoTile(
                            icono: "dollarsign.circle",
                            iconoColor: Color(hex: "3CB504"),
                            etiqueta: "Precio",
                            valor: "$\(String(format: "%.2f", producto.precio))",
                            valorColor: Color(hex: "3CB504")
                        )
                        InfoTile(
                            icono: "cube.box",
                            iconoColor: stockColor,
                            etiqueta: "Stock",
                            valor: producto.stock <= 0 ? "Sin stock" : "\(producto.stock) uds",
                            valorColor: stockColor
                        )
                    }

                    // ── INFORMACIÓN ──────────────────────────────
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle")
                                .foregroundColor(Color(hex: "3CB504"))
                            Text("Información")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(Color(hex: "1A1A1A"))
                        }
                        .padding(.bottom, 12)

                        FilaDetalle(icono: "barcode",  etiqueta: "Clave",  valor: producto.clave)

                        if !producto.marca.isEmpty {
                            Divider()
                            FilaDetalle(icono: "tag", etiqueta: "Marca", valor: producto.marca)
                        }
                        if producto.precioMayoreo > 0 {
                            Divider()
                            FilaDetalle(
                                icono: "cart",
                                etiqueta: "Precio mayoreo",
                                valor: "$\(String(format: "%.2f", producto.precioMayoreo))"
                            )
                        }
                        Divider()
                        FilaDetalle(
                            icono: "clock",
                            etiqueta: "Actualizado",
                            valor: producto.ultimaActualizacion.formatted(
                                date: .abbreviated, time: .shortened
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
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Subviews reutilizables

private struct InfoTile: View {
    let icono: String
    let iconoColor: Color
    let etiqueta: String
    let valor: String
    let valorColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icono).foregroundColor(iconoColor)
                Text(etiqueta)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "888888"))
            }
            Text(valor)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(valorColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

// MARK: - ProductoCard (sin cambios)

struct ProductoCard: View {
    let producto: ProductoLocal

    var stockColor: Color {
        if producto.stock <= 0  { return Color(hex: "E53935") }
        if producto.stock < 10  { return Color(hex: "E6A817") }
        return Color(hex: "3CB504")
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: "3CB504").opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: "shippingbox")
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "3CB504"))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(producto.nombre)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "1A1A1A"))
                    .lineLimit(2)
                Text(producto.clave)
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "888888"))
                if !producto.marca.isEmpty {
                    Text(producto.marca)
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "888888"))
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                Text("$\(String(format: "%.2f", producto.precio))")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: "3CB504"))
                Text(producto.stock <= 0 ? "Sin stock" : "Stock: \(producto.stock)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(stockColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(stockColor.opacity(0.15))
                    .cornerRadius(20)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

// MARK: - Nota ViewModels.swift
// En ProductosViewModel.cargarProductos() cambia:
//   APIService.shared.getArticulos(page: 1, limit: 50)
// por:
//   APIService.shared.getArticulos(page: 1, limit: 200)
// Para igualar el comportamiento de Flutter (ProductosScreen carga 200 artículos).

#Preview {
    NavigationStack {
        ProductosView()
    }
}
