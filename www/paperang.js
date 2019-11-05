window.PaperangAPI = {
    register: (successCallback, errorCallback) => {
        cordova.exec(
            successCallback,
            errorCallback,
            "Paperang",
            "register"
        );
    },
    scan: (successCallback, errorCallback) => {
        cordova.exec(
            successCallback,
            errorCallback,
            "Paperang",
            "scan"
        );
    },
    connect: (macAddress, successCallback, errorCallback) => {
        cordova.exec(
            successCallback,
            errorCallback,
            "Paperang",
            "connect",
            [macAddress]
        );
    },
    disconnect: (successCallback, errorCallback) => {
        cordova.exec(
            successCallback,
            errorCallback,
            "Paperang",
            "disconnect"
        );
    },
    print: (base64Image, successCallback, errorCallback) => {
        cordova.exec(
            successCallback,
            errorCallback,
            "Paperang",
            "print",
            [base64Image]
        );
    }
}
