import Foundation
import SwiftData
import SomariKit
import Synchronization
import CoreData

protocol EntityConvertible<EntityType>: PersistentModel {
    associatedtype EntityType

    init(_ entity: EntityType)

    func entity() -> EntityType
    func update(from entity: EntityType)
}

protocol ModelConvertible<ModelType> {
    associatedtype ModelType: EntityConvertible where ModelType.EntityType == Self
    var id: ModelIdentifier { get }
}

struct ModelIdentifier: Equatable, Hashable {
    private let id: PersistentIdentifier

    init(id: PersistentIdentifier) {
        self.id = id
    }

    init() {
        self.id = try! .identifier(for: "", entityName: "", primaryKey: 1)
    }
}

protocol Database {
    func insert<Model: PersistentModel>(_ model: Model) async throws
    func delete<Model: PersistentModel>(_ model: Model) async throws
    func delete<Model: PersistentModel>(_ models: [Model]) async throws
    func load<Model: PersistentModel>() async throws -> [Model]

    associatedtype Cancel: Cancellable
    func subscribeChangedNotification<Model: PersistentModel>(
        of type: Model.Type,
        actionFirstTime: Bool,
        action: @MainActor @escaping () -> Void
    ) -> Cancel
}

extension Database {
    func insert<Entity: ModelConvertible>(_ model: Entity) async throws {
        try await insert(Entity.ModelType.init(model))
    }

    func load<Entity: ModelConvertible>() async throws -> [Entity] {
        let models = try await load() as [Entity.ModelType]
        return models.map { $0.entity() }
    }

    func subscribeChangedNotification<Model: PersistentModel>(of type: Model.Type, action: @MainActor @escaping () -> Void) -> Cancel {
        subscribeChangedNotification(of: type, actionFirstTime: false, action: action)
    }

    func subscribeChangedNotification<Model: PersistentModel>(of type: Model.Type, actionForFirstTime: Bool = false) -> AsyncStream<Model.Type> {
        let (stream, continuation) = AsyncStream.makeStream(of: Model.Type.self)

        let cancellable = subscribeChangedNotification(of: type, actionFirstTime: actionForFirstTime) {
            continuation.yield(type)
        }
        DispatchQueue.main.async {
            let mutex: Synchronization.Mutex<Cancel> = .init(cancellable)
            continuation.onTermination = { _ in
                mutex.withLock { cancellable in
                    cancellable.cancel()
                }
            }
        }

        return stream
    }

    func subscribeChangedNotification<Entity: ModelConvertible>(of type: Entity.Type, actionFirstTime: Bool = false, action: @MainActor @escaping () -> Void) -> Cancel {
        subscribeChangedNotification(of: Entity.ModelType.self, actionFirstTime: actionFirstTime, action: action)
    }

    func subscribeChangedNotification<Entity: ModelConvertible>(of type: Entity.Type, actionForFirstTime: Bool = false) -> AsyncStream<Entity.Type> {
        let (stream, continuation) = AsyncStream.makeStream(of: Entity.Type.self)

        let task = Task {
            for await _ in subscribeChangedNotification(
                of: Entity.ModelType.self,
                actionForFirstTime: actionForFirstTime
            ) {
                continuation.yield(type)
            }
        }

        continuation.onTermination = { _ in
            task.cancel()
        }

        return stream
    }

    func delete<Entity: ModelConvertible>(_ entities: [Entity]) async throws {
        try await delete(entities.map(Entity.ModelType.init))
    }

    func delete<Entity: ModelConvertible>(_ entity: Entity) async throws {
        try await delete(Entity.ModelType.init(entity))
    }
}

final class SwiftDatabase: Database {
    struct ChangedSubscription: Hashable, Equatable {
        static func ==(lhs: ChangedSubscription, rhs: ChangedSubscription) -> Bool {
            lhs.uuid == rhs.uuid
        }
        let type: Any.Type
        let action: () -> Void
        let uuid: UUID = .init()

        func hash(into hasher: inout Hasher) {
            hasher.combine(uuid)
        }
    }

    private let container: ModelContainer
    private var subscriptions: Set<ChangedSubscription> = []

    init() throws {
        let configuration = ModelConfiguration()
        self.container = try ModelContainer(
            for: FeedSourceEntity.self,
            configurations: configuration
        )
    }

    func insert<Model: PersistentModel>(_ model: Model) async throws {
        let context = container.mainContext
        context.insert(model)
        try context.save()
        notifyChanged(of: Model.self)
    }

    func delete<Model: PersistentModel>(_ model: Model) async throws {
        let context = container.mainContext
        context.delete(model)
        try context.save()
        notifyChanged(of: Model.self)
    }

    func delete<Model: PersistentModel>(_ models: [Model]) async throws {
        let context = container.mainContext
        for model in models {
            context.delete(model)
        }
        try context.save()
        notifyChanged(of: Model.self)
    }

    func load<Model: PersistentModel>() async throws -> [Model] {
        let context = container.mainContext
        let descriptor = FetchDescriptor<Model>()
        let result = try context.fetch(descriptor)

        return result
    }

    func subscribeChangedNotification<Model: PersistentModel>(
        of type: Model.Type,
        actionFirstTime: Bool,
        action: @MainActor @escaping () -> Void
    ) -> AnyCancellable {
        let subscription = ChangedSubscription(type: type) {
            action()
        }
        subscriptions.insert(subscription)
        if actionFirstTime {
            action()
        }
        return AnyCancellable { [weak self] in
            self?.subscriptions.remove(subscription)
        }
    }
}

private extension SwiftDatabase {
    func notifyChanged<Model: PersistentModel>(of type: Model.Type) {
        for subscription in self.subscriptions {
            if subscription.type == type {
                subscription.action()
            }
        }
    }
}

final class DummyDatabase: Database {
    init() {
    }

    func insert<Model: PersistentModel>(_ model: Model) async throws {
    }

    func delete<Model: PersistentModel>(_ model: Model) async throws {
    }

    func delete<Model: PersistentModel>(_ models: [Model]) async throws {
    }

    func load<Model: PersistentModel>() async throws -> [Model] {
        []
    }

    func subscribeChangedNotification<Model: PersistentModel>(of type: Model.Type, actionFirstTime: Bool, action: @MainActor @escaping () -> Void) -> AnyCancellable {
        AnyCancellable {
        }
    }
}

struct DatabaseKey: ContainerKey {
    static let defaultValue: any Database = {
        do {
            return try SwiftDatabase()
        } catch {
            fatalError("Failed to initialize database: \(error)" )
        }
    }()

    static var testValue: any Database {
        DummyDatabase()
    }
}
