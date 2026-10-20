// Firebase Cloud Messaging Service Worker
// This file is required for Firebase push notifications on Flutter Web.

importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

firebase.initializeApp({
    apiKey: "AIzaSyB6f4NOExBLV9l9Y14f-TTAZr_ISXtcMpM",
    authDomain: "sevagan-2a5e3.firebaseapp.com",
    projectId: "sevagan-2a5e3",
    storageBucket: "sevagan-2a5e3.firebasestorage.app",
    messagingSenderId: "513014669350",
    appId: "1:513014669350:web:55413bc04d8599334f06e7",
    measurementId: "G-XVP8RHJJFM"
});

const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage(function (payload) {
    console.log('[firebase-messaging-sw.js] Received background message ', payload);

    const notificationTitle = payload.notification?.title || 'Sevagan';
    const notificationOptions = {
        body: payload.notification?.body || '',
        icon: '/icons/Icon-192.png'
    };

    self.registration.showNotification(notificationTitle, notificationOptions);
});
