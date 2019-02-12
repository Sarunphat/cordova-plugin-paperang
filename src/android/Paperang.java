package com.mfec.paperang;

import android.Manifest;
import android.content.Context;
import android.util.Log;

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

    private static final int PERMISSION_REQUEST_COARSE_LOCATION = 0x01;
    public static final String ACCESS_COARSE_LOCATION = Manifest.permission.ACCESS_COARSE_LOCATION;
    public static final int SEARCH_REQ_CODE = 0;

    private Context mContext;
    private Context appContext;

    @Override
    protected void pluginInitialize() {
        // Prepare app and activity context
        mContext = cordova.getActivity();
        appContext = mContext.getApplicationContext();
        // Init paperang service
        PaperangApi.init(appContext, appContext.getPackageName(), new OnInitStatusListener() {
            @Override
            public void initStatus(boolean b) {
                Log.e("sys", "b = " + b);
                // Register paperang
                PaperangApi.registerBT(appContext);
            }
        });
        if (!cordova.hasPermission(ACCESS_COARSE_LOCATION)) {
            cordova.requestPermission(this, SEARCH_REQ_CODE, ACCESS_COARSE_LOCATION);
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        PaperangApi.unregisterBT(appContext);
    }

    @Override
    public void onRequestPermissionResult(int requestCode, String[] permissions,
                                         int[] grantResults) throws JSONException
    {
        // Call function after request granted.
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
        callbackContext.success("Success!");
    }
}