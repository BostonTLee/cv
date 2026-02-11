del(.work[].description[] | select(.meta.impact == "low"))
| .work |= map(select(.level == "full time" or .level == "internship"))