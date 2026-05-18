//
//  SharedComponents.swift
//  La-Raza
//
//  Created by Alumno on 06/05/26.
//

import SwiftUI

// MARK: - FlowLayout
// Usado en NuevaVisitaView e HistorialView
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
            subview.place(
                at: CGPoint(x: x, y: y),
                proposal: ProposedViewSize(size)
            )
            maxHeight = max(maxHeight, size.height)
            x += size.width + spacing
        }
    }
}

// MARK: - SeccionCard
// Usado en NuevaVisitaView
struct SeccionCard<Contenido: View>: View {
    let icono: String
    let titulo: String
    let contenido: () -> Contenido

    init(
        icono: String,
        titulo: String,
        @ViewBuilder contenido: @escaping () -> Contenido
    ) {
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
// Usado en NuevaVisitaView y PerfilView
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

// MARK: - FilaDetalle
// Usado en DetalleProductoView y PerfilView
struct FilaDetalle: View {
    let icono: String
    let etiqueta: String
    let valor: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icono)
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "3CB504"))
                .frame(width: 20)
            Text(etiqueta)
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "888888"))
            Spacer()
            Text(valor)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(hex: "1A1A1A"))
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 10)
    }
}

// MARK: - ChipVisita
// Usado en HistorialView
struct ChipVisita: View {
    let icono: String
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icono)
                .font(.system(size: 11))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .cornerRadius(20)
    }
}

// MARK: - InfoCard
// Usado en DetalleProductoView
struct InfoCard: View {
    let icono: String
    let etiqueta: String
    let valor: String
    let color: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icono)
                    .foregroundColor(Color(hex: color))
                    .font(.system(size: 18))
                Text(etiqueta)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "888888"))
            }
            Text(valor)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(hex: color))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

// MARK: - ModoButton
// Usado en NuevaVisitaView
struct ModoButton: View {
    let modo: String
    let label: String
    let icono: String
    let colorHex: String
    let seleccionado: String
    let accion: () -> Void

    var activo: Bool { seleccionado == modo }

    var body: some View {
        Button(action: accion) {
            HStack(spacing: 6) {
                Image(systemName: icono)
                    .font(.system(size: 15))
                    .foregroundColor(
                        activo ? .white : Color(hex: "888888"))
                Text(label)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(
                        activo ? .white : Color(hex: "888888"))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(activo ? Color(hex: colorHex) : Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        activo ? Color.clear : Color(hex: "E5E7EB"),
                        lineWidth: 1.5)
            )
            .shadow(
                color: activo
                    ? Color(hex: colorHex).opacity(0.25)
                    : Color.clear,
                radius: 6, x: 0, y: 3)
        }
        .animation(.easeInOut(duration: 0.2), value: activo)
    }
}
