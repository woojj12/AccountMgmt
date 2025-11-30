package com.example.AccountMgmt

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class AppWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: android.content.SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                val addExpenseIntent = Intent(context, MainActivity::class.java).apply {
                    action = "android.intent.action.VIEW"
                    data = Uri.parse("accountmgmt://open_add_expense")
                }
                val addExpensePendingIntent = PendingIntent.getActivity(
                    context, 
                    1, 
                    addExpenseIntent, 
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.widget_root, addExpensePendingIntent)

                val balance = widgetData.getString("current_balance", "₩0")
                setTextViewText(R.id.tv_balance, balance ?: "₩0")
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
