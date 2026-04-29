/* ============================================
   SetLogix Service Worker
   ============================================ */

const CACHE_NAME = 'setlogix-v1';
const ASSETS = [
  '/',
  '/index.html',
  '/css/index.css',
  '/css/components.css',
  '/css/screens.css',
  '/js/data/exercises.js',
  '/js/store.js',
  '/js/render.js',
  '/js/components/toast.js',
  '/js/components/modal.js',
  '/js/components/navbar.js',
  '/js/screens/dashboard.js',
  '/js/screens/workout.js',
  '/js/screens/program.js',
  '/js/screens/progress.js',
  '/js/screens/exercises.js',
  '/js/screens/calculators.js',
  '/js/screens/more.js',
  '/js/router.js',
  '/js/app.js',
  '/manifest.json',
];

// Install
self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => {
      console.log('[SW] Caching assets');
      return cache.addAll(ASSETS);
    }).catch(err => {
      console.warn('[SW] Cache failed, continuing:', err);
    })
  );
  self.skipWaiting();
});

// Activate
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(keys => {
      return Promise.all(
        keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k))
      );
    })
  );
  self.clients.claim();
});

// Fetch — Network first, fallback to cache
self.addEventListener('fetch', event => {
  event.respondWith(
    fetch(event.request)
      .then(response => {
        const clone = response.clone();
        caches.open(CACHE_NAME).then(cache => {
          cache.put(event.request, clone);
        });
        return response;
      })
      .catch(() => caches.match(event.request))
  );
});
