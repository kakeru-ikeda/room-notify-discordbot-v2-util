const admin = require('firebase-admin');
const functions = require('firebase-functions');
const ServiceAccount = require('../serviceAccount.json');

admin.initializeApp({ credential: admin.credential.cert(ServiceAccount) });

module.exports.db = admin.firestore();