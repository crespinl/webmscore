
export const IS_NODE = typeof process === 'object' && typeof process.versions === 'object' && typeof process.versions.node === 'string'

export const getSelfURL = () => {
    let url = import.meta.url  // transforms to "" in the generated bundle
    if (!url) {
        if (typeof document !== 'undefined') {
            url = document.currentScript && document.currentScript.src || document.baseURI
        } else if (typeof location !== 'undefined') {
            url = location.href
        }
    }
    return url
}

export const shimDom = () => {
    const getGlobalThis = () => {
        if (typeof self !== 'undefined') { return self }
        if (typeof window !== 'undefined') { return window }
        if (typeof global !== 'undefined') { return global }
        throw new Error('unable to locate global object')
    }

    const globalthis = getGlobalThis()
    globalthis.window = globalthis.window || {
        addEventListener() { },
        removeEventListener() { },
        location: new URL("file:///"),
        encodeURIComponent,
        // Qt (its wasm event dispatcher) schedules its timers on `window`
        setTimeout: (...args) => globalthis.setTimeout(...args),
        clearTimeout: (...args) => globalthis.clearTimeout(...args),
        setInterval: (...args) => globalthis.setInterval(...args),
        clearInterval: (...args) => globalthis.clearInterval(...args),
        queueMicrotask: (...args) => globalthis.queueMicrotask(...args),
    }
    // `navigator` is a read-only accessor in recent Node.js versions
    if (!globalthis.navigator) {
        Object.defineProperty(globalthis, 'navigator', { value: {}, configurable: true, writable: true })
    }
}
