import Vapor

// configures your application
@available(macOS 15.0, *)
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    // register routes

    app.http.server.configuration.port = ConfigUtility.getPort()

    try routes(app)
}
