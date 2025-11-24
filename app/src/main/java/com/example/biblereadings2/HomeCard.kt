package com.example.biblereadings2

import androidx.annotation.DrawableRes

data class HomeCard(
    val id: Int,
    val title: String,
    @DrawableRes val iconRes: Int,
    val targetActivity: Class<*> // Activity class to open
)

