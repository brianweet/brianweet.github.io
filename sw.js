importScripts("https://storage.googleapis.com/workbox-cdn/releases/3.6.1/workbox-sw.js");
if (workbox) {
    workbox.skipWaiting();
    workbox.clientsClaim();
    workbox.routing.registerRoute(
        "/",
        workbox.strategies.networkFirst({
            cacheName: "homepage-cache"
        })
    );
    workbox.routing.registerRoute(
        new RegExp("/20.*/.*html"),
        workbox.strategies.staleWhileRevalidate({
            cacheName: "posts-cache"
        })
    );
    workbox.routing.registerRoute(
        new RegExp("/assets/js/.*js"),
        workbox.strategies.staleWhileRevalidate({
            cacheName: "js-cache"
        })
    );
    workbox.routing.registerRoute(
        /.*\.(?:eot|svg|ttf|woff|woff2)/g,
        workbox.strategies.staleWhileRevalidate({
            cacheName: "font-cache"
        })
    );
    workbox.routing.registerRoute(
        /.*\.(?:png|jpg|jpeg|svg|gif)/g,
        workbox.strategies.staleWhileRevalidate({
            cacheName: "image-cache",
            plugins: [
            new workbox.expiration.Plugin({
                maxEntries: 60,
                maxAgeSeconds: 7 * 24 * 60 * 60,
            })
        ]
        })
    );
    workbox.googleAnalytics.initialize();
}