//
//  ApiServices.swift
//  La-Raza
//

import Foundation

// MARK: - Configuración
struct APIConfig {
    static let baseURL = "https://laraza.mooo.com/api"
}

// MARK: - Errores
enum APIError: LocalizedError {
    case sinConexion
    case noAutorizado
    case respuestaInvalida
    case servidor(String)

    var errorDescription: String? {
        switch self {
        case .sinConexion:       return "Sin conexión al servidor."
        case .noAutorizado:      return "Sesión expirada. Inicia sesión de nuevo."
        case .respuestaInvalida: return "Error en la respuesta del servidor."
        case .servidor(let m):   return m
        }
    }
}

// MARK: - DTOs

struct LoginRequest: Codable {
    let username: String
    let password: String
}

struct LoginResponse: Codable {
    let token: String
}

// ── HELPER: igual que _toDouble() de Flutter ─────────────────────
// Acepta Double, Int o String del backend sin lanzar DecodingError
private func flexDouble(
    _ container: KeyedDecodingContainer<ArticuloDTO.CodingKeys>,
    key: ArticuloDTO.CodingKeys
) -> Double? {
    if let d = try? container.decode(Double.self, forKey: key) { return d }
    if let i = try? container.decode(Int.self,    forKey: key) { return Double(i) }
    if let s = try? container.decode(String.self, forKey: key) { return Double(s) }
    return nil
}

// ── ARTÍCULO ─────────────────────────────────────────────────────
struct ArticuloDTO: Codable {
    let id: Int
    let clave: String
    let nombre: String
    let descripcion: String?
    let precioVenta: Double?
    let precioSugerido: Double?
    let precioReferencia: Double?
    let existencias: [ExistenciaDTO]?
    let marcas: MarcaDTO?

    // Campos calculados — igual que Flutter
    var precio: Double { precioVenta ?? precioSugerido ?? 0.0 }

    var stockTotal: Int {
        existencias?.reduce(0) { $0 + Int($1.existencia ?? 0) } ?? 0
    }

    var marca: String? { marcas?.nombre }

    enum CodingKeys: String, CodingKey {
        case id, clave, nombre, descripcion, existencias, marcas
        case precioVenta      = "precio_venta"
        case precioSugerido   = "precio_sugerido"
        case precioReferencia = "precio_referencia"
    }

    // ── Decoder flexible ──────────────────────────────────────────
    // El backend puede mandar precios como String "850.00", Int 850
    // o Double 850.0. Swift es estricto por defecto; este init
    // replica el comportamiento de _toDouble() de Flutter.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        // Campos estrictos (siempre son el tipo correcto)
        id          = try  c.decode(Int.self,    forKey: .id)
        clave       = (try? c.decode(String.self, forKey: .clave))       ?? ""
        nombre      = (try? c.decode(String.self, forKey: .nombre))      ?? "Sin nombre"
        descripcion = try? c.decode(String.self, forKey: .descripcion)
        existencias = try? c.decode([ExistenciaDTO].self, forKey: .existencias)
        marcas      = try? c.decode(MarcaDTO.self, forKey: .marcas)

        // Precios flexibles — acepta String, Int o Double
        precioVenta      = flexDouble(c, key: .precioVenta)
        precioSugerido   = flexDouble(c, key: .precioSugerido)
        precioReferencia = flexDouble(c, key: .precioReferencia)
    }
}

// ── EXISTENCIA ───────────────────────────────────────────────────
struct ExistenciaDTO: Codable {
    let existencia: Double?

    enum CodingKeys: String, CodingKey { case existencia }

    // También flexible: el backend puede mandar "5", 5 o 5.0
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        if      let d = try? c.decode(Double.self, forKey: .existencia) { existencia = d }
        else if let i = try? c.decode(Int.self,    forKey: .existencia) { existencia = Double(i) }
        else if let s = try? c.decode(String.self, forKey: .existencia) { existencia = Double(s) }
        else                                                             { existencia = nil }
    }
}

struct MarcaDTO: Codable {
    let nombre: String?
}

// Respuesta paginada de artículos
struct ArticulosResponse: Codable {
    let data: [ArticuloDTO]
}

// Cultivo
struct CultivoDTO: Codable {
    let id: Int
    let nombre: String
}

struct CultivosResponse: Codable {
    let data: [CultivoDTO]
}

// Visita para enviar al backend
// VisitaRequest — agrega modo y especie
struct VisitaRequest: Codable {
    let idLocal: String
    let productor: String
    let rancho: String
    let cultivoId: Int
    let modo: String              // ← NUEVO
    let especie: String?          // ← NUEVO
    let latitud: Double?
    let longitud: Double?
    let notas: String
    let fechaVisita: String
    let productosRecomendados: [ProductoRecomendadoDTO]

    enum CodingKeys: String, CodingKey {
        case idLocal             = "id_local"
        case productor, rancho, latitud, longitud, notas, modo, especie
        case cultivoId           = "cultivo_id"
        case fechaVisita         = "fecha_visita"
        case productosRecomendados = "productos_recomendados"
    }
}

struct ProductoRecomendadoDTO: Codable {
    let articuloNombre: String
    enum CodingKeys: String, CodingKey { case articuloNombre = "articulo_nombre" }
}

struct VisitaResponse: Codable {
    let id: Int?
    let idLocal: String?
    enum CodingKeys: String, CodingKey { case id; case idLocal = "id_local" }
}

