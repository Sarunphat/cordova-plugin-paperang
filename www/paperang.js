var PaperangAPI = {
    register: (appId, appKey, appSecret, successCallback, errorCallback) => {
        cordova.exec(
            successCallback,
            errorCallback,
            "Paperang",
            "register",
            [appId, appKey, appSecret]
        );
    },
    scan: (successCallback, errorCallback) => {
        cordova.exec(
            successCallback,
            errorCallback,
            "Paperang",
            "scan"
        );
    }
}

console.log("cordova-plugin-paperang is loaded.");
