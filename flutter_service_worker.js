'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {".git/COMMIT_EDITMSG": "6df140bf63ae37c3e120c0dc1513bd56",
".git/config": "7135cd3629009ae1a1e80884cfc3c489",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/HEAD": "5ab7a4355e4c959b0c5c008f202f51ec",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
".git/hooks/fsmonitor-watchman.sample": "a0b2633a2c8e97501610bd3f73da66fc",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-commit.sample": "5029bfab85b1c39281aa9697379ea444",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/hooks/sendemail-validate.sample": "4d67df3a8d5c98cb8565c07e42be0b04",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/index": "68da306150c4f457518639964544393f",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "c93f14830c63e3445886e0417838a87a",
".git/logs/refs/heads/gh-pages": "c93f14830c63e3445886e0417838a87a",
".git/logs/refs/remotes/origin/gh-pages": "675f49264ad421a8704b50fdaaf561bf",
".git/objects/07/cfd79acae79940e7f7b676fb042e5ec33b3b3c": "4bffade4117938d621b3cad452cbec59",
".git/objects/08/62e32b4125217713f2ecd1b539c18fdc321516": "3b0d30a760832eba1d99c6fe7486df5e",
".git/objects/08/876f8d68feeba361b3aaf0f30208c5bcaf0dfd": "e803951e5a11bcd9b9020e7f7caf1fad",
".git/objects/10/78cda765d979b3beedc95a97c39fe0e7f77ed6": "d2cc6a3b861e5dc4b3d92f80704f77a8",
".git/objects/15/4134a7c056706db979d90400491ac015a65f5d": "ef7271aef1b42b7a0c43455089a19900",
".git/objects/1b/b63d7d6720d36c2e96b9cab53a42a1697563ef": "5164f4c9734f015017785bd521a679d3",
".git/objects/21/4215a03b2343798e31d9cbcc9d8029380a11ad": "b0486f433d29368a047e2605d1a4d154",
".git/objects/27/3ed821af66ed05a832ddea044814b71a124a3d": "4275294ad87a0cf10bd19282d422820c",
".git/objects/2f/5cc8a5666866cabe32f29ca881cb0d62bf49bd": "efc2c4346f61190dfbaa3b3cf7556de8",
".git/objects/31/edfe0161ac7c9117968bc771793148e630f501": "fcc5d3924928b9eb3261fa4aeafc0a80",
".git/objects/40/68080224e0dab79a0fd1e011bc81da3779e89f": "81f8db460903f5ca8885ca94617a8eb4",
".git/objects/45/04a8a4703518ebb4dc063c147d97dcc4087a51": "6d7856b68c8a4df1868d9b12837fdec3",
".git/objects/46/4ab5882a2234c39b1a4dbad5feba0954478155": "2e52a767dc04391de7b4d0beb32e7fc4",
".git/objects/48/37533a8ffb636e111644446b8b5254d152a146": "54ab11d80a5332cf91fd2999264849ea",
".git/objects/50/0e2f1a6d02ad0dbe6efaa1ceadf485bd04f65d": "55dc3630a6272f17981cbd8d8f243059",
".git/objects/50/951ddf671c5a68a75580a5e43aef40cba381d2": "89a77b907899ae6ccddab78b55d25093",
".git/objects/55/babe658e2994edec46aa13fdb5e1e2cc5415ce": "93ddecec6f564832964accb131f7daa6",
".git/objects/58/31840272dc1c691085a1cda9eff0467b035365": "adfbc6c173c4e9b037c82eb43ea9b9d0",
".git/objects/65/2f2f0f9c804c8a01b644dd2b524ca406820756": "9e601c473f252f7089da1903b9685180",
".git/objects/6e/7933a7ee21069178a53d2c8a1d8ece7ec2c300": "5d21ff9dabb1f39e86d9f98b8b87c43d",
".git/objects/70/a234a3df0f8c93b4c4742536b997bf04980585": "d95736cd43d2676a49e58b0ee61c1fb9",
".git/objects/75/535b6c62517ca558a96100c77ded526f75bc1a": "14ec71340587dc81550aedf60007c766",
".git/objects/7d/5dd97187ad5e83d7682bc92e205009dc502c7d": "a7e786dc1418dd283ee32cfb3b28607f",
".git/objects/87/de5c8d6130f6abfad858161940b831568b6ded": "b4a97f2fc5af5fd311ee3ec241c89dbf",
".git/objects/88/cfd48dff1169879ba46840804b412fe02fefd6": "e42aaae6a4cbfbc9f6326f1fa9e3380c",
".git/objects/8a/aa46ac1ae21512746f852a42ba87e4165dfdd1": "1d8820d345e38b30de033aa4b5a23e7b",
".git/objects/92/0116a839675f92d9528d5f60c7fac76fc972b0": "0594f4805085b7590ae6deac626302f3",
".git/objects/96/bfbcc9e9a3c8973ccce890151a7aaa6f0cb882": "41dab8fc2ff92d87d2bb23b7b5f370e9",
".git/objects/9a/54a12e07518d774d1aec7f8994c2ac75cc147f": "62e5b19dc0e38064163a0f5de7638115",
".git/objects/9b/d239fe920ca538ce2e963a33eadb75825723e5": "268abdc24bb895d2e24cee4f42c31450",
".git/objects/9b/d3accc7e6a1485f4b1ddfbeeaae04e67e121d8": "784f8e1966649133f308f05f2d98214f",
".git/objects/a2/b7c78c73ca82840bbf538b295cf23111a218c6": "caac676491e878d2a16f6fec6a48dfcd",
".git/objects/a3/0d083faf2e4686f6c51013d8ab82ae8c16e702": "b8263f0d00db5876f66ee7293a6c65e4",
".git/objects/a4/83fd5ede8870254f1f405080de97e3f9c816d1": "85fa983628b71850e1c973ba08f4e3e9",
".git/objects/a8/6f703084d17020859a78f48b1175cc0d672a94": "efb2d3f99c30fff1f13ae08e6c33b7a5",
".git/objects/b7/49bfef07473333cf1dd31e9eed89862a5d52aa": "36b4020dca303986cad10924774fb5dc",
".git/objects/b9/2a0d854da9a8f73216c4a0ef07a0f0a44e4373": "f62d1eb7f51165e2a6d2ef1921f976f3",
".git/objects/b9/38c47dbf6d1348cf2127f0471a29ec16044f0f": "816e5714413b5bb30165bd24bf9cb9ed",
".git/objects/b9/6a5236065a6c0fb7193cb2bb2f538b2d7b4788": "4227e5e94459652d40710ef438055fe5",
".git/objects/b9/c66ff1d69264255399a8c2cb8e7808cccb8295": "eec73cefb8d482d95471e5dea9e00a2a",
".git/objects/be/b77a264f4d4a1be2789cb0ce915d197c347b04": "dfd870be9926c4455dded2ced933dd37",
".git/objects/c2/de2acec1324290949b2241c8c14a01b1913091": "5b0c52a514133f5d5dd0063460f063a0",
".git/objects/cf/2b17a2d212ced45487fbc305c662bc81fcad0f": "963ee38ef9a267437ea348b114f658a7",
".git/objects/d3/a50a3db2546f068fe2f71d6ebfd63bce290178": "9e22736e074f0357ea59f7a2706235aa",
".git/objects/d3/c6a9c652e33376d4bb6749ddfc2ddc6a5fe42c": "3a91161cb326296ec2edb324a7f1da59",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/d6/9c56691fbdb0b7efa65097c7cc1edac12a6d3e": "868ce37a3a78b0606713733248a2f579",
".git/objects/d9/e15f4d1e2a9f542034a95d89e733497dcff109": "0349a2b38408084620cbce7fb1dada59",
".git/objects/dc/11fdb45a686de35a7f8c24f3ac5f134761b8a9": "761c08dfe3c67fe7f31a98f6e2be3c9c",
".git/objects/e2/ee4837d7aa3f78446c7a4bbbd939d74ba53ea6": "4b9005a670b533d0aa7387ba40dc7add",
".git/objects/e4/fd53f12e19b8d859b5f66be79e72bb2abf699b": "a428c27319c2d6629de11dd5cebc0bd6",
".git/objects/e7/653777b6a456a873079ff8978bdbabd7dca501": "97406d2faf71ed6f9e6b18f908c6e5c3",
".git/objects/eb/9b4d76e525556d5d89141648c724331630325d": "37c0954235cbe27c4d93e74fe9a578ef",
".git/objects/f2/04823a42f2d890f945f70d88b8e2d921c6ae26": "6b47f314ffc35cf6a1ced3208ecc857d",
".git/objects/fc/670d19e6e092a6aaa54a55eee38b010849b592": "db30ba7b07ab1aaa8d98491333de54a7",
".git/objects/fd/07803147ebc984b64aabc8ddfd697cea37be66": "b794ff1846818833467c0b21e279de75",
".git/refs/heads/gh-pages": "d488eb69f4cf6457426f8488a06d259b",
".git/refs/remotes/origin/gh-pages": "d488eb69f4cf6457426f8488a06d259b",
"assets/AssetManifest.bin": "430aa17f16e46c574be201605b62fe05",
"assets/AssetManifest.bin.json": "9fe24b30b3788ad9b4c9c05ac631c291",
"assets/AssetManifest.json": "1632ce76aab7a0902354cc398cbc6d4b",
"assets/assets/bg_main.png": "3a18765b26fd52f2a3dc9d884a0d306b",
"assets/assets/enemy.gif": "becdf2bd829b35f07464161d3f857dd6",
"assets/assets/road.png": "fa5de948af37d8e8b8983d672ef36c89",
"assets/assets/road2.png": "8865cde08a16b135e750daa42f8b17e9",
"assets/assets/sounds/attack.mp3": "c91e80e776c99b710df078e39c6b8386",
"assets/assets/sounds/boss_appear.mp3": "7b4a9d34ead6b2fa58718e0b7efca1ca",
"assets/assets/sounds/boss_battle.mp3": "a8ace50c5e05584fd1179cf2f74522ed",
"assets/assets/sounds/click.mp3": "ce2d848e9f9d425efb48638906672d21",
"assets/assets/sounds/fail.mp3": "d4855a31199da84f031e8681c13d5b30",
"assets/assets/sounds/hit.mp3": "b58c83c9c481dad9e8d0742d8dd00c84",
"assets/assets/sounds/home_bgm.mp3": "69418ecbaa6627e55d26a67282ed5e33",
"assets/assets/sounds/run.mp3": "1f5e04d0bb5427a9a4f732dff219b49d",
"assets/assets/sounds/win.mp3": "e3354f229d853ecde9fe97ff9f52d3f9",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "1239e0a5501c639b9391a38a792152b3",
"assets/NOTICES": "da4d6152543b2e75e1a918d4a9848e74",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "825e75415ebd366b740bb49659d7a5c6",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"canvaskit/canvaskit.js.symbols": "27361387bc24144b46a745f1afe92b50",
"canvaskit/canvaskit.wasm": "a37f2b0af4995714de856e21e882325c",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/chromium/canvaskit.js.symbols": "f7c5e5502d577306fb6d530b1864ff86",
"canvaskit/chromium/canvaskit.wasm": "c054c2c892172308ca5a0bd1d7a7754b",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/skwasm.js.symbols": "9fe690d47b904d72c7d020bd303adf16",
"canvaskit/skwasm.wasm": "1c93738510f202d9ff44d36a4760126b",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"flutter_bootstrap.js": "afda9364ca53a40bc5bd19d269f0c9fe",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "ceade8d122ada9f1644f55d0a08516f2",
"/": "ceade8d122ada9f1644f55d0a08516f2",
"main.dart.js": "f2b44e6679e68c7e1fa1d50549967abd",
"manifest.json": "ae39e429a617d66469da3a7a5717ebd8",
"version.json": "c4fcd160df170e1256875caa3d051daf"};
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
