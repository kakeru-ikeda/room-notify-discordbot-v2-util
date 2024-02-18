import { db } from '../module/firestore';

export class FirestoreService {
    /// Firestoreの指定documentに値を追加する
    public async setDocument({ collectionId, documentId, data }: { collectionId: string, documentId: string, data: any }) {
        await db.collection(collectionId).doc(documentId).set(data);
    }

    /** Firestoreの指定documentの値を更新する
     * isExistsMerge: trueの場合、指定documentが存在した場合は更新しない。存在しない場合は新規作成する。
     * @param collectionId string
     * @param documentId string
     * @param data any
     * @param isExistsCheck boolean?
     */
    public async updateDocument({ collectionId, documentId, data, isExistsMerge: isExistsMerge = false }: { collectionId: string, documentId: string, data: any, isExistsMerge?: boolean }) {
        if (isExistsMerge) {
            await this.getDocument({ collectionId, documentId }).then(async doc => {
                if (!doc.exists) {
                    await db.collection(collectionId).doc(documentId).set(data);
                    console.log(`Document ${documentId} is created`);
                } else {
                    console.error(`Document ${documentId} already exists`);
                }
            });
        } else {
            await db.collection(collectionId).doc(documentId).update(data);
            console.log(`Document ${documentId} is updated`);
        }
    }

    /// Firestoreの指定documentの値を削除する
    public async deleteDocument({ collectionId, documentId }: { collectionId: string, documentId: string }) {
        await db.collection(collectionId).doc(documentId).delete();
    }

    /// Firestoreの指定documentの値を取得する
    public async getDocument({ collectionId, documentId }: { collectionId: string, documentId: string }) {
        return await db.collection(collectionId).doc(documentId).get();
    }

    /// Firestoreの指定documentのRefaenceを取得する
    public getDocumentRef({ collectionId, documentId }: { collectionId: string, documentId: string }) {
        return db.collection(collectionId).doc(documentId);
    }

    /// Firestoreの指定collectionの値を取得する
    public async getCollection({ collectionId, where }: { collectionId: string, where?: { fieldPath: string, opStr: FirebaseFirestore.WhereFilterOp, value: any } }) {
        if (where) {
            return await db.collection(collectionId).where(where.fieldPath, where.opStr, where.value).get();
        }
        return await db.collection(collectionId).get();
    }

    /// Firestoreの指定collectionのRefaenceを取得する
    public getCollectionRef({ collectionId, where }: { collectionId: string, where?: { fieldPath: string, opStr: FirebaseFirestore.WhereFilterOp, value: any } }) {
        if (where) {
            return db.collection(collectionId).where(where.fieldPath, where.opStr, where.value);
        }
        return db.collection(collectionId);
    }
}