//
//  ApiServices.swift
//  La-Raza
//
//  Created by Alumno on 28/04/26.
//

import Foundation

// ── DTOs — lo que manda y recibe la API ─────────────────────────

struct LoginRequest: Codable {
    let username: String
    let password: String
}

struct LoginResponse: Codable {
    let token: String
    let usuario: UsuarioDTO
}

struct UsuarioDTO: Codable {
    let id: Int
    let username: String
    let rol: String
}

struct ProductoDTO: Codable {
    let id: Int
    let nombre: String
    let categoria: String
    let precio: Double
    let stock: Double
    let unidad: String
    let descripcion: String
}

struct VisitaRequest: Codable {
    let nombreProductor: String
    let ranchoEjido: String
    let cultivo: String
    let latitud: Double?
    let longitud: Double?
    let notas: String
    let productosRecomendados: [String]
}

struct VisitaResponse: Codable {
    let id: Int
    let fechaVisita: String
}

// ── ERRORES ──────────────────────────────────────────────────────
enum APIError: LocalizedError {
    case sinConexion
    case noAutorizado
    case respuestaInvalida
    case servidor(String)

    var errorDescription: String? {
        switch self {
        case .sinConexion:      return "Sin conexion. Los datos se guardaran localmente."
        case .noAutorizado:     return "Sesion expirada. Inicia sesion nuevamente."
        case .respuestaInvalida: return "Error en la respuesta del servidor."
        case .servidor(let msg): return msg
        }
    }
}

// ── API SERVICE ──────────────────────────────────────────────────
class APIService {
    static let shared = APIService()

    // Cambia esto por tu URL real cuando despliegues en DigitalOcean
    private let baseURL = "http://localhost:3000/api"

    // Token JWT en memoria durante la sesion
    var token: String? = nil

    private init() {}

    // ── Headers comunes ──────────────────────────────────────────
    private func request(
        endpoint: String,
        method: String = "GET",
        body: Data? = nil
    ) throws -> URLRequest {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.respuestaInvalida
        }
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        req.httpBody = body
        req.timeoutInterval = 10
        return req
    }

    // ── LOGIN ────────────────────────────────────────────────────
    func login(username: String, password: String) async throws -> LoginResponse {
        let body = try JSONEncoder().encode(LoginRequest(username: username, password: password))
        let req = try request(endpoint: "/auth/login", method: "POST", body: body)

        do {
            let (data, response) = try await URLSession.shared.data(for: req)
            guard let http = response as? HTTPURLResponse else { throw APIError.respuestaInvalida }

            switch http.statusCode {
            case 200:
                let loginResp = try JSONDecoder().decode(LoginResponse.self, from: data)
                self.token = loginResp.token
                return loginResp
            case 401:
                throw APIError.noAutorizado
            default:
                throw APIError.servidor("Error \(http.statusCode)")
            }
        } catch is URLError {
            throw APIError.sinConexion
        }
    }

    // ── PRODUCTOS ────────────────────────────────────────────────
    func obtenerProductos() async throws -> [ProductoDTO] {
        let req = try request(endpoint: "/productos")

        do {
            let (data, response) = try await URLSession.shared.data(for: req)
            guard let http = response as? HTTPURLResponse,
                  http.statusCode == 200 else { throw APIError.respuestaInvalida }

            return try JSONDecoder().decode([ProductoDTO].self, from: data)
        } catch is URLError {
            throw APIError.sinConexion
        }
    }

    // ── VISITAS ──────────────────────────────────────────────────
    func subirVisita(_ visita: VisitaLocal) async throws -> VisitaResponse {
        let dto = VisitaRequest(
            nombreProductor: visita.nombreProductor,
            ranchoEjido: visita.ranchoEjido,
            cultivo: visita.cultivo,
            latitud: visita.latitud,
            longitud: visita.longitud,
            notas: visita.notas,
            productosRecomendados: visita.productosRecomendados
        )
        let body = try JSONEncoder().encode(dto)
        let req = try request(endpoint: "/visitas", method: "POST", body: body)

        do {
            let (data, response) = try await URLSession.shared.data(for: req)
            guard let http = response as? HTTPURLResponse else { throw APIError.respuestaInvalida }

            switch http.statusCode {
            case 201:
                return try JSONDecoder().decode(VisitaResponse.self, from: data)
            case 401:
                throw APIError.noAutorizado
            default:
                throw APIError.servidor("Error \(http.statusCode)")
            }
        } catch is URLError {
            throw APIError.sinConexion
        }
    }
}
