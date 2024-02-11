import admin from 'firebase-admin';
import ServiceAccount from '../../serviceAccount.json';

admin.initializeApp({
    credential: admin.credential.cert(ServiceAccount as admin.ServiceAccount),
});

export const db = admin.firestore();