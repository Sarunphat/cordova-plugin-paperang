window.PaperangAPI = {
    register: (appId, appKey, appSecret, base64Image, successCallback, errorCallback) => {
        cordova.exec(
            successCallback,
            errorCallback,
            "Paperang",
            "register",
            [appId, appKey, appSecret, base64Image]
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
