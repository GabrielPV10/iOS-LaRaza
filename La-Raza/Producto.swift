//
//  Producto.swift
//  La-Raza
//
//  Created by Alumno on 15/04/26.
//

import SwiftUI

// MARK: - Modelo
struct Producto: Identifiable {
    let id = UUID()
    let nombre: String
    let categoria: String
    let precio: Double
    let stock: Double
    let unidad: String
    let descripcion: String
    let colorCategoria: String  // hex del color del ícono
}

// MARK: - Datos de prueba (después se reemplaza con API)
extension Producto {
    static let ejemplos: [Producto] = [
        Producto(nombre: "Urea 46%",          categoria: "Fertilizantes", precio: 850,  stock: 120, unidad: "kg",  descripcion: "Fertilizante nitrogenado de alta concentración. Ideal para cultivos de maíz, sorgo y caña.", colorCategoria: "D6F5D6"),
        Producto(nombre: "Glifosato 480 SL",  categoria: "Herbicidas",    precio: 320,  stock: 45,  unidad: "L",   descripcion: "Herbicida sistémico de amplio espectro para control de malezas anuales y perennes.", colorCategoria: "FFF3D6"),
        Producto(nombre: "Maíz Híbrido H-438",categoria: "Semillas",      precio: 1250, stock: 8,   unidad: "kg",  descripcion: "Semilla híbrida de alto rendimiento. Tolerante a sequía y enfermedades foliares.", colorCategoria: "D6EEF5"),
        Producto(nombre: "Clorpirifos 480 EC",categoria: "Insecticidas",  precio: 280,  stock: 32,  unidad: "L",   descripcion: "Insecticida organofosforado de contacto e ingestión para plagas de suelo y follaje.", colorCategoria: "FFE5E5"),
        Producto(nombre: "DAP 18-46-0",       categoria: "Fertilizantes", precio: 980,  stock: 0,   unidad: "kg",  descripcion: "Fosfato diamónico. Fuente de fósforo y nitrógeno para establecimiento de cultivos.", colorCategoria: "D6F5D6"),
        Producto(nombre: "Soya Cristalina",   categoria: "Semillas",      precio: 680,  stock: 55,  unidad: "kg",  descripcion: "Variedad de soya de ciclo corto adaptada al trópico húmedo de Chiapas.", colorCategoria: "D6EEF5"),
        Producto(nombre: "Mancozeb 80 WP",    categoria: "Fungicidas",    precio: 195,  stock: 18,  unidad: "kg",  descripcion: "Fungicida protectante de contacto para enfermedades foliares en hortalizas y granos.", colorCategoria: "F0D6F5"),
        Producto(nombre: "Sulfato de Potasio",categoria: "Fertilizantes", precio: 760,  stock: 90,  unidad: "kg",  descripcion: "Fuente de potasio y azufre. Mejora calidad de frutos y resistencia a enfermedades.", colorCategoria: "D6F5D6"),
    ]
}
