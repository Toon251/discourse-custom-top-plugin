# name: discourse-custom-top-plugin
# about: Custom top
# version: 0.0.1
# authors: Paitoon Burapavijitnon
# url: https://github.com/yourusername/basic-plugin

enabled_site_setting :custom_route_enabled

after_initialize do
  module ::CustomTop
  end

  

  # เปิดขยายหรือแก้ไข TopicParticipantsSummary
  class ::TopicParticipantsSummary
    # Override เมธอด user_ids
    def user_ids
      # ตรวจสอบ @user หรือ topic เพื่อป้องกันค่า nil
      return [] if @user.nil? || topic.nil?

      # ตั้งค่า allowed_user_ids ให้เป็นอาร์เรย์เปล่า หากเป็น nil
      allowed_ids = topic.allowed_user_ids || []
      user_id = topic.user_id

      # ใช้มาตรฐาน compact เพื่อกรอง nil ออกจากอาร์เรย์
      user_id ? [user_id, *allowed_ids].compact - [@user.id] : allowed_ids - [@user.id]
    end
  end

  # แก้ไขพฤติกรรมหน้า /top
  require_dependency 'topic_query'
  class ::TopicQuery
    alias_method :original_top_results, :list_top_for


    def list_top_for(period, limit = nil)
      # Ensure the period is sanitized (e.g., daily, weekly, monthly)
      period = period.to_s.downcase

      # ดึงข้อมูลหัวข้อพร้อมเรียงลำดับตาม "views"

      topics = Topic
                 .visible
                 .where("topics.views IS NOT NULL")
                 .where("topics.bumped_at > ?", period_to_date(period)) # Filter for the period
                 .order(views: :desc) # Order by view count
      #           .order(views: :desc) # เรียงตามจำนวน views
      #           .limit(30)

      # สร้าง TopicList จากผลลัพธ์
      TopicList.new("top", @user, topics)

      
      
      
      #limit_topics(topics, limit)
    end

    # Helper to determine period start time
    def period_to_date(period)
      case period
      when "daily"   then 1.day.ago
      when "weekly"  then 1.week.ago
      when "monthly" then 1.month.ago
      when "yearly"  then 1.year.ago
      else 10.years.ago # All time
      end
    end

  end

  
end