struct SyncRequest: Codable {
    let visitas: [VisitaRequest]
}

struct SyncResultado: Codable {
    let creadas: Int?
    let duplicadas: Int?
}

struct SyncResponse: Codable {
    let resultados: SyncResultado?
}

// MARK: - API Service
class APIService {
    static let shared = APIService()
    var token: String? = nil
    private init() {}

    // ── Construir request ────────────────────────────────────────
    private func buildRequest(
        endpoint: String,
        method: String = "GET",
        body: Data? = nil
    ) throws -> URLRequest {
        guard let url = URL(string: "\(APIConfig.baseURL)\(endpoint)") else {
            throw APIError.respuestaInvalida
        }
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token { req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        req.httpBody = body
        req.timeoutInterval = 15   // 15 s — más margen para 200 artículos
        return req
    }

    private func execute(_ req: URLRequest) async throws -> Data {
        do {
            let (data, response) = try await URLSession.shared.data(for: req)
            guard let http = response as? HTTPURLResponse else {
                throw APIError.respuestaInvalida
            }

            #if DEBUG
            if let str = String(data: data, encoding: .utf8) {
                print("📡 [\(http.statusCode)] \(req.url?.path ?? "")")
                // Imprime más caracteres para ver la estructura completa
                print(str.prefix(600))
            }
            #endif

            switch http.statusCode {
            case 200, 201: return data
            case 401:      throw APIError.noAutorizado
            default:       throw APIError.servidor("Error \(http.statusCode)")
            }
        } catch let err as APIError {
            throw err
        } catch {
            throw APIError.sinConexion
        }
    }

    // ── AUTH ─────────────────────────────────────────────────────
    func login(username: String, password: String) async throws {
        let body = try JSONEncoder().encode(LoginRequest(username: username, password: password))
        let req  = try buildRequest(endpoint: "/auth/login", method: "POST", body: body)
        let data = try await execute(req)
        let resp = try JSONDecoder().decode(LoginResponse.self, from: data)
        self.token = resp.token
        UserDefaults.standard.set(resp.token, forKey: "jwt_token")
    }

    func cargarTokenGuardado() {
        token = UserDefaults.standard.string(forKey: "jwt_token")
    }

    func logout() {
        token = nil
        UserDefaults.standard.removeObject(forKey: "jwt_token")
    }

    // ── INVENTARIO ───────────────────────────────────────────────
    func getArticulos(
        page: Int = 1,
        limit: Int = 200,
        search: String? = nil
    ) async throws -> [ArticuloDTO] {
        var endpoint = "/inventario/articulos?page=\(page)&limit=\(limit)"
        if let search, !search.isEmpty {
            let encoded = search.addingPercentEncoding(
                withAllowedCharacters: .urlQueryAllowed) ?? ""
            endpoint += "&search=\(encoded)"
        }
        let req  = try buildRequest(endpoint: endpoint)
        let data = try await execute(req)
        let resp = try JSONDecoder().decode(ArticulosResponse.self, from: data)
        return resp.data
    }

    func getArticuloDetalle(id: Int) async throws -> ArticuloDTO {
        let req  = try buildRequest(endpoint: "/inventario/articulos/\(id)")
        let data = try await execute(req)
        return try JSONDecoder().decode(ArticuloDTO.self, from: data)
    }

    func getArticulosParaVisita(search: String) async throws -> [ArticuloDTO] {
        var endpoint = "/inventario/articulos?limit=15"
        if !search.isEmpty {
            let encoded = search.addingPercentEncoding(
                withAllowedCharacters: .urlQueryAllowed) ?? ""
            endpoint += "&search=\(encoded)"
        }
        let req  = try buildRequest(endpoint: endpoint)
        let data = try await execute(req)
        let resp = try JSONDecoder().decode(ArticulosResponse.self, from: data)
        return resp.data
    }

    // ── CULTIVOS ─────────────────────────────────────────────────
    func getCultivos() async throws -> [CultivoDTO] {
        let req  = try buildRequest(endpoint: "/cultivos")
        let data = try await execute(req)
        let resp = try JSONDecoder().decode(CultivosResponse.self, from: data)
        return resp.data
    }

    // ── VISITAS ──────────────────────────────────────────────────
    func subirVisita(_ visita: VisitaLocal) async throws {
        let body = try JSONEncoder().encode(visita.toRequest())
        let req  = try buildRequest(endpoint: "/visitas", method: "POST", body: body)
        _ = try await execute(req)
    }

    func sincronizarVisitas(_ visitas: [VisitaLocal]) async throws -> SyncResultado {
        let body = try JSONEncoder().encode(SyncRequest(visitas: visitas.map { $0.toRequest() }))
        let req  = try buildRequest(endpoint: "/visitas/sync", method: "POST", body: body)
        let data = try await execute(req)
        let resp = try JSONDecoder().decode(SyncResponse.self, from: data)
        return resp.resultados ?? SyncResultado(creadas: 0, duplicadas: 0)
    }

    func getVisitasServidor() async throws -> [VisitaResponse] {
        let req  = try buildRequest(endpoint: "/visitas?limit=100")
        let data = try await execute(req)
        struct Wrapper: Codable { let data: [VisitaResponse] }
        let resp = try JSONDecoder().decode(Wrapper.self, from: data)
        return resp.data
    }
}
