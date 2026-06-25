package com.edencorp.myfitnessapp

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class CaloriesWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_calories).apply {
                val caloriesText = widgetData.getString("calories_text", "0 kcal")
                
                setTextViewText(R.id.widget_calories_text, caloriesText)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
