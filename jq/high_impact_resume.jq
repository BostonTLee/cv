.work |= map(
  select(.level == "full time" or .level == "internship") | 
  .description |= map(select(.meta.impact == "high"))
)
