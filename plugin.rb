# name: custom-top
# about: Custom top
# version: 0.0.1
# authors: Paitoon Burapavijitnon
# url: https://github.com/yourusername/basic-plugin

enabled_site_setting :custom_route_enabled

after_initialize do
  module ::CustomTop
  end

  # แก้ไขพฤติกรรมหน้า /top
  require_dependency 'topic_query'
  class ::TopicQuery
    alias_method :original_top_results, :list_top_for


    def list_top_for(period)
      # ดึงข้อมูลหัวข้อพร้อมเรียงลำดับตาม "views"
      topics = Topic
                 .visible
                 .order(views: :desc) # เรียงตามจำนวน views
                 .limit(30)

      # สร้าง TopicList จากผลลัพธ์
      TopicList.new("top", @user, topics)
    end

    def user_ids
      return [] if @user.nil? || topic.nil? || topic.user_id.nil?

      allowed_ids = topic.allowed_user_ids || []
      user_array = allowed_ids.compact # ลบค่า nil ออกจาก allowed_user_ids

      [topic.user_id] + user_array - [@user.id]
    end

  end
end
