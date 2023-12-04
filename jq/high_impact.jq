#.work[].description[] | select(.meta.impact != "high")
del(.work[].description[] | select(.meta.impact != "high"))