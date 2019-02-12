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

    private boolean isPrinting = false;

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
        if (action.equals("register")) {
            final String base64Image = args.getString(0);
            final String macAddress = args.getString(1);
            final Paperang paperang = this;
            cordova.getActivity().runOnUiThread(new Runnable() {
                public void run() {
                    paperang.register(base64Image, macAddress, callbackContext);
                }
            });
            return true;
        }
        return false;
    }

    private void register(String base64Image, String macAddress, CallbackContext callbackContext) {
        if (isPrinting) { callbackContext.error("Is printing."); }
        else {
            boolean b = PaperangApi.initBT(mContext);
            if (b) {
                PaperangApi.setAutoConnect(true);
                    PaperangApi.searchBT(new OnBtDeviceListener() {
                        @Override
                        public void onBtFound(List<PaperangDevice> deviceList) {
                            Log.i("TEST BT", "DeviceList = " + deviceList.toString());
                            for (int i = 0;i < deviceList.size(); i++) {
                                PaperangDevice device = deviceList.get(i);
                                Log.i("TEST BT", i + ": " + device.getAddress());
                                if (device.getAddress().equals(macAddress)) {
                                    isPrinting = true;
                                    Log.i("TEST BT", "Connect to : " + device.getAddress());
                                    PaperangApi.connBT(macAddress, 10000, new OnBtDeviceListener() {
                                        @Override
                                        public void onBtConnSuccess(final BluetoothDevice device, final int code) {
                                            String base64String = base64Image.split(",")[1];
                                            byte[] decodedString = Base64.decode(base64String, Base64.DEFAULT);
                                            Bitmap decodedByte = BitmapFactory.decodeByteArray(decodedString, 0, decodedString.length);
                                            PaperangApi.sendImgToBT(mContext, decodedByte, new OnBtDeviceListener() {
                                                @Override
                                                public void onBtDataSendFinish() {
                                                    Log.d("TEST BT", "Send data finished.");
                                                }
                            
                                                @Override
                                                public void onBtDataSendFailed(final int code, final String msg) {
                                                    callbackContext.error("Data sending failed.");
                                                    isPrinting = false;
                                                }
                            
                                                @Override
                                                public void onBtPrintFinish() {
                                                    Log.d("TEST BT", "BT Print finished.");
                                                    isPrinting = false;
                                                }
                                            });
                                        }
                    
                                        @Override
                                        public void onBtConnFailed(final int code, final String msg) {
                                            isPrinting = false;
                                            callbackContext.error("Connect Bluetooth failed.");
                                        }
                    
                                        @Override
                                        public void onBtConnTimeout() {
                                            isPrinting = false;
                                            callbackContext.error("Connect Bluetooth timeout.");
                                        }
                                    });
                                }
                            }
                        }

                        @Override
                        public void onDiscoveryTimeout() {
                            Log.e("TEST BT", "BT Discovery timeout.");
                        }
                    }, 30000);
            } else {
                callbackContext.error("Cannot init Bluetooth");
            }
        }
    }
}