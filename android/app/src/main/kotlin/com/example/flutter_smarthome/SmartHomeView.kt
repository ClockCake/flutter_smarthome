package com.jiyoujiaju.jijiahui

import android.content.Context
import android.os.Build
import android.util.AttributeSet
import android.util.Log
import android.util.TypedValue
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.webkit.WebChromeClient
import android.webkit.WebSettings
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import android.graphics.Color
import androidx.annotation.RequiresApi
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.RecyclerView

@RequiresApi(Build.VERSION_CODES.LOLLIPOP)
class SmartHomeView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0
) : LinearLayout(context, attrs, defStyleAttr) {

    private lateinit var webView: WebView
    private lateinit var segmentLayout: LinearLayout
    private lateinit var segmentRecyclerView: RecyclerView
    private lateinit var segmentAdapter: SegmentAdapter
    private val segments = arrayOf("客厅", "卧室", "厨房")

    init {
        initView()
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.smart_home_devices_layout, this, true)

        // 初始化 WebView
        webView = findViewById(R.id.header_webview)
        setupWebView()

        findViewById<ImageView>(R.id.vr_icon).setOnClickListener {
            WebViewActivity.start(context, "https://360vryun.cn/t/c84121f49047024e", "VR")
        }

        // 初始化 segment 按钮和 RecyclerView
        initSegments()
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    private fun setupWebView() {
        webView.settings.apply {
            javaScriptEnabled = true
            domStorageEnabled = true
            loadWithOverviewMode = true
            useWideViewPort = true
            mixedContentMode = WebSettings.MIXED_CONTENT_ALWAYS_ALLOW
            cacheMode = WebSettings.LOAD_NO_CACHE
        }
        webView.webViewClient = object : WebViewClient() {
            override fun onPageFinished(view: WebView?, url: String?) {
                super.onPageFinished(view, url)
                Log.d("SmartHomeView", "WebView page loaded: $url")
            }
        }
        webView.webChromeClient = WebChromeClient()
        webView.loadUrl("https://360vryun.cn/t/c84121f49047024e")
    }

    private fun initSegments() {
        segmentLayout = findViewById(R.id.segment_layout)
        segmentRecyclerView = findViewById(R.id.segment_container)
        segmentRecyclerView.layoutManager = GridLayoutManager(context, 2)
        segmentAdapter = SegmentAdapter(emptyList())
        segmentRecyclerView.adapter = segmentAdapter

        segments.forEachIndexed { index, title ->
            val tv = TextView(context).apply {
                text = title
                setPadding(16, 16, 16, 16)
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f)
                setTextColor(Color.GRAY)
                setOnClickListener { showSegmentData(index) }
            }
            segmentLayout.addView(tv)
        }
        // 默认显示第一个 segment 的数据
        showSegmentData(0)
    }

    private fun showSegmentData(index: Int) {
        // 更新 segment 按钮颜色
        for (i in 0 until segmentLayout.childCount) {
            val tv = segmentLayout.getChildAt(i) as TextView
            tv.setTextColor(if (i == index) Color.BLACK else Color.GRAY)
        }
        // 模拟数据源，每个 segment 显示 10 个 item
        val items = mutableListOf<SegmentItem>()
        val segmentTitle = segments[index]
        repeat(10) { i ->
            val color = Color.rgb((0..255).random(), (0..255).random(), (0..255).random())
            items.add(SegmentItem("$segmentTitle - Item ${i + 1}", color))
        }
        segmentAdapter.updateData(items)
    }

    fun refreshContent() {
        webView.reload()
    }

    fun handleBack(): Boolean {
        return if (webView.canGoBack()) {
            webView.goBack()
            true
        } else {
            false
        }
    }

    fun cleanup() {
        webView.destroy()
    }

    data class SegmentItem(val title: String, val color: Int)

    inner class SegmentAdapter(private var items: List<SegmentItem>) :
        RecyclerView.Adapter<SegmentAdapter.SegmentViewHolder>() {

        inner class SegmentViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
            val textView: TextView = itemView.findViewById(R.id.item_text)
        }

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): SegmentViewHolder {
            val view = LayoutInflater.from(parent.context)
                .inflate(R.layout.item_segment, parent, false)
            return SegmentViewHolder(view)
        }

        override fun onBindViewHolder(holder: SegmentViewHolder, position: Int) {
            val item = items[position]
            holder.itemView.setBackgroundColor(item.color)
            Log.d("DEBUG", "item.title = ${item.title}")
            holder.textView.text = item.title ?: ""
        }

        override fun getItemCount(): Int = items.size

        fun updateData(newItems: List<SegmentItem>) {
            items = newItems
            notifyDataSetChanged()
        }


    }
}