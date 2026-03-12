package com.example.deenguard

import android.app.Activity
import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.TextView

class BlockedActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        val layout = android.widget.LinearLayout(this).apply {
            orientation = android.widget.LinearLayout.VERTICAL
            gravity = android.view.Gravity.CENTER
            setPadding(50, 50, 50, 50)
        }
        
        val title = TextView(this).apply {
            text = "Content Blocked"
            textSize = 24f
            gravity = android.view.Gravity.CENTER
        }
        
        val message = TextView(this).apply {
            text = "This content has been blocked by DeenGuard"
            textSize = 16f
            gravity = android.view.Gravity.CENTER
            setPadding(0, 20, 0, 40)
        }
        
        val closeButton = Button(this).apply {
            text = "Go Back"
            setOnClickListener {
                finish()
            }
        }
        
        layout.addView(title)
        layout.addView(message)
        layout.addView(closeButton)
        
        setContentView(layout)
    }
}
