class SessionManager {
  static String? token;
  static String? uid;
  static String? referenceNo; // Unique ID from Gov Auth API

  static void startSession(String newToken, String newUid, String newRefNo) {
    token = newToken;
    uid = newUid;
    referenceNo = newRefNo;
  }

  static void endSession() {
    token = null;
    uid = null;
    referenceNo = null;
  }
}
