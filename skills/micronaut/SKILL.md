---
name: micronaut
description: Conventions and gotchas for Micronaut Framework projects, especially those using reactive patterns and Azure SDK integration.
metadata:
  author: timsearle
  version: "1.0"
  category: backend
---

# Micronaut conventions

## Reactive + blocking SDK integration

Azure SDK (and similar blocking SDKs) use Reactor's `block()` internally in their sync clients. Netty event loop threads forbid blocking, causing `IllegalStateException`.

**Pattern**: Offload blocking calls to IO scheduler:

```kotlin
@Named(TaskExecutors.IO)
private val ioExecutor: ExecutorService

fun fetchData(): Mono<Data> {
    val scheduler = Schedulers.fromExecutorService(ioExecutor)
    return Mono.fromCallable { blockingSdkCall() }
        .subscribeOn(scheduler)
}
```

## Configuration files

- **application.yml**: Primary config file, always loaded
- **bootstrap.yml**: Only loaded when config-client is enabled (e.g., for distributed config)
- When in doubt, put config in `application.yml`

## Kotlin + AOP (@Cacheable, @Transactional, etc.)

Kotlin classes are `final` by default. Micronaut AOP interceptors require:
- Either: Mark class and method as `open`
- Or: Use the `kotlin-allopen` Gradle plugin with Micronaut annotations

## Azure SDK quirks

- `JsonWebKey.curveName` getter returns the EC curve (not `.crv`)
- Property accessors don't always match JSON field names
