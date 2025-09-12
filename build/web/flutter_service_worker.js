'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "464ce66bb95eb00858f5a31b9d0eee69",
"assets/AssetManifest.bin.json": "e976d5c9b4352fa74a859ecd8d8ae97a",
"assets/AssetManifest.json": "744ac30bbf49fa9ac300c5a2964cd877",
"assets/assets/banner-admin.svg": "88f1513edf5c3db4a929654188973cc2",
"assets/assets/banner-ambiental.svg": "957985fdf77cc32f2ca18eabc36aebb0",
"assets/assets/banner-automotriz.svg": "c0f2ed6ecb6ddc701c912138b8debf15",
"assets/assets/banner-conta.svg": "8d778ba0c83a0da0490ce1321f99a92d",
"assets/assets/banner-gastro.svg": "3f4cc2e585e10dc9844641fb6a3eb2e1",
"assets/assets/banner-industrial.svg": "64cc6daff7b57d475c1c5e309aca7a49",
"assets/assets/banner-renovables.svg": "a7c555b47d9114efe100f3fd480929e8",
"assets/assets/banner-sistemas.svg": "55d5ea944bbe889ef5aef1b06e3dbd8d",
"assets/assets/banner-tic.svg": "71aa6dea4b706d5636bd2ac67a4214f9",
"assets/assets/banner-tics.svg": "46b1f2c4edb963a7c6d2a09a6d317947",
"assets/assets/course.jpg": "a4c7291abab15087554a5ecc68bfc006",
"assets/assets/dark.riv": "9b140c717b587c75c51c09225672b644",
"assets/assets/empty-box.png": "41b7d990221881d4f3b5d7811507a8f7",
"assets/assets/girl.riv": "f41661028b8c1ca7164dcd3ee2cf1772",
"assets/assets/light.riv": "6960c435bac4d737c5a0a5ac0e14a945",
"assets/assets/login-blue.svg": "e337fb2bab2d867b70b7c931a5533933",
"assets/assets/login.svg": "714ce79ca1e87683f9af61dd4cfb8905",
"assets/assets/LOGO.svg": "a179e91d32d50c1076109f95434f4efd",
"assets/assets/my_course.jpg": "6567f27f2bcd53d9322e744b732b5487",
"assets/assets/notebook.svg": "765a0d9baed7f08893a9cfb25ea68a44",
"assets/assets/notebook_dark.svg": "b3f57501cef5293504ae9c41468e0feb",
"assets/assets/notebook_large.svg": "568ca57a218365a9bce06f0c0a5f92b0",
"assets/assets/notebook_large_dark.svg": "d1944d96f8e4b80d9912f3fa2869873b",
"assets/assets/profile.png": "84f2249c079b1be9b3f7ffb8550120d3",
"assets/assets/profile.svg": "11854ce7a427ae013fba06a20de8b5a5",
"assets/assets/profile_page.jpg": "6a85a4a18274b85febf5e9f432ccf257",
"assets/assets/template.png": "e2e426d0f8408326684d86fd5fca245f",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "a20551648646e1f29a0d8763de760282",
"assets/NOTICES": "2f352fab1cf57f62b456f917689662ee",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "d7d83bd9ee909f8a9b348f56ca7b68c6",
"assets/packages/quill_native_bridge_linux/assets/xclip": "d37b0dbbc8341839cde83d351f96279e",
"assets/packages/wakelock_plus/assets/no_sleep.js": "7748a45cd593f33280669b29c2c8919a",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"canvaskit/canvaskit.js.symbols": "bdcd3835edf8586b6d6edfce8749fb77",
"canvaskit/canvaskit.wasm": "7a3f4ae7d65fc1de6a6e7ddd3224bc93",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/chromium/canvaskit.js.symbols": "b61b5f4673c9698029fa0a746a9ad581",
"canvaskit/chromium/canvaskit.wasm": "f504de372e31c8031018a9ec0a9ef5f0",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/skwasm.js.symbols": "e72c79950c8a8483d826a7f0560573a1",
"canvaskit/skwasm.wasm": "39dd80367a4e71582d234948adc521c0",
"favicon.png": "6ef2ef5dd988fcf2e86f048b0f54d53d",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"flutter_bootstrap.js": "ef19c29f61874a841d5497e7754807ca",
"icons/Icon-192.png": "52fc136b897b3992ee2f3e85182d0545",
"icons/Icon-512.png": "224c0a7356840a94626795af14fae7ff",
"icons/Icon-maskable-192.png": "52fc136b897b3992ee2f3e85182d0545",
"icons/Icon-maskable-512.png": "224c0a7356840a94626795af14fae7ff",
"index.html": "0b394862efa13633faf5ef564d41db4a",
"/": "0b394862efa13633faf5ef564d41db4a",
"main.dart.js": "8477c969f993c329b2ca10caa26ae842",
"manifest.json": "cfe5598039417c728a5aac24d65c2e0d",
"version.json": "ef65212461686012b813864c87f76f8e"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
