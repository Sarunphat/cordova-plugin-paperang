package com.mfec.paperang;

import android.Manifest;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import cn.paperang.sdk.btclient.callback.OnInitStatusListener;
import cn.paperang.sdk.btclient.callback.OnBtDeviceListener;
import cn.paperang.sdk.btclient.callback.OnBtStatusChangeListener;
import cn.paperang.sdk.btclient.model.PaperangDevice;
import cn.paperang.sdk.client.PaperangApi;
import cn.paperang.sdk.client.errcode.DevConnStatus;

/**
 * This class call Paperang API
 */
public class Paperang extends CordovaPlugin {

    public static final String ACCESS_COARSE_LOCATION = Manifest.permission.ACCESS_COARSE_LOCATION;
    public static final int SEARCH_REQ_CODE = 0;

    private Context mContext;

    @Override
    protected void pluginInitialize() {
        mContext = cordova.getActivity();
        Context appContext = mContext.getApplicationContext();
        PaperangApi.init(this, appContext.getPackageName(), new OnInitStatusListener() {
            @Override
            public void initStatus(boolean b) {
                Log.e("sys", "b = " + b);
            }
        });
        PaperangApi.registerBT(appContext);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        PaperangApi.unregisterBT(this);
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("register")) {
            this.register(callbackContext);
            return true;
        }
        return false;
    }

    private void register(CallbackContext callbackContext) {
        if (appId != null) {
            
            callbackContext.success("" + appId + " " + appKey + " " + appSecret);
        } else {
            callbackContext.error("Parameter(s) is missing.");
        }
    }
}