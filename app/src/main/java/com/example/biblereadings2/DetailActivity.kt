package com.example.biblereadings2

import android.os.Bundle
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity

class DetailActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_detail)
        val tv = findViewById<TextView>(R.id.detail_title)
        tv.text = intent.getStringExtra("title") ?: "Detail"
    }
}

