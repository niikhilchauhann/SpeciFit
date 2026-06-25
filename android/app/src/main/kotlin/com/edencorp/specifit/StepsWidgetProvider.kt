package com.edencorp.myfitnessapp

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class StepsWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_steps).apply {
                val stepsText = widgetData.getString("steps_text", "0 / 10000")
                val stepsProgress = widgetData.getInt("steps_progress_int", 0)
                
                setTextViewText(R.id.widget_steps_text, stepsText)
                setProgressBar(R.id.widget_steps_progress, 100, stepsProgress, false)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
