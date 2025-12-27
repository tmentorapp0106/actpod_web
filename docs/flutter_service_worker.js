'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "bd58eb3a1eeafb0f632fb65533e180c2",
"version.json": "25493ad68f4e3e87125deff7dff486bb",
"index.html": "cab8985c932c44fa2f9d785a2851b0e4",
"/": "cab8985c932c44fa2f9d785a2851b0e4",
"main.dart.js": "47dc31a727ca93922b2cea1b1d0f6881",
"404.html": "7dd4726fde80205372269229ad6175ca",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"favicon.png": "9917066f8e32a572a2e996fdd047797b",
"icons/Icon-192.png": "7cedc088e01ba3d3aafdd1d59c4a817b",
"icons/Icon-maskable-192.png": "7cedc088e01ba3d3aafdd1d59c4a817b",
"icons/Icon-maskable-512.png": "1ecd35309d42d46a95f4f8503a187806",
"icons/Icon-512.png": "1ecd35309d42d46a95f4f8503a187806",
"manifest.json": "31470e3ce515fd8c90e03c084fed7b1b",
"assets/config/server_tw.env": "3fa982c36043e4a9a75c457a34b4d164",
"assets/AssetManifest.json": "04bee4499ba15c96924e15fa6fab9671",
"assets/NOTICES": "c349bb35e00063a321bb584d90dff4d2",
"assets/FontManifest.json": "e15b651c55bec4c6eb19cb64f08a4625",
"assets/AssetManifest.bin.json": "f98b256bf1a81d13bf86b3749fd53fd8",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/fluttertoast/assets/toastify.js": "56e2c9cedd97f10e7e5f1cebd85d53e3",
"assets/packages/fluttertoast/assets/toastify.css": "a85675050054f179444bc5ad70ffc635",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "798e315de918d4685af8f099dc155644",
"assets/fonts/MaterialIcons-Regular.otf": "76db2759d724fe142bdf7ae226eff043",
"assets/assets/images/google_download.png": "d0742d983279458aa918a501e668b3f5",
"assets/assets/images/empty_collections.svg": "fb08cca02c417fd79055dee963dfd7d2",
"assets/assets/images/empty_stories.svg": "fb08cca02c417fd79055dee963dfd7d2",
"assets/assets/images/google-logo.png": "b75aecaf9e70a9b1760497e33bcd6db1",
"assets/assets/images/apple_download.png": "d4d91c90e043d6706ce818fd89107164",
"assets/assets/images/podcoins.png": "e1804eaadedb59041e883f60180529d2",
"assets/assets/images/apple-logo.png": "54739f84f6f8f4add6fda170c600ca7b",
"assets/assets/images/nullAvatar.png": "425d092e064c91c68135361386f97560",
"assets/assets/images/actpod_logo_web.png": "e1d05df515c922c20d7f608da57db829",
"assets/assets/icons/send_voice_message.png": "e1d425cee27ef516ca7b65c948a927a1",
"assets/assets/icons/backward_15.svg": "7b3f14dfe3fa14a04bd1ddb563656bdb",
"assets/assets/icons/forward_15.svg": "55c809e2006ef1d5fa4f08fdca4df9a0",
"assets/assets/icons/listen_to_message.svg": "e06a44921d55ef474a424c1a0391fd49",
"assets/assets/icons/home_page/voice_chat.svg": "a94389704d66ae0fc78e3ec9694b833a",
"assets/assets/icons/home_page/volume_off.svg": "f2f39b57df3dfd3ebb17361ef1678728",
"assets/assets/icons/home_page/headphones.svg": "f1b55cee030ae15936ddee17f13c2338",
"assets/assets/icons/home_page/favorite.svg": "6fb668af9255459b24dc9030e1b68053",
"assets/assets/icons/home_page/graphic_eq.svg": "277fd0a2b5b50e98c0cf1f51c8599025",
"assets/assets/icons/voice_message.svg": "f395b4f1f49f04bfbad0bae0f2413bf6",
"assets/assets/icons/listen_to_message.png": "b025cf09f15dfd9c88cfa6c242169853",
"assets/assets/icons/backward_15.png": "ae175dde4d24217a2d8adce391b7abd9",
"assets/assets/icons/forward_15.png": "53cd98c8b429ece8cc463863cbf660c4",
"assets/assets/icons/send_voice_message.svg": "2fda87adec9ff847c3c57b24eefcc269",
"assets/assets/fonts/NotoSansTC-Regular.ttf": "d809fe87923210679057a2847dceb454",
"assets/assets/fonts/NotoSansTC-Bold.ttf": "822af33401e11a85619df63a83a8839f",
"assets/assets/fonts/NotoSansTC-Medium.ttf": "54aa741d9809a2e7a300155a226237c2",
"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b"};
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
