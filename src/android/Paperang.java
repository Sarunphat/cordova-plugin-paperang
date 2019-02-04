package com.mfec.paperang;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * This class call Paperang API
 */
public class Paperang extends CordovaPlugin {

    public static final String ACCESS_COARSE_LOCATION = Manifest.permission.ACCESS_COARSE_LOCATION;
    public static final int SEARCH_REQ_CODE = 0;

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("register")) {
            Long appId = args.getLong(0);
            String appKey = args.getString(1);
            String appSecret = args.getString(2);

            String base64Image = args.getString(3);
            this.register(appId, appKey, appSecret, base64Image, callbackContext);
            return true;
        }
        return false;
    }

    private void register(Long appId, String appKey, String appSecret, String base64Image, CallbackContext callbackContext) {
        if (appId != null) {
            callbackContext.success("" + appId + " " + appKey + " " + appSecret);
        } else {
            callbackContext.error("Parameter(s) is missing.");
        }
    }
}