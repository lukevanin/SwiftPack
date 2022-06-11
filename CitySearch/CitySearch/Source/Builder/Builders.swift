import Foundation

///
/// Creates an instance of the associated artefact type.
///
/// Builders are used to product instances of objects, while hiding the procedure used to create the object:
/// - Isolates potentially complex procedures and deependency graphs from the rest of the
/// application code.
/// - Allows categories of instance types to be used interchangably.
///
protocol BuilderProtocol {
    associatedtype Artefact
    func build() async throws -> Artefact
}


///
/// A type-erasing structure that allows builders to be used generically.
///
/// - Note: Type-erasure is no longer needed from Swift 5.7.
///
struct AnyBuilder<Artefact>: BuilderProtocol {
    
    private let wrappedBuild: () async throws -> Artefact
    
    init<B>(_ builder: B) where B: BuilderProtocol, B.Artefact == Artefact {
        self.wrappedBuild = builder.build
    }
    
    func build() async throws -> Artefact {
        try await wrappedBuild()
    }
}
