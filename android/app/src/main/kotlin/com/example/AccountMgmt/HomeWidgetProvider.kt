
package com.example.AccountMgmt

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import com.example.AccountMgmt.R
import com.example.AccountMgmt.MainActivity
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class AppWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                // Open App on Widget Click
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("home_widget://open_add_expense")
                )
                setOnClickPendingIntent(R.id.widget_root, pendingIntent)

                val balance = widgetData.getString("current_balance", "0")
                setTextViewText(R.id.tv_balance, balance)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
