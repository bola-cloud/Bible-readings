package com.example.biblereadings2

import android.os.Bundle
import android.util.DisplayMetrics
import android.view.View
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.RecyclerView

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContentView(R.layout.activity_main)

        // Apply system window insets to the root view (`@+id/main` in activity_main.xml)
        val root: View = findViewById(R.id.main)
        ViewCompat.setOnApplyWindowInsetsListener(root) { v, insets ->
            val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom)
            insets
        }

        // Initialize the RecyclerView used for the home grid
        val recycler = findViewById<RecyclerView>(R.id.recycler_home)

        // Determine span count based on screen width (approximate)
        val metrics = DisplayMetrics()
        windowManager.defaultDisplay.getMetrics(metrics)
        val screenDp = metrics.widthPixels / metrics.density
        val spanCount = if (screenDp >= 600) 3 else 2

        recycler.layoutManager = GridLayoutManager(this, spanCount)
        recycler.setHasFixedSize(true)

        // Create sample items for the home screen
        val items = listOf(
            HomeAdapter.HomeItem("قراءة يومية", R.drawable.ic_calendar, DetailActivity::class.java),
            HomeAdapter.HomeItem("تأملات من الكتاب المقدس", R.mipmap.ic_launcher, DetailActivity::class.java),
            HomeAdapter.HomeItem("جدول متابعة أسبوعي", R.mipmap.ic_launcher, DetailActivity::class.java),
            HomeAdapter.HomeItem("خطوات عملية", R.mipmap.ic_launcher, DetailActivity::class.java),
            HomeAdapter.HomeItem("حياة قديس", R.mipmap.ic_launcher, DetailActivity::class.java),
            HomeAdapter.HomeItem("خطوات ساعة السجود", R.mipmap.ic_launcher, DetailActivity::class.java),
            HomeAdapter.HomeItem("فضيلة لكل شهر", R.mipmap.ic_launcher, DetailActivity::class.java)
        )

        // Set adapter
        recycler.adapter = HomeAdapter(this, items)
    }
}