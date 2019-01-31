var PaperangAPI = {
    register: (appId, appKey, appSecret, successCallback, errorCallback) => {
        cordova.exec(
            successCallback,
            errorCallback,
            "PaperangCordova",
            "register",
            [appId, appKey, appSecret]
        );
    },
    scan: (successCallback, errorCallback) => {
        cordova.exec(
            successCallback,
            errorCallback,
            "PaperangCordova",
            "scan"
        );
    }
}
