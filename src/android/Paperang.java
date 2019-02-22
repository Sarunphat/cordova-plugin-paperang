package com.mfec.paperang;

import java.util.List;

import android.bluetooth.BluetoothDevice;
import android.Manifest;
import android.content.Context;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import android.util.Log;
import android.util.Base64;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.PluginResult;

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
            }
        });
        if (!cordova.hasPermission(ACCESS_COARSE_LOCATION)) {
            cordova.requestPermission(this, SEARCH_REQ_CODE, ACCESS_COARSE_LOCATION);
        }
        PaperangApi.registerBT(appContext);
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
        final Paperang paperang = this;
        if (action.equals("register")) {
            cordova.getActivity().runOnUiThread(new Runnable() {
                public void run() {
                    paperang.register(callbackContext);
                }
            });
            return true;
        } else if (action.equals("scan")) {
            cordova.getActivity().runOnUiThread(new Runnable() {
                public void run() {
                    paperang.scan(callbackContext);
                }
            });
            return true;
        } else if (action.equals("connect")) {
            final String macAddress = args.getString(0);
            cordova.getActivity().runOnUiThread(new Runnable() {
                public void run() {
                    paperang.connect(macAddress, callbackContext);
                }
            });
            return true;
        } else if (action.equals("disconnect")) {
            cordova.getActivity().runOnUiThread(new Runnable() {
                public void run() {
                    paperang.disconnect(callbackContext);
                }
            });
            return true;
        } else if (action.equals("print")) {
            final String base64String = args.getString(0);
            cordova.getActivity().runOnUiThread(new Runnable() {
                public void run() {
                    paperang.print(base64String, callbackContext);
                }
            });
            return true;
        }
        return false;
    }

    private void register(CallbackContext callbackContext) {
        boolean b = PaperangApi.initBT(mContext);
        if (b) {
            callbackContext.success();
        } else {
            callbackContext.error("Cannot init Bluetooth");
        }
    }

    private void scan(CallbackContext callbackContext) {
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, message);
        pluginResult.setKeepCallback(true); // keep callback
        callbackContext.sendPluginResult(pluginResult);

        PaperangApi.setAutoConnect(true);
        PaperangApi.searchBT(new OnBtDeviceListener() {
            @Override
            public void onBtFound(List<PaperangDevice> deviceList) {
                Log.d("TEST BT", "Device: " + deviceList.toString());
                JSONObject result = new JSONObject();
                JSONArray resultDevices = new JSONArray();
                for (int i = 0;i < deviceList.size(); i++) {
                    PaperangDevice device = deviceList.get(i);
                    JSONObject resultDevice = new JSONObject();
                    resultDevice.put("name", device.getName());
                    resultDevice.put("address", device.getAddress());
                    resultDevices.put(resultDevice);
                }
                result.put("state", "scanning");
                result.put("deviceList", resultDevices);
                callbackContext.success(object);
            }

            @Override
            public void onDiscoveryTimeout() {
                PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, message);
                pluginResult.setKeepCallback(false); // keep callback
                callbackContext.sendPluginResult(pluginResult);
                JSONObject result = new JSONObject();
                JSONArray resultDevices = new JSONArray();
                result.put("state", "finished");
                result.put("deviceList", resultDevices);
                callbackContext.success(object);
            }
        }, 30000);
    }

    private void connect(String macAddress, CallbackContext callbackContext) {
        PaperangApi.connBT(macAddress, 10000, new OnBtDeviceListener() {
            @Override
            public void onBtConnSuccess(final BluetoothDevice device, final int code) {
                callbackContext.success();
            }

            @Override
            public void onBtConnFailed(final int code, final String msg) {
                callbackContext.error("Connect Bluetooth failed.");
            }

            @Override
            public void onBtConnTimeout() {
                callbackContext.error("Connect Bluetooth timeout.");
            }
        });
    }

    private void print (String base64Image, CallbackContext callbackContext) {
        String base64String = base64Image.split(",")[1];
        byte[] decodedString = Base64.decode(base64String, Base64.DEFAULT);
        Bitmap decodedByte = BitmapFactory.decodeByteArray(decodedString, 0, decodedString.length);
        PaperangApi.sendImgToBT(mContext, decodedByte, new OnBtDeviceListener() {
            @Override
            public void onBtDataSendFinish() {
                callbackContext.success();
            }

            @Override
            public void onBtDataSendFailed(final int code, final String msg) {
                callbackContext.error("Data send failed.");
            }
        });
    }

    private void disconnect (CallbackContext callbackContext) {
        PaperangApi.disconnBT();
        callbackContext.success();
    }
}