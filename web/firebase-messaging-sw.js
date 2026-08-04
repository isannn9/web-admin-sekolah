importScripts('https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js');

firebase.initializeApp({
  apiKey: "AIzaSyAmAtZPBbnqOxECg-ZHZEvaG-mIjxmRcpY",
  authDomain: "pengduanapp.firebaseapp.com",
  projectId: "pengduanapp",
  storageBucket: "pengduanapp.firebasestorage.app",
  messagingSenderId: "326496900877",
  appId: "1:326496900877:web:553f4c755a7790405b0244"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function(payload) {
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: 'icons/Icon-192.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
