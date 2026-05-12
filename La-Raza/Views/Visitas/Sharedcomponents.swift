//
//  Sharedcomponents.swift
//  La-Raza
//
//  Created by Alumno on 12/05/26.
//

import SwiftUI

// MARK: - FilaDetalle
// Usada en: DetalleProductoSheet, DetalleVisitaSheet
struct FilaDetalle: View {
    let icono: String
    let etiqueta: String
    let valor: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icono)
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "3CB504"))
                .frame(width: 18)
            Text(etiqueta)
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "888888"))
            Spacer()
            Text(valor)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(hex: "1A1A1A"))
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - InfoSeccion
// Usada en: DetalleVisitaSheet
struct InfoSeccion<C: View>: View {
    let titulo: String
    let contenido: () -> C

    init(titulo: String, @ViewBuilder contenido: @escaping () -> C) {
        self.titulo = titulo
        self.contenido = contenido
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(titulo)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(Color(hex: "3CB504"))
                .textCase(.uppercase)
            contenido()
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 3, x: 0, y: 1)
    }
}

// MARK: - SeccionCard
// Usada en: NuevaVisitaView
struct SeccionCard<Contenido: View>: View {
    let icono: String
    let titulo: String
    let contenido: () -> Contenido

    init(icono: String, titulo: String, @ViewBuilder contenido: @escaping () -> Contenido) {
        self.icono = icono
        self.titulo = titulo
        self.contenido = contenido
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icono)
                    .foregroundColor(Color(hex: "3CB504"))
                    .font(.system(size: 15))
                Text(titulo)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color(hex: "1A1A1A"))
            }
            contenido()
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

// MARK: - CampoTexto
// Usada en: NuevaVisitaView
struct CampoTexto: View {
    let icono: String
    let placeholder: String
    @Binding var texto: String

    var body: some View {
        HStack {
            Image(systemName: icono)
                .foregroundColor(Color(hex: "3CB504"))
                .frame(width: 20)
            TextField(placeholder, text: $texto)
                .foregroundColor(Color(hex: "1A1A1A"))
                .autocapitalization(.words)
                .disableAutocorrection(true)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(Color(hex: "F0FAF0"))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(hex: "3CB504").opacity(0.4), lineWidth: 1)
        )
    }
}

// MARK: - FlowLayout
// Usada en: NuevaVisitaView, DetalleVisitaSheet
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let width = proposal.width ?? 0
        var height: CGFloat = 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        var maxHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width {
                y += maxHeight + spacing
                x = 0
                maxHeight = 0
            }
            maxHeight = max(maxHeight, size.height)
            x += size.width + spacing
            height = y + maxHeight
        }
        return CGSize(width: width, height: height)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        var x = bounds.minX
        var y = bounds.minY
        var maxHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX {
                y += maxHeight + spacing
                x = bounds.minX
                maxHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            maxHeight = max(maxHeight, size.height)
            x += size.width + spacing
        }
    }
}
