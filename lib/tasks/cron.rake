namespace :cron do
  desc "Hourly tasks"
  task :hourly => []
  desc "Daily tasks"
  task :daily  => ["scheduled:regenerateSitemap", "scheduled:recalculateRankingMetrics", "scheduled:deleteExpiredTokens" ]
  desc "Weekly tasks"
  task :weekly => []
  desc "Monthly tasks"
  task :monthly => []
end