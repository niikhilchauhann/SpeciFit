package com.edencorp.myfitnessapp

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class WaterWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_water).apply {
                val waterText = widgetData.getString("water_text", "0 / 4000 ml")
                val waterProgress = widgetData.getInt("water_progress_int", 0)
                
                setTextViewText(R.id.widget_water_text, waterText)
                setProgressBar(R.id.widget_water_progress, 100, waterProgress, false)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
