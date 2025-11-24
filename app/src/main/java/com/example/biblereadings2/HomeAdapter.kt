package com.example.biblereadings2

import android.content.Context
import android.content.Intent
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView

class HomeAdapter(private val ctx: Context, private val items: List<HomeItem>) : RecyclerView.Adapter<HomeAdapter.VH>() {

    data class HomeItem(val title: String, val iconRes: Int, val targetActivity: Class<*>)

    class VH(view: View) : RecyclerView.ViewHolder(view) {
        val icon: ImageView = view.findViewById(R.id.card_icon)
        val title: TextView = view.findViewById(R.id.card_title)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): VH {
        val v = LayoutInflater.from(parent.context).inflate(R.layout.item_home_card, parent, false)
        return VH(v)
    }

    override fun onBindViewHolder(holder: VH, position: Int) {
        val item = items[position]
        holder.icon.setImageResource(item.iconRes)
        holder.title.text = item.title
        holder.itemView.setOnClickListener {
            val i = Intent(ctx, item.targetActivity)
            i.putExtra("title", item.title)
            ctx.startActivity(i)
        }
    }

    override fun getItemCount(): Int = items.size
}
