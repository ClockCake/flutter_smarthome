package com.jiyoujiaju.jijiahui


import android.content.Context
import android.content.SharedPreferences
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken

// ----- 用户模型 -----
data class UserModel(
    var mobile: String? = null,
    var password: String? = null,
    var nickname: String? = null,
    var name: String? = null,
    var sex: String? = null,
    var avatar: String? = null,
    var tuyaPwd: String? = null,
    var terminalId: String? = null,
    var accessToken: String? = null,
    var city: String? = null,
    var profile: String? = null
)

class FlutterUserPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var appContext: Context

    companion object {
        const val CHANNEL_NAME = "com.example.app/user"
        var methodChannel: MethodChannel? = null
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        try {
            appContext = binding.applicationContext
            channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
            channel.setMethodCallHandler(this)
            methodChannel = channel

            // 初始化 UserManager
            UserManager.initialize(appContext)
            Log.d("FlutterUserPlugin", "Plugin successfully attached to engine")
        } catch (e: Exception) {
            Log.e("FlutterUserPlugin", "Error attaching to engine", e)
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        try {
            Log.d("FlutterUserPlugin", "Method called: ${call.method}")
            Log.d("FlutterUserPlugin", "Arguments: ${call.arguments}")

            when (call.method) {
                "syncUser" -> {
                    val args = call.arguments as? Map<*, *>
                    if (args != null) {
                        val gson = Gson()
                        val jsonStr = gson.toJson(args)
                        Log.d("FlutterUserPlugin", "Syncing user data: $jsonStr")

                        try {
                            val user = gson.fromJson(jsonStr, UserModel::class.java)
                            UserManager.saveUser(user)
                            result.success(true)
                            Log.d("FlutterUserPlugin", "User sync successful")
                        } catch (e: Exception) {
                            Log.e("FlutterUserPlugin", "Error parsing user data", e)
                            result.error("PARSE_ERROR", "解析用户数据失败: ${e.message}", e.stackTraceToString())
                        }
                    } else {
                        Log.e("FlutterUserPlugin", "Invalid arguments: null")
                        result.error("INVALID_ARGS", "用户数据为空", null)
                    }
                }
                "clearUser" -> {
                    UserManager.clearUser()
                    result.success(true)
                    Log.d("FlutterUserPlugin", "User cleared successfully")
                }
                "tuyaLogin" -> {
                    val args = call.arguments as? Map<*, *>
                    if (args != null) {
                        val mobile = args["mobile"] as? String
                        val password = args["password"] as? String
                        if (mobile != null && password != null) {
                            Log.d("FlutterUserPlugin", "Attempting Tuya login: mobile=$mobile")
                            // TODO: 集成涂鸦 SDK 登录逻辑
                            result.success("涂鸦登录成功")
                        } else {
                            Log.e("FlutterUserPlugin", "Missing mobile or password")
                            result.error("INVALID_ARGS", "缺少手机号或密码", null)
                        }
                    } else {
                        Log.e("FlutterUserPlugin", "Invalid arguments for Tuya login")
                        result.error("INVALID_ARGS", "参数为空", null)
                    }
                }
                else -> {
                    Log.w("FlutterUserPlugin", "Method not implemented: ${call.method}")
                    result.notImplemented()
                }
            }
        } catch (e: Exception) {
            Log.e("FlutterUserPlugin", "Unexpected error in method call", e)
            result.error("UNEXPECTED_ERROR", "发生未预期的错误: ${e.message}", e.stackTraceToString())
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        methodChannel = null
        Log.d("FlutterUserPlugin", "Plugin detached from engine")
    }
}

// ----- 用户管理单例 -----
object UserManager {
    private const val PREFS_NAME = "UserPrefs"
    private const val USER_KEY = "CurrentUser"
    private var sharedPreferences: SharedPreferences? = null
    private val gson = Gson()
    var currentUser: UserModel? = null
        private set

    // 防止循环同步
    var isSyncing: Boolean = false

    fun initialize(context: Context) {
        sharedPreferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        loadUser()
    }

    fun saveUser(user: UserModel) {
        currentUser = user
        val jsonStr = gson.toJson(user)
        sharedPreferences?.edit()?.putString(USER_KEY, jsonStr)?.apply()
        if (!isSyncing) {
            syncToFlutter()
        }
    }

    fun loadUser() {
        val jsonStr = sharedPreferences?.getString(USER_KEY, null)
        if (jsonStr != null) {
            try {
                currentUser = gson.fromJson(jsonStr, UserModel::class.java)
            } catch (e: Exception) {
                e.printStackTrace()
                currentUser = null
            }
        }
        if (!isSyncing) {
            syncToFlutter()
        }
    }

    fun updateUser(updateFn: (UserModel) -> UserModel) {
        currentUser?.let {
            val updatedUser = updateFn(it)
            saveUser(updatedUser)
        }
    }

    fun clearUser() {
        currentUser = null
        sharedPreferences?.edit()?.remove(USER_KEY)?.apply()
        if (!isSyncing) {
            syncToFlutter()
        }
    }

    // 同步用户状态到 Flutter 端
    private fun syncToFlutter() {
        val channel = FlutterUserPlugin.methodChannel ?: return
        isSyncing = true
        if (currentUser != null) {
            val jsonStr = gson.toJson(currentUser)
            val type = object : TypeToken<Map<String, Any>>() {}.type
            val userMap: Map<String, Any> = gson.fromJson(jsonStr, type)
            channel.invokeMethod("userUpdated", userMap, object : Result {
                override fun success(result: Any?) {
                    isSyncing = false
                }
                override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                    isSyncing = false
                }
                override fun notImplemented() {
                    isSyncing = false
                }
            })
        } else {
            channel.invokeMethod("userCleared", null, object : Result {
                override fun success(result: Any?) {
                    isSyncing = false
                }
                override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                    isSyncing = false
                }
                override fun notImplemented() {
                    isSyncing = false
                }
            })
        }
    }
}